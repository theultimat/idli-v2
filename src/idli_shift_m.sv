`include "idli_pkg.svh"


// Shifter is very simple and can only do a single position.
module idli_shift_m import idli_pkg::*; (
  // Clock -- no reset.
  input  var logic        i_shift_gck,

  // Control signals.
  input  var ctr_t        i_shift_ctr,
  input  var shift_op_t   i_shift_op,

  // Input/output data.
  input  var slice_t      i_shift_in,
  input  var logic        i_shift_in_next,
  input  var logic        i_shift_in_prev,
  output var slice_t      o_shift_out
);

  // Possible shift directions.
  typedef enum logic {
    DIR_L,
    DIR_R
  } dir_t;

  // Bit saved between cycles.
  logic stash_q;

  // Direction of shift.
  dir_t dir;

  // New bit to shift in.
  logic next_bit;


  // Everything goes right except ROL.
  always_comb dir = i_shift_op == SHIFT_OP_ROL ? DIR_L : DIR_R;

  // Next bit depends on the shift operation and cycle.
  always_comb unique case (i_shift_op)
    SHIFT_OP_ROR: next_bit = ~|i_shift_ctr ? stash_q : i_shift_in_next;
    SHIFT_OP_ROL: next_bit = ~|i_shift_ctr ? i_shift_in_prev : stash_q;
    SHIFT_OP_SRL: next_bit = &i_shift_ctr ? '0 : i_shift_in_next;
    default:      next_bit = &i_shift_ctr ? i_shift_in[3] : i_shift_in_next;
  endcase

  // Output is based on the next bit and direction.
  always_comb unique case (dir)
    DIR_L:   o_shift_out = {i_shift_in[2:0], next_bit};
    default: o_shift_out = {next_bit, i_shift_in[3:1]};
  endcase

  // Update the saved bit between cycles.
  always_ff @(posedge i_shift_gck) begin
    if (~&i_shift_ctr) begin
      stash_q <= dir == DIR_L ? i_shift_in[3] : i_shift_in[0];
    end
  end

endmodule
