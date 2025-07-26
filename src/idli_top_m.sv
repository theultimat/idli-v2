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

  data_t  instr;
  logic   instr_vld;
  slice_t mem_data;

  // TODO Move the counter into the sync/control block.
  ctr_t ctr_q;
  always_ff @(posedge i_top_gck, negedge i_top_rst_n) begin
    if (!i_top_rst_n) ctr_q <= '0;
    else              ctr_q <= ctr_q + 2'b1;
  end


  idli_sqi_m sqi_u (
    .i_sqi_gck        (i_top_gck),
    .i_sqi_rst_n      (i_top_rst_n),

    .i_sqi_ctr        (ctr_q),
    .i_sqi_redirect   ('0),
    .i_sqi_wr_en      ('0),

    .i_sqi_slice      ('0),
    .o_sqi_slice      (mem_data),
    .o_sqi_instr      (instr),
    .o_sqi_instr_vld  (instr_vld),

    .o_sqi_lo_sck     (o_top_mem_lo_sck),
    .o_sqi_lo_cs      (o_top_mem_lo_cs),
    .i_sqi_lo_sio     (i_top_mem_lo_sio),
    .o_sqi_lo_sio     (o_top_mem_lo_sio),

    .o_sqi_hi_sck     (o_top_mem_hi_sck),
    .o_sqi_hi_cs      (o_top_mem_hi_cs),
    .i_sqi_hi_sio     (i_top_mem_hi_sio),
    .o_sqi_hi_sio     (o_top_mem_hi_sio)
  );


  idli_ex_m ex_u (
    .i_ex_gck     (i_top_gck),
    .i_ex_rst_n   (i_top_rst_n),

    .i_ex_ctr     (ctr_q),
    .i_ex_enc     (instr),
    .i_ex_enc_vld (instr_vld),
    .i_ex_data    (mem_data)
  );


  // Tie off unused signals for now.
  always_comb o_top_uart_tx = 'x;
  always_comb o_top_io_pins = 'x;

  logic _unused;
  always_comb _unused = &{1'b0, i_top_uart_rx, i_top_io_pins};

endmodule
