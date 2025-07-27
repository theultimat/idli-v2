`include "idli_pkg.svh"


// UART TX. Assumes other device is configured such that we have one bit per
// cycle.
module idli_utx_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_utx_gck,
  input  var logic      i_utx_rst_n,

  // Control and execution unit interface.
  input  var ctr_t      i_utx_ctr,
  input  var slice_t    i_utx_data,
  input  var logic      i_utx_vld,
  output var logic      o_utx_acp,

  // Output to top level.
  output var logic      o_utx_data
);

  // UART is configured for 1b per cycle, 8b payload, 1 stop bit.
  typedef enum logic {
    STATE_IDLE,
    STATE_DATA
  } state_t;

  // Current and next state.
  state_t state_q;
  state_t state_d;

  // Counter to track number of bits in the buffer. Each period of the
  // synchronisation counter is 4 GCK, so we can track the number of nibbles
  // sent TX using another 4b counter.
  ctr_t ctr_q;

  // Buffer containing data to send.
  logic [15:0] data_q;

  // New data has been pushed into the buffer.
  logic new_data;


  // Flop new state. This can only change on a 4 GCK boundary to keep in sync
  // with the rest of the core.
  always_ff @(posedge i_utx_gck, negedge i_utx_rst_n) begin
    if (!i_utx_rst_n) begin
      state_q <= STATE_IDLE;
    end
    else if (&i_utx_ctr) begin
      state_q <= state_d;
    end
  end

  // Determine the next state. We move out of IDLE when we have data to send,
  // and we stay in DATA until we've sent 8b of data.
  always_comb unique case (state_q)
    STATE_IDLE: state_d = new_data || |ctr_q ? STATE_DATA : STATE_IDLE;
    default:    state_d = ctr_q[0] ? STATE_DATA : STATE_IDLE;
  endcase

  // Accept signal can only be high if we're IDLE and the entire data buffer
  // is empty or we're just about to finish sending data.
  always_comb o_utx_acp = state_q == STATE_IDLE && ~|ctr_q;

  // We've accepted new data in this 4 GCK period.
  always_comb new_data = i_utx_vld && o_utx_acp;

  // Update the data buffer. We shift out 1b per cycle in DATA or push in 4b
  // per cycle when accepting new data.
  always_ff @(posedge i_utx_gck) begin
    if (new_data) begin
      data_q <= {i_utx_data, data_q[15:4]};
    end
    else if (state_q == STATE_DATA) begin
      data_q <= {1'bx, data_q[15:1]};
    end
  end

  // Transmit data is IDLE when in IDLE except for on the final cycle when we
  // have data to send at which point we set the START bit. In DATA the value
  // always comes from the buffer.
  always_comb unique case (state_q)
    STATE_IDLE: o_utx_data = &i_utx_ctr && state_d == STATE_DATA ? '0 : '1;
    default:    o_utx_data = data_q[0];
  endcase

  // Counter subtracts 1 on each 4b cycle when in the DATA state and is reset
  // to maximum value when accepting new data.
  always_ff @(posedge i_utx_gck, negedge i_utx_rst_n) begin
    if (!i_utx_rst_n) begin
      ctr_q <= ctr_t'('0);
    end
    else if (&i_utx_ctr) begin
      if (new_data) begin
        ctr_q <= ctr_t'('1);
      end
      else if (state_q == STATE_DATA && |ctr_q) begin
        ctr_q <= ctr_q - 2'b1;
      end
    end
  end

endmodule
