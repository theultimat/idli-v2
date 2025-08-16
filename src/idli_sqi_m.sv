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
  input  var logic    i_sqi_stall,

  // Data IO with the rest of the core.
  input  var slice_t  i_sqi_slice,
  output var slice_t  o_sqi_slice,
  output var data_t   o_sqi_instr,
  output var logic    o_sqi_instr_vld,
  output var logic    o_sqi_wr_acp,

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

  // Output value to each memory on the previous cycle.
  slice_t hi_sio_q;
  slice_t lo_sio_q;

  // Signals for the internal buffer.
  logic   buf_push;
  logic   buf_dir;
  slice_t buf_push_slice;
  data_t  buf_data;

  // Whether the memory has ever been redirected.
  logic redirected_q;

  // Whether state changed on this cycle.
  logic changed_q;

  // Whether this transaction is a WRITE.
  logic wr_en_q;

  // Internal buffer for reversing endianness of data -- core is LE but
  // memories are BE.
  idli_sqi_buf_m buf_u (
    .i_sqi_gck,
    .i_sqi_rst_n,

    .i_sqi_ctr,
    .i_sqi_push   (buf_push),
    .o_sqi_dir    (buf_dir),

    .i_sqi_slice  (buf_push_slice),
    .o_sqi_slice,
    .o_sqi_data   (buf_data)
  );

  // Update state of the state machine every other falling edge of SCK for to
  // ensure the output pins will be ready for the next rising SCK edge. Also
  // track whether we've ever been redirected to control address behaviour.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      state_q       <= STATE_RESET;
      redirected_q  <= '0;
      changed_q     <= '0;
    end
    else if (&i_sqi_ctr) begin
      state_q       <= state_d;
      redirected_q  <= redirected_q || i_sqi_redirect;
      changed_q     <= state_q != state_d;
    end
  end

  // Determine the next state for the state machine. It's only possible to
  // enter the stall state during DATA so we don't need to consider it
  // elsewhere.
  always_comb begin
    unique case (state_q)
      STATE_RESET:        state_d = STATE_INSTR;
      STATE_INSTR:        state_d = STATE_ADDR_HI;
      STATE_ADDR_HI:      state_d = STATE_ADDR_LO;
      STATE_ADDR_LO:      state_d = STATE_DUMMY;
      STATE_DUMMY:        state_d = STATE_DATA;
      default: /* DATA */ state_d = i_sqi_redirect ? STATE_RESET : STATE_DATA;
    endcase
  end

  // Flop write enable on first cycle of a new transaction.
  always_ff @(posedge i_sqi_gck) begin
    if (&i_sqi_ctr && state_q == STATE_RESET) begin
      wr_en_q <= i_sqi_wr_en;
    end
  end

  // Flop the new value of SCK. In standard operation this is the *inverse* of
  // the low bit of the counter to ensure we get SCK high on the second GCK
  // cycle of the 4 GCK period. At times we need to pause SCK so the clock
  // will be tied zero to hold memory until data is ready. If we're stalled
  // then the clock stays at zero. Also pause clock when in DUMMY for a write
  // so the core can write store data into the buffer.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      sck_q <= '0;
    end
    else begin
      sck_q <= ~i_sqi_ctr[0] && !i_sqi_stall
                             && !(state_q == STATE_DUMMY && wr_en_q);
    end
  end

  // Output current value of SCK to the HI memory.
  always_comb o_sqi_hi_sck = sck_q;

  // CS should be high when in RESET state only.
  // TODO Need to flop for glitches?
  always_comb o_sqi_hi_cs = state_q == STATE_RESET;

  // Data to send to the memory depends on the state. For INSTR it's either
  // READ or WRITE, and for others the value should be read out of the buffer.
  // For outgoing data need to make sure value stays the same on the pin for a
  // complete SCK otherwise we may flop the wrong value.
  always_comb unique case (state_q)
    STATE_INSTR:  o_sqi_hi_sio = i_sqi_ctr[1] ? {3'b1, ~wr_en_q} : '0;
    STATE_DATA:   o_sqi_hi_sio = sck_q ? hi_sio_q : o_sqi_slice;
    default:      o_sqi_hi_sio = o_sqi_slice;
  endcase

  // LO memory gets the previous cycle's SCK and CS so it's always one GCK
  // behind the HI memory. Also save the previous value written to the HI
  // memory so this can be mirrored for ADDR and INSTR.
  always_ff @(posedge i_sqi_gck) begin
    o_sqi_lo_sck <= o_sqi_hi_sck;
    o_sqi_lo_cs  <= o_sqi_hi_cs;
    hi_sio_q     <= o_sqi_hi_sio;
    lo_sio_q     <= o_sqi_lo_sio;
  end

  // LO memory shadows the HI memory with cycle of delay for INSTR and ADDR,
  // followed by the output of the internal buffer for DATA. Keep outgoing
  // data high for complete SCK as with HI memory for store data -- we need to
  // do this in RESET to account for the last nibble of a store just before we
  // redirect.
  always_comb unique case (state_q)
    STATE_RESET,
    STATE_DATA: begin
      if (wr_en_q) begin
        o_sqi_lo_sio = sck_q ? o_sqi_slice : lo_sio_q;
      end
      else begin
        o_sqi_lo_sio = changed_q ? hi_sio_q : o_sqi_slice;
      end
    end
    default: o_sqi_lo_sio = hi_sio_q;
  endcase

  // Buffer update behaviour depends on whether we're redirected the memory or
  // not (e.g. due to branch/load/store).
  always_comb begin
    if (redirected_q) begin
      // If we have redirected then the address was written in during the end
      // of the previous transaction's DATA cycle. As a result we need to hold
      // the data such that it's read out of the buffer every SCK rather than
      // every GCK when in ADDR. Once we get back to DATA it's business as
      // usual.
      unique case (state_q)
        STATE_DATA:     buf_push = !i_sqi_stall;
        STATE_DUMMY:    buf_push = wr_en_q;
        STATE_ADDR_HI,
        STATE_ADDR_LO:  buf_push = sck_q;
        default:        buf_push = '0;
      endcase
    end
    else begin
      // If we've never redirected then data can always be pushed into the
      // buffer -- address should be held at zero on reset and once we hit
      // DATA we'll stay there until redirect. Still need to account for
      // stalls though!
      buf_push = !i_sqi_stall;
    end
  end

  // Data to push into the buffer comes from the memory if and only if we're
  // in the DATA state and aren't being redirected. If we're writing then data
  // always comes from the core.
  always_comb begin
    unique case (state_q)
      STATE_DATA: buf_push_slice = i_sqi_redirect ? i_sqi_slice :
                                   i_sqi_ctr[0]   ? i_sqi_lo_sio : i_sqi_hi_sio;
      default:    buf_push_slice = i_sqi_slice;
    endcase

    if (wr_en_q) begin
      buf_push_slice = i_sqi_slice;
    end
  end

  // Instruction will be ready for flopping by the decode unit on the final
  // DATA cycle in the 4 GCK period.
  always_comb o_sqi_instr_vld = state_q == STATE_DATA && &i_sqi_ctr;

  // Instruction encoding presented to the decode unit. We need to keep the
  // data in a consistent order, so data may need to be reversed based on the
  // current direction of the buffer. The encoding will be flopped in the
  // decode unit, so we also make sure we present the data currently incoming
  // from the memory for the final nibble rather than the old data in the
  // buffer.
  always_comb begin
    if (buf_dir) begin
      o_sqi_instr = {buf_push_slice, buf_data[1], buf_data[2], buf_data[3]};
    end
    else begin
      o_sqi_instr = {buf_push_slice, buf_data[2:0]};
    end
  end

  // Hold off memory writes until we're in the DUMMY or DATA states.
  always_comb o_sqi_wr_acp = state_q == STATE_DUMMY || state_q == STATE_DATA;

endmodule
