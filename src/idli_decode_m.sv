`include "idli_pkg.svh"


// Decode the 16b instruction from the raw encoding. This will internally flop
// the encoding on the first cycle of the 4 GCK period for generating the
// signals for execution on the fly while the SQI buffer is being overwritten.
module idli_decode_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_de_gck,
  // verilator lint_off UNUSEDSIGNAL
  input  var logic      i_de_rst_n,
  // verilator lint_on UNUSEDSIGNAL

  // Encoding from memory and the sync counter.
  input  var ctr_t      i_de_ctr,
  input  var data_t     i_de_enc,
  input  var logic      i_de_enc_vld,

  // Execution unit control signals.
  output var pipe_t     o_de_pipe,
  output var alu_op_t   o_de_alu_op,
  output var logic      o_de_alu_inv,
  output var logic      o_de_alu_cin,
  output var cmp_op_t   o_de_cmp_op,
  output var shift_op_t o_de_shift_op,

  // Operand locations.
  output var dst_t      o_de_dst,
  output var reg_t      o_de_dst_reg,
  output var src_t      o_de_lhs,
  output var reg_t      o_de_lhs_reg,
  output var src_t      o_de_rhs,
  output var reg_t      o_de_rhs_reg,
  output var aux_t      o_de_aux,

  // Conditional execution signals.
  output var cond_t     o_de_cond,
  output var logic      o_de_cond_wr,
  output var logic      o_de_cond_op,

  // Memory operation specific signals.
  output var reg_t      o_de_mem_first,
  output var reg_t      o_de_mem_last,
  output var mem_op_t   o_de_mem_op,

  // Counter operation signals.
  output var count_op_t o_de_count_op,
  output var slice_t    o_de_count
);

  // Instruction being decoded and whether it's valid.
  data_t enc_q;

  // Flop the new instruction encoding for the next period.
  always_ff @(posedge i_de_gck) begin
    if (&i_de_ctr && i_de_enc_vld) begin
      enc_q <= i_de_enc;
    end
  end

  // Most operations go to the ALU. The four shifts go to the shifter, and the
  // other instructions are frontend-only or IO pin operations.
  always_comb unique casez ({enc_q[0], enc_q[1], enc_q[3]})
    12'b1010_????_101?,
    12'b1010_????_110?: o_de_pipe = PIPE_SHIFT;
    12'b1101_???0_????: o_de_pipe = PIPE_IO;
    12'b1110_???1_????: o_de_pipe = PIPE_COUNT;
    default:            o_de_pipe = PIPE_ALU;
  endcase

  // Most operations are treated as an ADD with the following exceptions:
  //  1) AND, ANDN, and ANY use AND.
  //  2) OR uses OR.
  //  3) XOR and NOT use XOR.
  always_comb unique casez ({enc_q[0], enc_q[1], enc_q[3]})
    12'b001?_????_????,
    12'b1011_?110_????: o_de_alu_op = ALU_OP_AND;
    12'b0100_????_????: o_de_alu_op = ALU_OP_OR;
    12'b0101_????_????,
    12'b1010_????_1110: o_de_alu_op = ALU_OP_XOR;
    default:            o_de_alu_op = ALU_OP_ADD;
  endcase

  // RHS operand for ALU operations should be inverted in the following cases:
  //  1) SUB  => A = B + ~C + 1
  //  2) ANDN => A = B & ~C
  //  3) NOT  => A = B ^ ~C
  //  4) MEM- => B = B + ~ZR
  //  5) -MEM => B = B + ~ZR
  //  6) DEC  => A = B + ~ZR
  //  7) CMP  => A = B + ~C + 1 (excluding ANY)
  always_comb unique casez ({enc_q[0], enc_q[1], enc_q[3]})
    12'b0001_????_????,
    12'b0011_????_????,
    12'b1010_????_1110,
    12'b1010_????_01??,
    12'b1010_????_1??1,
    12'b1011_?0??_????,
    12'b1011_?10?_????: o_de_alu_inv = '1;
    default:            o_de_alu_inv = '0;
  endcase

  // ALU carry in should be set in the following cases only:
  //  1) SUB  => A = B + ~C + 1
  //  2) INC  => A = B + ZR + 1
  //  3) MEM+ => A = B + ZR + 1
  //  4) +MEM => A = B + ZR + 1
  //  5) CMP  => A = B + ~C + 1 (ANY is don't care)
  always_comb unique casez ({enc_q[0], enc_q[3]})
    8'b0001_????,
    8'b1010_10?0,
    8'b1010_00??,
    8'b1011_????: o_de_alu_cin = '1;
    default:      o_de_alu_cin = '0;
  endcase

  // Comparison operation is taken from encoding directly.
  always_comb o_de_cmp_op = cmp_op_t'(enc_q[1][2:0]);

  // Shift operation can be read directly from the encoding.
  always_comb o_de_shift_op = shift_op_t'(enc_q[3][1:0]);

  // Destination is typically a register except for:
  //  1) CMP instructions write to the predicate register P.
  //  2) B/J write to PC.
  //  3) UTX writes to UART.
  //  4) PUTP writes to P.
  always_comb unique casez ({enc_q[0], enc_q[1], enc_q[2]})
    12'b1101_???1_??11,
    12'b1011_????_????: o_de_dst = DST_P;
    12'b1100_????_???1: o_de_dst = DST_PC;
    12'b1101_???1_??01: o_de_dst = DST_UART;
    default:            o_de_dst = DST_REG;
  endcase

  // Typically the destination register comes from the A bits in the encoding,
  // but this isn't always the case:
  //  1) LD[M]/ST[M] write to ZR to discard the address.
  //  2) LD+/-ST/... write to B instead of A.
  //  3) URX and GETP write A but it's in the location of C.
  always_comb unique casez ({enc_q[0], enc_q[3]})
    8'b011?_????,
    8'b100?_????: o_de_dst_reg = REG_ZR;
    8'b1010_0???: o_de_dst_reg = reg_t'(enc_q[2]);  // B
    8'b1101_????: o_de_dst_reg = reg_t'(enc_q[3]);  // C
    default:      o_de_dst_reg = reg_t'(enc_q[1]);  // A
  endcase

  // LHS comes from a register except for instructions that offset the PC:
  // ADDPC and B[L].
  always_comb unique casez ({enc_q[0], enc_q[1], enc_q[2]})
    12'b1100_????_???0,
    12'b1100_???0_???1: o_de_lhs = SRC_PC;
    default:            o_de_lhs = SRC_REG;
  endcase

  // When a register LHS is almost always taken from B except for J[L], URX,
  // UTX, GETP, PUTP, and LDM/STM which all offset from ZR.
  always_comb unique casez (enc_q[0])
    4'b100?,
    4'b1100,
    4'b1101:  o_de_lhs_reg = REG_ZR;
    default:  o_de_lhs_reg = reg_t'(enc_q[2]);  // B
  endcase

  // Based on the encoding RHS can only come from the C bits or the UART, but
  // we also need to account for the immediate following when C is SP (i.e.
  // all bits are high). There are some exceptions we need to handle:
  //  1) LDM/STM is always register B which can't be an immediate.
  //  2) GETP is always ZR.
  //  3) URX is UART.
  // There also also some exceptions that we don't need to explicitly handle
  // as enc_q[3] is not all 1s:
  //  1) MEM+/-MEM etc always use ZR.
  //  2) INC/DEC/NOT always use ZR.
  always_comb unique casez ({enc_q[0], enc_q[2]})
    8'b100?_????,
    8'b1101_??10: o_de_rhs = SRC_REG;
    8'b1101_??00: o_de_rhs = SRC_UART;
    default:      o_de_rhs = &enc_q[3] ? SRC_SQI : SRC_REG;
  endcase

  // Force RHS to ZR as descibed above. Don't need to worry about operand
  // being set incorrectly for shifts as it's unused anyway.
  always_comb unique casez ({enc_q[0], enc_q[2]})
    8'b1010_????,
    8'b1101_??10: o_de_rhs_reg = REG_ZR;
    default:      o_de_rhs_reg = reg_t'(enc_q[3]);  // C
  endcase

  // Some operations perform an auxiliary write operation in addition to the
  // primary write controlled by DST. These are:
  //  1) LD[M]/ST[M] or +MEM/-MEM write the result to SQI to redirect.
  //  2) MEM+/MEM- write the LHS operand to SQI.
  //  3) BL/JL write the next PC to LR.
  always_comb unique casez ({enc_q[0], enc_q[1], enc_q[2], enc_q[3]})
    16'b011?_????_????_????,
    16'b100?_????_????_????,
    16'b1010_????_????_0?1?:  o_de_aux = AUX_SQI_DST;
    16'b1010_????_????_0?0?:  o_de_aux = AUX_SQI_LHS;
    16'b1100_??1?_???1_????:  o_de_aux = AUX_LR;
    default:                  o_de_aux = AUX_NONE;
  endcase

  // Whether to write to the conditional execution state. This is performed by
  // CMPX instructions and CEX only.
  always_comb unique casez ({enc_q[0], enc_q[1]})
    8'b1011_1???,
    8'b1110_???0: o_de_cond_wr = '1;
    default:      o_de_cond_wr = '0;
  endcase

  // Value to write for cond is taken directly from the encoding for CEX. For
  // CMPX operations the value is always fixed to 'b11 to conditionally
  // execute the next instruction if P is true only.
  always_comb o_de_cond = enc_q[0] == 4'b1110 ? cond_t'({enc_q[2], enc_q[3]})
                                              : cond_t'(2'b11);

  // First memory register always comes from the the bits typically used for
  // operand A.
  always_comb o_de_mem_first = reg_t'(enc_q[1]);

  // Last memory register is taken from the standard B operand location for
  // LDM and STM, and is the same as the first register for all other LD/ST.
  always_comb unique casez (enc_q[0])
    4'b1?0?:  o_de_mem_last = reg_t'(enc_q[2]);
    default:  o_de_mem_last = o_de_mem_first;
  endcase

  // Memory operation can be read directly from the encoding.
  always_comb unique casez (enc_q[0])
    4'b011?,
    4'b100?:  o_de_mem_op = mem_op_t'(enc_q[0][0]);
    default:  o_de_mem_op = mem_op_t'(enc_q[3][0]);
  endcase

  // Count operation can be read directly from the encodings.
  always_comb o_de_count_op = count_op_t'(enc_q[2][1:0]);

  // Counter value is always the final slice.
  always_comb o_de_count = enc_q[3];

  // Signal to pick up COND instruction only.
  always_comb unique casez ({enc_q[0], enc_q[1]})
    8'b1110_???0: o_de_cond_op = '1;
    default:      o_de_cond_op = '0;
  endcase

endmodule
