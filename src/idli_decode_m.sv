`include "idli_pkg.svh"


// Decode the 16b instruction from the raw encoding. This will internally flop
// the encoding on the first cycle of the 4 GCK period for generating the
// signals for execution on the fly while the SQI buffer is being overwritten.
module idli_decode_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_de_gck,
  input  var logic      i_de_rst_n,

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
  output var shift_op_t o_de_shift_op
);

  // Instruction being decoded and whether it's valid.
  // verilator lint_off UNUSEDSIGNAL
  data_t enc_q;
  logic  enc_vld_q;
  // verilator lint_on UNUSEDSIGNAL

  // Flop the new instruction encoding for the next period.
  always_ff @(posedge i_de_gck, negedge i_de_rst_n) begin
    if (!i_de_rst_n) begin
      enc_vld_q <= '0;
    end
    else if (&i_de_ctr) begin
      enc_q     <= i_de_enc;
      enc_vld_q <= i_de_enc_vld;
    end
  end

  // All operations go to the ALU except for shift instructions.
  always_comb unique casez ({enc_q[0], enc_q[3]})
    8'b1010_10??,
    8'b1010_11??: o_de_pipe = PIPE_SHIFT;
    default:      o_de_pipe = PIPE_ALU;
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
  always_comb unique casez ({enc_q[0], enc_q[3]})
    8'b0001_????,
    8'b0011_????,
    8'b1010_1110,
    8'b1010_01??,
    8'b1010_1??1: o_de_alu_inv = '1;
    default:      o_de_alu_inv = '0;
  endcase

  // ALU carry in should be set in the following cases only:
  //  1) SUB  => A = B + ~C + 1
  //  2) INC  => A = B + ZR + 1
  //  3) MEM+ => A = B + ZR + 1
  //  4) +MEM => A = B + ZR + 1
  always_comb unique casez ({enc_q[0], enc_q[3]})
    8'b0001_????,
    8'b1010_10?0,
    8'b1010_00??: o_de_alu_cin = '1;
    default:      o_de_alu_cin = '0;
  endcase

  // Comparison operation is taken from encoding directly.
  always_comb o_de_cmp_op = cmp_op_t'(enc_q[1][2:0]);

  // Shift operation can be read directly from the encoding.
  always_comb o_de_shift_op = shift_op_t'(enc_q[3][1:0]);

endmodule
