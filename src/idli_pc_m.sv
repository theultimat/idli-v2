`include "idli_pkg.svh"


// PC value and incrementing logic.
module idli_pc_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_pc_gck,
  input  var logic      i_pc_rst_n,

  // Control signals.
  input  var ctr_t      i_pc_ctr,
  input  var logic      i_pc_inc,
  input  var logic      i_pc_redirect,
  input  var slice_t    i_pc_data,

  // Current slice of the PC and next sequential PC.
  output var slice_t    o_pc,
  output var slice_t    o_pc_next
);

  // Current and next PC value.
  data_t  pc_q;
  slice_t pc_d;

  // Carry propagation as 4b add per cycle.
  logic carry_q;
  logic carry_d;


  // PC rotates every cycle and resets to zero.
  always_ff @(posedge i_pc_gck, negedge i_pc_rst_n) begin
    if (!i_pc_rst_n) begin
      pc_q    <= '0;
      carry_q <= '1;
    end
    else begin
      pc_q    <= {pc_d, pc_q[3:1]};
      carry_q <= carry_d;
    end
  end

  // Compute the next sequential value of the PC by adding the carry in.
  always_comb begin
    {carry_d, o_pc_next} = o_pc + slice_t'(carry_q);

    // Reset carry back to 1 for next instruction to keep incrementing.
    if (&i_pc_ctr) begin
      carry_d = '1;
    end
  end

  // Next value to actually store for the PC depends on the control signals.
  // If we're incrementing this is the next sequential PC, and if we're
  // redirecting it's the incoming address data.
  always_comb unique casez ({i_pc_redirect, i_pc_inc})
    2'b1?:    pc_d = i_pc_data;
    2'b01:    pc_d = o_pc_next;
    default:  pc_d = o_pc;
  endcase

  // Ouput the current slice of the PC.
  always_comb o_pc = pc_q[0];

endmodule
