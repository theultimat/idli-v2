`include "idli_pkg.svh"


// Wrapper for the top module for debug.
module idli_tb_m import idli_pkg::*; ();

  // Clock and reset signals.
  logic gck;
  logic rst_n;

  // Signals connected to the low and high SQI memories.
  logic   mem_lo_sck;
  logic   mem_hi_sck;
  logic   mem_lo_cs;
  logic   mem_hi_cs;
  slice_t mem_lo_in;
  slice_t mem_hi_in;
  slice_t mem_lo_out;
  slice_t mem_hi_out;

endmodule
