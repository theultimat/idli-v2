`include "idli_pkg.svh"


// Receive 16b of UART data from outside then present it to the core.
module idli_urx_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic    i_urx_gck,
  input  var logic    i_urx_rst_n,

  // Sync counter an EX interface.
  input  var ctr_t    i_urx_ctr,
  output var slice_t  o_urx_data,
  output var logic    o_urx_vld,
  input  var logic    i_urx_acp,

  // External interface.
  input  var logic    i_urx_data
);

  // UART will be waiting for external data, receiving data from the outside,
  // or waiting for data to be consumed by EX.
  typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_DATA_IN_LO,
    STATE_DATA_IN_HI,
    STATE_DATA_OUT
  } state_t;

  // Current and next state.
  state_t state_q;
  state_t state_d;

  // Number of bits we've received.
  logic [3:0] bits_q;

  // 16b buffer for holding one transaction's worth of data.
  logic [15:0] data_q;


  // Update the state every GCK as we can't know when a new transaction will
  // start.
  always_ff @(posedge i_urx_gck, negedge i_urx_rst_n) begin
    if (!i_urx_rst_n) begin
      state_q <= STATE_IDLE;
    end
    else begin
      state_q <= state_d;
    end
  end

  // Stay IDLE until we see a start bit, then move into DATA_IN. Once we have
  // 16b worth of data in the buffer move to DATA_OUT and wait until the
  // buffer is consumed by EX.
  always_comb unique case (state_q)
    STATE_IDLE:             state_d = i_urx_data ? state_q : STATE_DATA_IN_LO;
    STATE_DATA_IN_LO:       state_d = bits_q[2:0] == 3'd3 ? STATE_DATA_IN_HI
                                                          : state_q;
    STATE_DATA_IN_HI:       state_d = bits_q == 4'd7  ? STATE_IDLE :
                                      bits_q == 4'd15 ? STATE_DATA_OUT
                                                      : state_q;
    default: /* DATA_OUT */ state_d = &i_urx_ctr && i_urx_acp ? STATE_IDLE
                                                              : state_q;
  endcase

  // Output data is valid if we're in the DATA_OUT state. This means we have
  // a full 16b of data ready to go.
  always_comb o_urx_vld = state_q == STATE_DATA_OUT;

  // Flop incoming data in DATA_IN and push out on DATA_OUT when EX is
  // accepting the data.
  always_ff @(posedge i_urx_gck) begin
    if (state_q == STATE_DATA_IN_LO || state_q == STATE_DATA_IN_HI) begin
      data_q <= {i_urx_data, data_q[15:1]};
    end
    else if (state_q == STATE_DATA_OUT && i_urx_acp) begin
      data_q <= {4'bx, data_q[15:4]};
    end
  end

  // Output data to EX from the bottom of the buffer.
  always_comb o_urx_data = data_q[3:0];

  // Count in new bits as they arrive, resetting back to zero once we're full.
  always_ff @(posedge i_urx_gck, negedge i_urx_rst_n) begin
    if (!i_urx_rst_n) begin
      bits_q <= '0;
    end
    else begin
      if (state_q == STATE_DATA_IN_LO || state_q == STATE_DATA_IN_HI) begin
        bits_q <= bits_q + 4'd1;
      end
      else if (state_q == STATE_DATA_OUT) begin
        bits_q <= '0;
      end
    end
  end

endmodule
