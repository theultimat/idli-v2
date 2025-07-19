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
  input  var slice_t  i_sqi_data,
  output var slice_t  o_sqi_data,
  output var logic    o_sqi_data_vld,

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

  // Number of internal buffers. We only need to double buffer to pipeline
  // data going out to the core so only two buffers are required.
  localparam int unsigned NUM_LIFO = 2;

  // A transaction must go through the following stages.
  //
  //  1. CS = 1 to reset transaction state.
  //  2. CS = 0 to start a new transaction.
  //  3. Send 8b instruction (READ or WRITE) to memory.
  //  4. Send 16b address to memory.
  //  5. Wait for the dummy cycle if reading.
  //  6. Read/write the data from/to the memory 4b at a time.
  //
  // Core is running at twice the speed of the attached memories so each state
  // lasts for two GCK and a single SCK. Internally the core must stay in sync
  // for every four GCK i.e. two SCK, so states must be a multiple of two
  // (hence the two reset states). We make sure to transition between state on
  // the falling edge of SCK so the new data is available on the next rising
  // edge.
  typedef enum logic [3:0] {
    STATE_RESET_0,
    STATE_RESET_1,
    STATE_INSTR_0,
    STATE_INSTR_1,
    STATE_ADDR_0,
    STATE_ADDR_1,
    STATE_ADDR_2,
    STATE_ADDR_3,
    STATE_DUMMY_0,
    STATE_DUMMY_1,
    STATE_DATA_0,
    STATE_DATA_1
  } state_t;

  // READ and WRITE instructions as per the Microchip 23A512/23LC512
  // datasheet.
  typedef enum logic [7:0] {
    INSTR_RD = 8'h3,
    INSTR_WR = 8'h2
  } instr_t;

  // Current and next state.
  state_t state_q;
  state_t state_d;

  // Currently active LIFO for writing, so the opposite will be active for
  // reading, and whether its value should be toggled.
  logic wr_lifo_q;
  logic wr_lifo_swap;

  // Push/pop/input data signals for the LIFOs. These signals are shared but
  // gated by wr_lifo_q to ensure only one is active at a time.
  logic   lifo_push;
  logic   lifo_pop;
  slice_t lifo_in;

  // Data read out of each LIFO.
  slice_t [NUM_LIFO-1:0] lifo_out;

  // Slice sent to the high memory on the previous cycle.
  slice_t hi_sio_q;

  // Flop the next state on the *falling* edge of SCK so we can get the data
  // ready for the next rising edge.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      state_q <= STATE_RESET_0;
    end
    else if (o_sqi_hi_sck) begin
      state_q <= state_d;
    end
  end

  // Determine the next state. For the most part this is just moving into the
  // next sequentially and checking for a redirect.
  always_comb case (state_q)
    STATE_RESET_0:  state_d = STATE_RESET_1;
    STATE_RESET_1:  state_d = STATE_INSTR_0;
    STATE_INSTR_0:  state_d = STATE_INSTR_1;
    STATE_INSTR_1:  state_d = STATE_ADDR_0;
    STATE_ADDR_0:   state_d = STATE_ADDR_1;
    STATE_ADDR_1:   state_d = STATE_ADDR_2;
    STATE_ADDR_2:   state_d = STATE_ADDR_3;
    STATE_ADDR_3:   state_d = i_sqi_wr_en ? STATE_DATA_0 : STATE_DUMMY_0;
    STATE_DUMMY_0:  state_d = STATE_DUMMY_1;
    STATE_DUMMY_1:  state_d = STATE_DATA_0;
    STATE_DATA_0:   state_d = STATE_DATA_1;
    STATE_DATA_1:   state_d = i_sqi_redirect ? STATE_RESET_0 : STATE_DATA_0;
    default:        state_d = state_t'('x); // Unreachable
  endcase

  // SCK should be read out of the bottom bit of the counter flop to avoid any
  // clock glitches.
  always_comb o_sqi_hi_sck = i_sqi_ctr[0];

  // CS should be high in RESET but low at all other times.
  always_comb case (state_q)
    STATE_RESET_0, STATE_RESET_1: o_sqi_hi_cs = '1;
    default:                      o_sqi_hi_cs = '0;
  endcase

  // SCK and CS for the low memory are the value for the high memory from the
  // previous cycle.
  always_ff @(posedge i_sqi_gck) begin
    o_sqi_lo_sck  <= o_sqi_hi_sck;
    o_sqi_lo_cs   <= o_sqi_hi_cs;
  end

  for (genvar LIFO = 0; LIFO < NUM_LIFO; LIFO++) begin : num_lifo_b
    // Instantiate a new LIFO. Push/pop signals are gated based on whether
    // this LIFO is the one that's currently being written to.
    idli_lifo_m lifo_u (
      .i_lifo_gck   (i_sqi_gck),
      .i_lifo_rst_n (i_sqi_rst_n),

      .i_lifo_push  (LIFO == wr_lifo_q && lifo_push),
      .i_lifo_pop   (LIFO != wr_lifo_q && lifo_pop),
      .i_lifo_data  (lifo_in),
      .o_lifo_data  (lifo_out[LIFO])
    );
  end : num_lifo_b

  // Which LIFO is being written into only needs to change when we're starting
  // a new batch of data. This takes place on the final phase of each of the
  // states.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      wr_lifo_q <= '0;
    end
    else if (wr_lifo_swap && o_sqi_hi_sck) begin
      wr_lifo_q <= ~wr_lifo_q;
    end
  end

  // Detect final phases for each state to know when to swap - but only do so
  // when it's the falling edge of SCK to ensure we stay in sync with state_q.
  always_comb wr_lifo_swap = state_q == STATE_INSTR_1
                          || state_q == STATE_ADDR_3
                          || state_q == STATE_DATA_1;

  // Data is popped from the LIFO on the rising edge of GCK when in DATA mode
  // as we're sending different data to each of the memories, but only on the
  // falling edge of every SCK when in address mode as this needs to persist
  // for an entire SCK.
  always_comb case (state_q)
    STATE_ADDR_0,
    STATE_ADDR_1,
    STATE_ADDR_2,
    STATE_ADDR_3: lifo_pop = o_sqi_hi_sck;
    STATE_DATA_0,
    STATE_DATA_1: lifo_pop = '1;
    default:      lifo_pop = '0;
  endcase

  // Data is pushed into LIFO on every cycle when in the DATA or INSTR or ADDR
  // states./ We need to push the address while INSTR is being written by the
  // core so the value can be read out in big-endian afterwards. This also
  // applies to ADDR where we write the store data while the first two address
  // nibbles are being transferred.
  always_comb case (state_q)
    STATE_INSTR_0,
    STATE_INSTR_1,
    STATE_ADDR_0,
    STATE_ADDR_1,
    STATE_DATA_0,
    STATE_DATA_1: lifo_push = '1;
    default:      lifo_push = '0;
  endcase

  // Data to be pushed into the FIFO comes from the core during INSTR and ADDR,
  // as the value is either a redirect address or store data, and from the
  // memory for DATA as the new values are incoming.
  always_comb case (state_q)
    STATE_INSTR_0,
    STATE_INSTR_1,
    STATE_ADDR_0,
    STATE_ADDR_1: lifo_in = i_sqi_data;
    STATE_DATA_0: lifo_in = i_sqi_hi_sio;
    default:      lifo_in = i_sqi_lo_sio;
  endcase

  // Save the previous value written to the high memory for forwarding to the
  // low memory in some scenarios.
  always_ff @(posedge i_sqi_gck) begin
    hi_sio_q <= o_sqi_hi_sio;
  end

  // Control data output for the high memory. Instruction is hardcoded while
  // address and data come out of the LIFOs.
  always_comb case (state_q)
    STATE_INSTR_0:  o_sqi_hi_sio = i_sqi_wr_en ? INSTR_WR[7:4] : INSTR_RD[7:4];
    STATE_INSTR_1:  o_sqi_hi_sio = i_sqi_wr_en ? INSTR_WR[3:0] : INSTR_RD[3:0];
    default:        o_sqi_hi_sio = lifo_out[~wr_lifo_q];
  endcase

  // For the low memory we send out the value sent to the high memory on the
  // previous cycle except when sending out data as the nibbles are different.
  always_comb case (state_q)
    STATE_DATA_0, STATE_DATA_1: o_sqi_lo_sio = lifo_out[~wr_lifo_q];
    default:                    o_sqi_lo_sio = hi_sio_q;
  endcase

  // Data output to the rest of the core always comes from the top of the LIFO
  // that isn't currently being written to.
  always_comb o_sqi_data = lifo_out[~wr_lifo_q];

  // Output data is valid once we've been in DATA_1 at least once as this
  // means we've received 16b and it will be presented to the core over the
  // next 4 GCK. Once we redirect back to reset the value is cleared.
  always_ff @(posedge i_sqi_gck, negedge i_sqi_rst_n) begin
    if (!i_sqi_rst_n) begin
      o_sqi_data_vld <= '0;
    end
    else if (state_q == STATE_DATA_1 && o_sqi_hi_sck) begin
      o_sqi_data_vld <= !i_sqi_redirect;
    end
  end

endmodule
