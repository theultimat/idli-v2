`include "idli_pkg.svh"


// Wrapper for the top module for debug. Note that many of the signals are
// driven by the python script so we need to tell the linter to not complain
// for a number of signals.
module idli_tb_m import idli_pkg::*; (
  // Clock and reset signals.
  input  var logic      i_tb_gck,
  input  var logic      i_tb_rst_n,

  // UART interface with ready signal for RX to avoid dropping data.
  input  var logic      i_tb_uart_rx,
  output var logic      o_tb_uart_rx_rdy,
  output var logic      o_tb_uart_tx,

  // IO pin interface and output.
  input  var io_pins_t  i_tb_pins,
  output var io_pins_t  o_tb_pins,

  // Low memory interface.
  output var logic      o_tb_mem_lo_sck,
  output var logic      o_tb_mem_lo_cs,
  input  var slice_t    i_tb_mem_lo_sio,
  output var slice_t    o_tb_mem_lo_sio,

  // High memory interface.
  output var logic      o_tb_mem_hi_sck,
  output var logic      o_tb_mem_hi_cs,
  input  var slice_t    i_tb_mem_hi_sio,
  output var slice_t    o_tb_mem_hi_sio
);

  // verilator lint_off UNDRIVEN
  // verilator lint_off UNUSEDSIGNAL

  // Debug probes from inside the core to avoid internal references.
  debug_t debug;

  // Signals connected to the low and high SQI memories.
  logic   mem_lo_wr_en;
  logic   mem_hi_wr_en;
  slice_t mem_lo_out_top;
  slice_t mem_hi_out_top;
  slice_t mem_lo_in_top;
  slice_t mem_hi_in_top;

  // Internal sync counter.
  ctr_t ctr;

  // Whether an instruction has just finished.
  logic instr_done_q;
  logic instr_done_d;

  // Scoreboard of registers written. Set by the RTL and cleared by TB.
  logic [NUM_REGS-1:0] reg_sb;
  data_t reg_data [NUM_REGS-1:1];
  logic pred_sb;
  logic pred;
  io_pins_t pins_out_sb;

  // PC of the most recent instruction.
  data_t pc;

  // verilator lint_on UNDRIVEN
  // verilator lint_on UNUSEDSIGNAL


  // Instantiate the top-level module of the core and connect to the bench.
  idli_top_m top_u (
    .i_top_gck        (i_tb_gck),
    .i_top_rst_n      (i_tb_rst_n),

    .o_top_mem_lo_sck (o_tb_mem_lo_sck),
    .o_top_mem_lo_cs  (o_tb_mem_lo_cs),
    .i_top_mem_lo_sio (mem_lo_in_top),
    .o_top_mem_lo_sio (mem_lo_out_top),
    .o_top_mem_lo_en  (mem_lo_wr_en),

    .o_top_mem_hi_sck (o_tb_mem_hi_sck),
    .o_top_mem_hi_cs  (o_tb_mem_hi_cs),
    .i_top_mem_hi_sio (mem_hi_in_top),
    .o_top_mem_hi_sio (mem_hi_out_top),
    .o_top_mem_hi_en  (mem_hi_wr_en),

    .i_top_uart_rx    (i_tb_uart_rx),
    .o_top_uart_tx    (o_tb_uart_tx),

    .i_top_io_pins    (i_tb_pins),
    .o_top_io_pins    (o_tb_pins),

    .o_top_debug      (debug)
  );

  // Adjust signals visible to the bench based on the output enable for each
  // of the memories. When the output enable is set we forward on the output
  // pins and X out the inputs and vice versa.
  always_comb mem_lo_in_top = mem_lo_wr_en ? 'x : i_tb_mem_lo_sio;
  always_comb mem_hi_in_top = mem_hi_wr_en ? 'x : i_tb_mem_hi_sio;

  always_comb o_tb_mem_lo_sio = mem_lo_wr_en ? mem_lo_out_top : 'x;
  always_comb o_tb_mem_hi_sio = mem_hi_wr_en ? mem_hi_out_top : 'x;


  // Grab sync counter from inside the core.
  always_comb ctr = debug.ctr;

  // Instruction has just finished if we're at the end of a 4 GCK period and
  // run_instr was set in the execution wrapper. Special handling for memory
  // operations as these span multiple cycles.
  always_comb instr_done_d = &ctr && debug.ex.run_instr
                          && (~|debug.ex.mem_state || debug.ex.mem_end_redirect)
                          && !debug.ex.mem_op;

  // Flop and reset required values.
  always_ff @(posedge i_tb_gck, negedge i_tb_rst_n) begin
    if (!i_tb_rst_n) begin
      instr_done_q <= '0;
      reg_sb       <= '0;
      pred_sb      <= '0;
      pc           <= '0;
      pins_out_sb  <= '0;
    end
    else begin
      instr_done_q <= instr_done_d;

      // On the first cycle of an instruction that's being run record whether
      // a register was written.
      if (ctr == '0 && debug.ex.dst_reg_wr) begin
        reg_sb[debug.ex.dst_reg] <= '1;
      end

      // As above for predicate register.
      if (ctr == '0 && debug.ex.run_instr && debug.ex.dst == DST_P) begin
        pred_sb <= !debug.ex.skip_instr;
      end

      // As above for output pins.
      if (ctr == '0 && debug.ex.run_pin_op && debug.ex.pin_op != PIN_OP_IN) begin
        pins_out_sb[debug.ex.pin_idx] <= '1;
      end

      // PC should be saved when instruction is new in EX.
      if (ctr == '0 && debug.ex.enc_vld && debug.ex.enc_new) begin
        pc <= debug.ex.pc;
      end
    end
  end

  // Read out register state for use when checking instructions.
  always_comb begin
    for (int unsigned REG = 1; REG < NUM_REGS; REG++) begin
      reg_data[REG] = debug.ex.regs[REG];
    end
  end

  // Predicate register state.
  always_comb pred = debug.ex.pred;

  // Wait until EX is stalled waiting for UART data and we're not about to
  // have a full buffer to process.
  always_comb o_tb_uart_rx_rdy = debug.ex.stall_urx
                              && debug.urx.bits != 4'd15
                              && debug.ex.enc_vld;

endmodule
