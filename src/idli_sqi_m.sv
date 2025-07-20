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

  // States for controlling the SQI transaction. The general sequence of
  // operation is as follows:
  //
  //  1) CS = 1 to reset transaction state.
  //  2) CS = 0 to start a new transaction.
  //  3) Send 8b instruction (READ or WRITE).
  //  4) Send 16b address.
  //  5) Wait for dummy byte to clock out if READ.
  //  6) Read/write data 4b per cycle.
  //
  // GCK is running at twice the frequency of SCK, with the HI memory always
  // half an SCK ahead of the LO memory. This means we can get 4b per cycle at
  // GCK rather than 4b per cycle at SCK.
  typedef enum logic [2:0] {
    STATE_RESET,
    STATE_INSTR,
    STATE_ADDR_HI,
    STATE_ADDR_LO,
    STATE_DUMMY,
    STATE_DATA
  } state_t;

  // Current and next state.
  state_t state_q;
  state_t state_d;

  // Value of SCK, flopped to avoid glitches on the output.
  logic sck_q;

  // Output value to the HI memory on the previous cycle.
  slice_t hi_sio_q;

  // Whether to push data and what to push.
  logic   buf_push;
  slice_t buf_push_slice;

  // Internal buffer for reversing endianness of data -- core is LE but
  // memories are BE.
  idli_sqi_buf_m buf_u (
    .i_sqi_gck,
    .i_sqi_rst_n,

    .i_sqi_ctr,
    .i_sqi_push   (buf_push),
    .i_sqi_slice  (buf_push_slice),

    .o_sqi_slice,
    .o_sqi_data
  );

  // Update state of the state machine every other falling edge of SCK for to
  // ensure the output pins will be ready for the next rising SCK edge.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      state_q <= STATE_RESET;
    end
    else if (&i_sqi_ctr) begin
      state_q <= state_d;
    end
  end

  // Determine the next state for the state machine.
  always_comb unique case (state_q)
    STATE_RESET:        state_d = STATE_INSTR;
    STATE_INSTR:        state_d = STATE_ADDR_HI;
    STATE_ADDR_HI:      state_d = STATE_ADDR_LO;
    STATE_ADDR_LO:      state_d = i_sqi_wr_en ? STATE_DATA : STATE_DUMMY;
    STATE_DUMMY:        state_d = STATE_DATA;
    default: /* DATA */ state_d = i_sqi_redirect ? STATE_RESET : STATE_DATA;
  endcase

  // Flop the new value of SCK. In standard operation this is the *inverse* of
  // the low bit of the counter to ensure we get SCK high on the second GCK
  // cycle of the 4 GCK period. At times we need to pause SCK so the clock
  // will be tied zero to hold memory until data is ready.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      sck_q <= '0;
    end
    else begin
      sck_q <= ~i_sqi_ctr[0];
    end
  end

  // Output current value of SCK to the HI memory.
  always_comb o_sqi_hi_sck = sck_q;

  // CS should be high when in RESET state only.
  // TODO Need to flop for glitches?
  always_comb o_sqi_hi_cs = state_q == STATE_RESET;

  // Data to send to the memory depends on the state. For INSTR it's either
  // READ or WRITE, and for others the value should be read out of the buffer.
  always_comb unique case (state_q)
    STATE_INSTR:  o_sqi_hi_sio = i_sqi_ctr[1] ? {3'b1, ~i_sqi_wr_en} : '0;
    default:      o_sqi_hi_sio = o_sqi_slice;
  endcase

  // LO memory gets the previous cycle's SCK and CS so it's always one GCK
  // behind the HI memory. Also save the previous value written to the HI
  // memory so this can be mirrored for ADDR and INSTR.
  always_ff @(posedge i_sqi_gck) begin
    o_sqi_lo_sck <= o_sqi_hi_sck;
    o_sqi_lo_cs  <= o_sqi_hi_cs;
    hi_sio_q     <= o_sqi_hi_sio;
  end

  // LO memory shadows the HI memory with cycle of delay for INSTR and ADDR,
  // followed by the output of the internal buffer for DATA.
  always_comb unique case (state_q)
    STATE_DATA: o_sqi_lo_sio = o_sqi_slice;
    default:    o_sqi_lo_sio = hi_sio_q;
  endcase

  // Data should be pushed into the buffer in the following states.
  //  - INSTR:    Address is written by core.
  //  - ADDR_LO:  First 16b of data is written.
  //  - DATA:     More data is written.
  always_comb buf_push = state_q == STATE_INSTR
                      || state_q == STATE_ADDR_LO
                      || state_q == STATE_DATA;

  // Data to push into the buffer should come from the memory on DATA cycles
  // and from the core on all others.
  always_comb unique case (state_q)
    STATE_DATA: buf_push_slice = i_sqi_ctr[0] ? i_sqi_lo_sio : i_sqi_hi_sio;
    default:    buf_push_slice = i_sqi_slice;
  endcase

  // Data coming out of the core is valid when we leave the DATA state for the
  // first time. At this point we have read a complete 16b into the buffer so
  // it is ready to be read back out in LE.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      o_sqi_slice_vld <= '0;
    end
    else if (&i_sqi_ctr) begin
      o_sqi_slice_vld <= state_q == STATE_DATA;
    end
  end

endmodule
