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
  // to fully decode an instruction. Extra states are also added for LDM and
  // STM which generate multiple operations for a single encoding.
  typedef enum logic [4:0] {
    STATE_INIT,       // Reset state, process opcode major.

    STATE_ABC,        // Operands A, B, and C remain.
    STATE_RBS,        // Operands R, B, and S remain.
    STATE_AB,         // Operands A and B remain followed by opcode.
    STATE_CMP,        // Compare opcode followed by operands B and C/N.
    STATE_PC_0,       // PC operation followed by opcode and C.
    STATE_FLAG_0,     // Flag/IO operation followed by C/J.
    STATE_CEX,        // Operation is a CEX.

    STATE_BC,         // B and C remain.
    STATE_BS,         // B and S remain.
    STATE_B,          // B followed by opcode.
    STATE_PC_1,       // PC opcode followed by C.
    STATE_FLAG_1,     // Flag/IO opcode followed by C or J.
    STATE_M_0,        // First chunk of operand M.

    STATE_C,          // C remains.
    STATE_S,          // S remains.
    STATE_AB_OP,      // Opcode after A and B remains.
    STATE_J,          // J operand remains.
    STATE_M_1,        // Second chunk of operand M.

    STATE_IMM,        // Immedate data.
    STATE_LD,         // Generate LD register write.
    STATE_ST,         // Generate ST register read.
    STATE_POST_MEM    // Post-memory access redirect.
  } state_t;

  // Current and next stte for decoder.
  state_t state_q;
  state_t state_d;

  // Saved state for the partially decoded operation.
  op_t op_q;
  op_t op_d;

  // Current and final register for loads and stores.
  reg_t mem_reg_q;
  reg_t mem_reg_d;
  reg_t mem_end_reg_q;

  // Whether memory operation is LD or ST.
  logic mem_st_q;
  logic mem_st_d;

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
    STATE_INIT: begin
      casez ({i_de_enc_vld, i_de_enc})
        5'b0????: state_d = state_q;
        5'b10???: state_d = STATE_ABC;
        5'b1100?: state_d = STATE_RBS;
        5'b11010: state_d = STATE_AB;
        5'b11011: state_d = STATE_CMP;
        5'b11100: state_d = STATE_PC_0;
        5'b11101: state_d = STATE_FLAG_0;
        5'b11110: state_d = STATE_CEX;
        default:  state_d = state_t'('x); // Invalid encoding!
      endcase
    end
    STATE_FLAG_1: begin
      casez ({op_q.dst_reg, i_de_enc[3:2]})
        6'b000001,
        6'b001011:  state_d = STATE_C;
        default:    state_d = STATE_J;
      endcase
    end
    STATE_C: begin
      // Take immediate data when C == SP unless redirecting.
      casez ({i_de_redirect, i_de_enc[2:0]})
        4'b0111:  state_d = STATE_IMM;
        default:  state_d = STATE_INIT;
      endcase
    end
    STATE_IMM: begin
      // Return back to INIT on final cycle of immediate.
      state_d = &i_de_ctr ? STATE_INIT : STATE_IMM;
    end
    STATE_LD, STATE_ST: begin
      // Keep generating more LD/ST instructions until there are no more
      // registers to process.
      state_d = &i_de_ctr && mem_reg_q == mem_end_reg_q ? STATE_POST_MEM
                                                        : state_q;
    end
    STATE_S: begin
      // Move into either LD or ST state depending on which operation is being
      // performed.
      state_d = mem_st_q ? STATE_ST : STATE_LD;
    end
    STATE_POST_MEM: begin
      // Generate a PC update then return back to INIT.
      state_d = &i_de_ctr ? STATE_INIT : state_q;
    end
    STATE_AB_OP: begin
      // Move to LD or ST if this is a memory operation otherwise back to
      // INIT.
      casez (i_de_enc)
        4'b1???:  state_d = STATE_INIT;
        4'b0??0:  state_d = STATE_LD;
        default:  state_d = STATE_ST;
      endcase
    end
    STATE_ABC, STATE_CMP:   state_d = STATE_BC;
    STATE_RBS:              state_d = STATE_BS;
    STATE_AB:               state_d = STATE_B;
    STATE_PC_0:             state_d = STATE_PC_1;
    STATE_FLAG_0:           state_d = STATE_FLAG_1;
    STATE_CEX:              state_d = STATE_M_0;
    STATE_BC, STATE_PC_1:   state_d = STATE_C;
    STATE_BS:               state_d = STATE_S;
    STATE_B:                state_d = STATE_AB_OP;
    STATE_M_0:              state_d = STATE_M_1;
    default: begin
      // This is the final state of the instruction encoding -- return back to
      // INIT in all cases.
      state_d = STATE_INIT;
    end
  endcase

  // If the instruction is actually going to the execution unit then it's
  // always ALU unless it's a shift. This is determined on the final cycle of
  // decoding so there's no need to save the flopped value.
  always_comb casez ({state_q, i_de_enc})
    {STATE_AB_OP, 4'b101?},
    {STATE_AB_OP, 4'b110?}: op_d.pipe = PIPE_SHIFT;
    default:                op_d.pipe = PIPE_ALU;
  endcase

endmodule
