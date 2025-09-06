`include "idli_pkg.svh"


// Simualtes a single 25LC512 SQI memory. Useful for testing on e.g. FPGA.
module idli_sqi_mem_m import idli_pkg::*; #(
  parameter string       PATH = "",
  parameter int unsigned SIZE = 64 * 1024
) (
  // SCK and CS.
  input  var logic    i_sqi_sck,
  input  var logic    i_sqi_cs,

  // SIO data.
  input  var slice_t  i_sqi_sio,
  output var slice_t  o_sqi_sio
);

  // Only support READ and WRITE modes.
  typedef enum logic [7:0] {
    INSTR_READ  = 8'h03,
    INSTR_WRITE = 8'h02
  } instr_t;

  // Memory cycles through various states as instruction, address, and data is
  // all provided in serial over SIO.
  typedef enum logic [3:0] {
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


  // Data is stored in 8b bytes.
  logic [7:0] data_q [0:SIZE-1];

  // Snapshot of the bottom part of the memory. Useful for debug.
  // verilator lint_off UNUSEDSIGNAL
  logic [7:0] data_sel;
  // verilator lint_on UNUSEDSIGNAL

  // Current and next state of the state machine.
  state_t state_q;
  state_t state_d;

  // Instruction being executed and address for memory access.
  instr_t       instr_q;
  logic [15:0]  addr_q;

  // Whether this is a write instruction.
  logic wr_en;


  // Flop new state of the FSM, resetting to start of new instruction when CS
  // is high.
  always_ff @(posedge i_sqi_sck) begin
    state_q <= i_sqi_cs ? STATE_INSTR_0 : state_d;
  end

  // Determine next state of the FSM. This is largely just cycling forward
  // through the states until we get to DATA and making sure to account for
  // the dummy byte when starting a new READ.
  always_comb unique case (state_q)
    STATE_INSTR_0:  state_d = STATE_INSTR_1;
    STATE_INSTR_1:  state_d = STATE_ADDR_0;
    STATE_ADDR_0:   state_d = STATE_ADDR_1;
    STATE_ADDR_1:   state_d = STATE_ADDR_2;
    STATE_ADDR_2:   state_d = STATE_ADDR_3;
    STATE_ADDR_3:   state_d = wr_en ? STATE_DATA_0 : STATE_DUMMY_0;
    STATE_DUMMY_0:  state_d = STATE_DUMMY_1;
    STATE_DUMMY_1:  state_d = STATE_DATA_0;
    STATE_DATA_0:   state_d = STATE_DATA_1;
    default:        state_d = STATE_DATA_0;
  endcase

  // Flop incoming instruction MSB first.
  always_ff @(posedge i_sqi_sck) begin
    if (state_q == STATE_INSTR_0 || state_q == STATE_INSTR_1) begin
      instr_q <= instr_t'({instr_q[3:0], i_sqi_sio});
    end
  end

  // Receive incoming address and increment for each 8b of data.
  always_ff @(posedge i_sqi_sck) unique case (state_q)
    STATE_ADDR_0,
    STATE_ADDR_1,
    STATE_ADDR_2,
    STATE_ADDR_3: addr_q <= {addr_q[11:0], i_sqi_sio};
    STATE_DATA_1: addr_q <= addr_q + 16'b1;
    default:      /* do nothing */;
  endcase

  // Output data from memory, high MSBs first, when in READ mode. Ouput junk in
  // DUMMY or when inactive.
  always_comb unique case (state_q)
    STATE_DUMMY_0,
    STATE_DUMMY_1:  o_sqi_sio = slice_t'('x);
    STATE_DATA_0:   o_sqi_sio = slice_t'(wr_en ? 'x : data_q[addr_q][7:4]);
    STATE_DATA_1:   o_sqi_sio = slice_t'(wr_en ? 'x : data_q[addr_q][3:0]);
    default:        o_sqi_sio = slice_t'('x);
  endcase

  // Enable writes based on instruction when not in reset.
  always_comb wr_en = instr_q == INSTR_WRITE && !i_sqi_cs;

  // Write new data into memory, high MSBs first.
  always_ff @(posedge i_sqi_sck) begin
    if (wr_en) begin
      if (state_q == STATE_DATA_0) begin
        data_q[addr_q][7:4] <= i_sqi_sio;
      end
      else if (state_q == STATE_DATA_1) begin
        data_q[addr_q][3:0] <= i_sqi_sio;
      end
    end
  end

  // Grab the low bytes for debug.
  always_comb data_sel = data_q[addr_q];

  // Load data from file.
  initial $readmemh(PATH, data_q);

endmodule
