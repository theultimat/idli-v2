`include "idli_pkg.svh"


// Buffers 16b of data, with the endianness of the data being reversed between
// reading and writing. The buffer is designed to work with pipelining such
// that while one 16b chunk is being written the other is being read out, 4b
// at a time. This means the read data is the current value in the buffer at
// the pointer, which will be replaced by the write data on the next cycle.
module idli_sqi_buf_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic    i_sqi_gck,
  input  var logic    i_sqi_rst_n,

  // Global counter, push signal, and direction of data.
  input  var ctr_t    i_sqi_ctr,
  input  var logic    i_sqi_push,
  output var logic    o_sqi_dir,

  // Current read and write data. We also provide a view of the entire buffer
  // which can be useful for e.g. instruction decode.
  input  var slice_t  i_sqi_slice,
  output var slice_t  o_sqi_slice,
  output var data_t   o_sqi_data
);

  // Data stored in the buffer.
  data_t  data_q;

  // Current and next value for the pointer. There are four slices in the
  // buffer so we need a 2b index.
  logic [1:0] ptr_q;
  logic [1:0] ptr_d;

  // Direction of pointer movement and whether we need to reverse.
  logic dir_q;
  logic flip;

  // Update pointer and direction if a push was made.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      ptr_q <= '0;
      dir_q <= '0;
    end
    else if (i_sqi_push) begin
      ptr_q <= ptr_d;

      if (flip) begin
        dir_q <= ~dir_q;
      end
    end
  end

  // Flop new data into the buffer.
  always_ff @(posedge i_sqi_gck) begin
    if (i_sqi_push) begin
      data_q[ptr_q] <= i_sqi_slice;
    end
  end

  // Output current slice, buffer contents, and direction.
  always_comb o_sqi_slice = data_q[ptr_q];
  always_comb o_sqi_data  = data_q;
  always_comb o_sqi_dir   = dir_q;

  // Next pointer value depends on whether we're pushing at the direction of
  // motion. If we're flipping this cycle then there's no need to increment.
  always_comb unique case ({flip, i_sqi_push, dir_q})
    3'b010:   ptr_d = ptr_q + 2'b1;
    3'b011:   ptr_d = ptr_q - 2'b1;
    default:  ptr_d = ptr_q;
  endcase

  // Need to reverse when the next write will overflow the buffer and we're on
  // a 4 GCK boundary.
  always_comb flip = &i_sqi_ctr && (~dir_q && &ptr_q || dir_q && ~|ptr_q);

endmodule
