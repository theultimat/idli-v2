`include "idli_pkg.svh"


// Top-level module for the core. This is what is instantiated in the bench
// and what should eventually be used as the module in Tiny Tapeout.
module idli_top_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_top_gck,
  input  var logic      i_top_rst_n,

  // Low memory interface.
  output var logic      o_top_mem_lo_sck,
  output var logic      o_top_mem_lo_cs,
  input  var slice_t    i_top_mem_lo_sio,
  output var slice_t    o_top_mem_lo_sio,

  // High memory interface.
  output var logic      o_top_mem_hi_sck,
  output var logic      o_top_mem_hi_cs,
  input  var slice_t    i_top_mem_hi_sio,
  output var slice_t    o_top_mem_hi_sio,

  // UART interface.
  input  var logic      i_top_uart_rx,
  output var logic      o_top_uart_tx,

  // Input and output pin interface.
  input  var io_pins_t  i_top_io_pins,
  output var io_pins_t  o_top_io_pins
);

endmodule
