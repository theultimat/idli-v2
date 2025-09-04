`include "idli_pkg.svh"


// Empty paths -- these must be overridden for each individual test.
`ifndef idli_tb_mem_lo_d
`define idli_tb_mem_lo_d ""
`endif

`ifndef idli_tb_mem_hi_d
`define idli_tb_mem_hi_d ""
`endif


// Bench for running on FPGA. This instantiates the two memories internally to
// keep everything on the board except for UART which will be connected to an
// external Raspberry Pi and output pins to LEDs.
module idli_tb_fpga_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_tb_gck,
  input  var logic      i_tb_rst_n,

  // UART TX and RX.
  input  var logic      i_tb_uart_rx,
  output var logic      o_tb_uart_rx_rdy,
  output var logic      o_tb_uart_tx,

  // Output pins.
  // TODO Input pins driven by Pi?
  output var io_pins_t  o_tb_pins
);

  // Low memory signals.
  logic   mem_lo_sck;
  logic   mem_lo_cs;
  slice_t mem_lo_sio_in;
  slice_t mem_lo_sio_out;

  // High memory signals.
  logic   mem_hi_sck;
  logic   mem_hi_cs;
  slice_t mem_hi_sio_in;
  slice_t mem_hi_sio_out;


  // Core.
  idli_top_m idli_top_u (
    .i_top_gck        (i_tb_gck),
    .i_top_rst_n      (i_tb_rst_n),

    .o_top_mem_lo_sck (mem_lo_sck),
    .o_top_mem_lo_cs  (mem_lo_cs),
    .i_top_mem_lo_sio (mem_lo_sio_in),
    .o_top_mem_lo_sio (mem_lo_sio_out),
    // verilator lint_off PINCONNECTEMPTY
    .o_top_mem_lo_en  (),
    // verilator lint_on PINCONNECTEMPTY

    .o_top_mem_hi_sck (mem_hi_sck),
    .o_top_mem_hi_cs  (mem_hi_cs),
    .i_top_mem_hi_sio (mem_hi_sio_in),
    .o_top_mem_hi_sio (mem_hi_sio_out),
    // verilator lint_off PINCONNECTEMPTY
    .o_top_mem_hi_en  (),
    // verilator lint_on PINCONNECTEMPTY

    .i_top_uart_rx    (i_tb_uart_rx),
    .o_top_uart_tx    (o_tb_uart_tx),

    .i_top_io_pins    (io_pins_t'('0)),
    .o_top_io_pins    (o_tb_pins)
  );

  // Low memory.
  idli_sqi_mem_m mem_lo_u (
    .i_sqi_sck  (mem_lo_sck),
    .i_sqi_cs   (mem_lo_cs),

    .i_sqi_sio  (mem_lo_sio_out),
    .o_sqi_sio  (mem_lo_sio_in)
  );

  // High memory.
  idli_sqi_mem_m mem_hi_u (
    .i_sqi_sck  (mem_hi_sck),
    .i_sqi_cs   (mem_hi_cs),

    .i_sqi_sio  (mem_hi_sio_out),
    .o_sqi_sio  (mem_hi_sio_in)
  );


  // Wait until we're stalled waiting for UART RX data before sending.
  always_comb o_tb_uart_rx_rdy = idli_top_u.ex_u.stall_urx
                              && idli_top_u.urx_u.bits_q != 4'd15
                              && idli_top_u.ex_u.enc_vld_q;


  // Load the memories from file.
  initial begin
    $readmemh(`idli_tb_mem_lo_d, mem_lo_u.data_q);
    $readmemh(`idli_tb_mem_hi_d, mem_hi_u.data_q);
  end

endmodule
