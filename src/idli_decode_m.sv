`include "idli_pkg.svh"


// Decode instruction stream 4b per cycle into an operation to execute. Also
// maintains the state of various control signals such as condition execution
// mask, predicate register, and carry in.
module idli_decode_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic    i_de_gck,
  input  var logic    i_de_rst_n,

  // Control signals from the rest of the core.
  input  var ctr_t    i_de_ctr,
  input  var logic    i_de_redirect,

  // Encoded instruction as read from memory.
  input  var slice_t  i_de_enc,
  input  var logic    i_de_enc_vld
);

  // Encoding arrives 4b per cycle so decode needs to maintain a state machine
  // to fully decode an instruction. Extra states are also added for LD* and
  // ST* which generate multiple operations for a single encoding.
  typedef enum logic [4:0] {
    // Cycle 0
    STATE_INIT,       // Reset state, process opcode major.

    // Cycle 1
    STATE_ABC,        // Operands A + B + C
    STATE_RNG_0,      // Range cycle 0: operands R + S + B.
    STATE_OP_AB,      // Opcode + A + B.
    STATE_CMP,        // Comparison operation + B + C.
    STATE_PC_0,       // PC operation + opcode/A + C
    STATE_PUP,        // Pin/UART/predicate operation.
    STATE_DEC_0,      // Decode only instruction cycle 1.

    // Cycle 2
    STATE_BC,         // Operands B + C.
    STATE_RNG_1,      // Range cycle 1: operands S + B.
    STATE_AB,         // Operands A + B.
    STATE_AC,         // Operands A + C.
    STATE_PC_1,       // Opcode + C.
    STATE_PIN,        // Pin opcode + operand.
    STATE_UP,         // UART/predicate + operand.
    STATE_DEC_1,      // Decode only instruction cycle 2.
    STATE_M_0,        // First cycle of operand M.
    STATE_NC,         // Operands N + C.

    // Cycle 3
    STATE_C,          // Operand C.
    STATE_RNG_2,      // Range cycle 2: operand B.
    STATE_B,          // Operand B.
    STATE_A,          // Operand A.
    STATE_M_1,        // Second cycle of operand M.
    STATE_J,          // Operand J.

    // Extra
    STATE_IMM,        // Immediate data.
    STATE_MEM,        // Load/store single register.
    STATE_POST_MEM    // Redirect after memory access.
  } state_t;

  // Current and next stte for decoder.
  state_t state_q;
  state_t state_d;

  // Saved state for the partially decoded operation.
  op_t op_q;
  op_t op_d;

  // Whether we've decoded a memory operation.
  logic mem_vld_q;
  logic mem_vld_d;

  // Whether the memory operation is a load or store.
  logic mem_st_q;
  logic mem_st_d;

  // Memory range start and end.
  reg_t mem_next_q;
  reg_t mem_next_d;
  reg_t mem_end_q;
  reg_t mem_end_d;

  // Flop new state and in-progress decoded operation. Operation doesn't need
  // to be reset as we should write all enables while decoding.
  always_ff @(posedge i_de_gck, negedge i_de_rst_n) begin
    if (!i_de_rst_n) begin
      state_q <= STATE_INIT;
    end
    else begin
      state_q <= state_d;
      op_q    <= op_d;
    end
  end

  // Determine the next state for the state machine.
  always_comb case (state_q)
    // Cycle 0
    STATE_INIT: begin
      casez ({i_de_enc_vld, i_de_enc})
        5'b0????: state_d = state_q;
        5'b10???: state_d = STATE_ABC;
        5'b1100?: state_d = STATE_RNG_0;
        5'b11010: state_d = STATE_OP_AB;
        5'b11011: state_d = STATE_CMP;
        5'b11100: state_d = STATE_PC_0;
        5'b11101: state_d = STATE_PUP;
        default:  state_d = STATE_DEC_0;
      endcase
    end

    // Cycle 1
    STATE_ABC:    state_d = STATE_BC;
    STATE_RNG_0:  state_d = STATE_RNG_1;
    STATE_OP_AB:  state_d = STATE_AB;
    STATE_CMP:    state_d = &i_de_enc[2:0] ? STATE_NC    : STATE_BC;
    STATE_PC_0:   state_d =  i_de_enc[0]   ? STATE_PC_1  : STATE_AC;
    STATE_PUP:    state_d =  i_de_enc[0]   ? STATE_UP    : STATE_PIN;
    STATE_DEC_0:  state_d =  i_de_enc[0]   ? STATE_DEC_1 : STATE_M_0;

    // Cycle 2
    STATE_BC, STATE_AC,
    STATE_PC_1, STATE_NC: state_d = STATE_C;
    STATE_AB:             state_d = STATE_B;
    STATE_RNG_1:          state_d = STATE_RNG_2;
    STATE_UP, STATE_PIN:  state_d = i_de_enc[0] ? STATE_C : STATE_A;
    STATE_DEC_1:          state_d = STATE_J;
    STATE_M_0:            state_d = STATE_M_1;

    // If C is SP (i.e. all 1) then an immediate follows this instruction. We
    // also need to check for a memory operation, and this should take
    // priority over the immediate so we can generate the next instruction
    // while the immediate is being processed.
    STATE_C: casez ({mem_vld_q, i_de_enc})
      5'b1????: state_d = STATE_MEM;
      5'b01111: state_d = STATE_IMM;
      default:  state_d = STATE_INIT;
    endcase

    // Stay in IMM or POST_MEM until end of 16b packet.
    STATE_IMM, STATE_POST_MEM: state_d = &i_de_ctr ? STATE_INIT : state_q;

    // Generate another LD/ST operation until we hit the end register.
    STATE_MEM: state_d = mem_next_q == mem_end_q ? STATE_POST_MEM : state_q;

    // Catch all for other cycle 3 entries. Either return back to INIT or
    // start a memory operation.
    default: state_d = mem_vld_q ? STATE_MEM : STATE_INIT;
  endcase

  // Instructions that go to the execution stage all go to the ALU except for
  // shift instructions.
  always_comb casez ({state_q, i_de_enc})
    {STATE_INIT,  4'b????}: op_d.pipe = PIPE_ALU;
    {STATE_OP_AB, 4'b101?},
    {STATE_OP_AB, 4'b110?}: op_d.pipe = PIPE_SHIFT;
    default:                op_d.pipe = op_q.pipe;
  endcase

  // Where the destination should be written to. If an operation doesn't write
  // a result the value will be written to ZR and discarded.
  always_comb case (state_q)
    STATE_ABC,
    STATE_MEM,
    STATE_AB,
    STATE_A:        op_d.dst = DST_REG;
    STATE_CMP:      op_d.dst = DST_P;
    STATE_PC_0:     op_d.dst =  i_de_enc[0] ? DST_REG : DST_PC;
    STATE_UP:       op_d.dst = ~i_de_enc[0] ? DST_REG :
                                i_de_enc[1] ? DST_P   : DST_UART;
    STATE_POST_MEM: op_d.dst = DST_PC;
    default:        op_d.dst = op_q.dst;
  endcase

  // Where the LHS operand should come from. This is almost always a register,
  // so we reset back to REG on the first cycle and then override it as
  // required.
  always_comb case (state_q)
    STATE_INIT,
    STATE_MEM,
    STATE_POST_MEM: op_d.lhs = SRC_REG;
    STATE_PC_0:     op_d.lhs = SRC_PC;
    STATE_UP:       op_d.lhs = i_de_enc[1] ? SRC_REG : SRC_UART;
    default:        op_d.lhs = op_q.lhs;
  endcase

  // Location of the RHS operand. Special care needs to be taken to check for
  // operand C == SP to pick up the immediate from SQI.
  always_comb case (state_q)
    STATE_INIT,
    STATE_POST_MEM: op_d.rhs = SRC_REG;
    STATE_C:        op_d.rhs = &i_de_enc ? SRC_SQI : SRC_REG;
    STATE_MEM:      op_d.rhs =  mem_st_q ? SRC_REG : SRC_SQI;
    default:        op_d.rhs = op_q.rhs;
  endcase

  // Destination register is mostly read directly from the encoding but in
  // some cases we override with ZR to discard. Special cases also exist for
  // memory operations to pick up the approprate load register.
  always_comb case (state_q)
    STATE_ABC,
    STATE_AB:   op_d.dst_reg = mem_vld_q ? REG_ZR : reg_t'(i_de_enc);
    STATE_CMP:  op_d.dst_reg = REG_ZR;
    STATE_AC,
    STATE_A:    op_d.dst_reg = reg_t'(i_de_enc);
    STATE_MEM:  op_d.dst_reg = mem_st_q ? REG_ZR : mem_next_q;
    default:    op_d.dst_reg = op_q.dst_reg;
  endcase

endmodule
