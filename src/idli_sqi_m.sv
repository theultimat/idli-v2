`include "idli_pkg.svh"


// Interface to the two attached SQI memories. This module is responsible for
// handling the SQI protocol and presenting/accepting data from the rest of
// the core. We have two SQI memories attached, one of which holds the high
// nibbles and the other which holds the low.
module idli_sqi_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic    i_sqi_gck,
  input  var logic    i_sqi_rst_n,

  // Control signals for redirecting and sync.
  input  var ctr_t    i_sqi_ctr,
  input  var logic    i_sqi_redirect,
  input  var logic    i_sqi_wr_en,

  // Data IO with the rest of the core.
  input  var slice_t  i_sqi_slice,
  output var slice_t  o_sqi_slice,
  output var logic    o_sqi_slice_vld,
  output var data_t   o_sqi_data,

  // Interface with the low memory.
  output var logic    o_sqi_lo_sck,
  output var logic    o_sqi_lo_cs,
  input  var slice_t  i_sqi_lo_sio,
  output var slice_t  o_sqi_lo_sio,

  // Interface with the high memory.
  output var logic    o_sqi_hi_sck,
  output var logic    o_sqi_hi_cs,
  input  var slice_t  i_sqi_hi_sio,
  output var slice_t  o_sqi_hi_sio
);

  idli_sqi_buf_m buf_u (
    .i_sqi_gck,
    .i_sqi_rst_n,

    .i_sqi_ctr,
    .i_sqi_push   ('0),
    .i_sqi_slice  (i_sqi_slice),

    .o_sqi_slice  (o_sqi_slice),
    .o_sqi_data   (o_sqi_data)
  );

  // Tie off unused signals.
  always_comb o_sqi_lo_sck    = '0;
  always_comb o_sqi_lo_cs     = '1;
  always_comb o_sqi_lo_sio    = 'x;
  always_comb o_sqi_hi_sck    = '0;
  always_comb o_sqi_hi_cs     = '1;
  always_comb o_sqi_hi_sio    = 'x;
  always_comb o_sqi_slice_vld = '0;

  logic _unused;
  always_comb _unused = &{
    1'b0, i_sqi_lo_sio, i_sqi_hi_sio, i_sqi_redirect, i_sqi_wr_en
  };

endmodule
