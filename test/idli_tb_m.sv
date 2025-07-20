`include "idli_pkg.svh"


// Wrapper for the top module for debug. Note that many of the signals are
// driven by the python script so we need to tell the linter to not complain
// for a number of signals.
module idli_tb_m import idli_pkg::*; ();

  // verilator lint_off UNDRIVEN
  // verilator lint_off UNUSEDSIGNAL

  // Clock and reset signals.
  logic gck;
  logic rst_n;

  // Signals connected to the low and high SQI memories.
  logic   mem_lo_sck;
  logic   mem_hi_sck;
  logic   mem_lo_cs;
  logic   mem_hi_cs;
  slice_t mem_lo_out;
  slice_t mem_hi_out;
  slice_t mem_lo_in;
  slice_t mem_hi_in;

  // UART signals.
  logic uart_rx;
  logic uart_tx;

  // IO pins.
  io_pins_t pins_in;
  io_pins_t pins_out;

  // verilator lint_on UNDRIVEN
  // verilator lint_on UNUSEDSIGNAL


  // Instantiate the top-level module of the core and connect to the bench.
  idli_top_m idli_top_u (
    .i_top_gck        (gck),
    .i_top_rst_n      (rst_n),

    .o_top_mem_lo_sck (mem_lo_sck),
    .o_top_mem_lo_cs  (mem_lo_cs),
    .i_top_mem_lo_sio (mem_lo_in),
    .o_top_mem_lo_sio (mem_lo_out),

    .o_top_mem_hi_sck (mem_hi_sck),
    .o_top_mem_hi_cs  (mem_hi_cs),
    .i_top_mem_hi_sio (mem_hi_in),
    .o_top_mem_hi_sio (mem_hi_out),

    .i_top_uart_rx    (uart_rx),
    .o_top_uart_tx    (uart_tx),

    .i_top_io_pins    (pins_in),
    .o_top_io_pins    (pins_out)
  );

endmodule
