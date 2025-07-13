`include "idli_pkg.svh"


// Last In First Out implementation.
module idli_lifo_m import idli_pkg::*; #(
  parameter int unsigned DEPTH = 4
) (
  // Clock and reset.
  input  var logic    i_lifo_gck,
  input  var logic    i_lifo_rst_n,

  // Data IO and push/pop controls.
  input  var logic    i_lifo_push,
  input  var logic    i_lifo_pop,
  input  var slice_t  i_lifo_data,
  output var slice_t  o_lifo_data
);

  // Width and type of a pointer for indexing into the storage.
  localparam int unsigned PTR_W = $clog2(DEPTH);
  typedef logic [PTR_W-1:0] ptr_t;

  // Data is stored in 4b slices.
  slice_t [DEPTH-1:0] data_q;

  // Current and next pointer into storage.
  ptr_t ptr_q;
  ptr_t ptr_d;

  // Flop new pointer value. We reset to the maximum value so that when
  // pushing the *next* value of ptr is the insertion index, and the *current*
  // value of ptr is where to read from.
  always_ff @(posedge i_lifo_gck, negedge i_lifo_rst_n) begin
    if (!i_lifo_rst_n) begin
      ptr_q <= '1;
    end
    else begin
      ptr_q <= ptr_d;
    end
  end

  // Write data into the buffer when pushing. Buffer contents are not reset as
  // we should never read out of a buffer without first writing something into
  // it.
  always_ff @(posedge i_lifo_gck) begin
    if (i_lifo_push) begin
      data_q[ptr_d] <= i_lifo_data;
    end
  end

  // Next value for the pointer depend on the push and pop values. If both are
  // active then the pointer doesn't move.
  always_comb case ({i_lifo_push, i_lifo_pop})
    2'b01:    ptr_d = ptr_q - ptr_t'('b1);
    2'b10:    ptr_d = ptr_q + ptr_t'('b1);
    default:  ptr_d = ptr_q;
  endcase

  // Output data always comes from the top of the stack.
  always_comb o_lifo_data = data_q[ptr_q];

endmodule
