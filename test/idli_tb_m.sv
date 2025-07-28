`include "idli_pkg.svh"


// Wrapper for the top module for debug. Note that many of the signals are
// driven by the python script so we need to tell the linter to not complain
// for a number of signals.
module idli_tb_m import idli_pkg::*; ();

  // verilator lint_off UNDRIVEN
  // verilator lint_off UNUSEDSIGNAL

  // Clock and reset signals.
  logic gck;
  logic rst_n;

  // Signals connected to the low and high SQI memories.
  logic   mem_lo_sck;
  logic   mem_hi_sck;
  logic   mem_lo_cs;
  logic   mem_hi_cs;
  slice_t mem_lo_out;
  slice_t mem_hi_out;
  slice_t mem_lo_in;
  slice_t mem_hi_in;

  // UART signals.
  logic uart_rx;
  logic uart_tx;

  // IO pins.
  io_pins_t pins_in;
  io_pins_t pins_out;

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

  // PC of the most recent instruction.
  data_t pc;

  // Core is ready for a new 16b UART transaction to be received.
  logic uart_rx_rdy;

  // verilator lint_on UNDRIVEN
  // verilator lint_on UNUSEDSIGNAL


  // Instantiate the top-level module of the core and connect to the bench.
  idli_top_m top_u (
    .i_top_gck        (gck),
    .i_top_rst_n      (rst_n),

    .o_top_mem_lo_sck (mem_lo_sck),
    .o_top_mem_lo_cs  (mem_lo_cs),
    .i_top_mem_lo_sio (mem_lo_in),
    .o_top_mem_lo_sio (mem_lo_out),

    .o_top_mem_hi_sck (mem_hi_sck),
    .o_top_mem_hi_cs  (mem_hi_cs),
    .i_top_mem_hi_sio (mem_hi_in),
    .o_top_mem_hi_sio (mem_hi_out),

    .i_top_uart_rx    (uart_rx),
    .o_top_uart_tx    (uart_tx),

    .i_top_io_pins    (pins_in),
    .o_top_io_pins    (pins_out)
  );


  // Grab sync counter from inside the core.
  always_comb ctr = top_u.ctr_q;

  // Instruction has just finished if we're at the end of a 4 GCK period and
  // run_instr was set in the execution wrapper.
  always_comb instr_done_d = &ctr && top_u.ex_u.run_instr;

  // Flop and reset required values.
  always_ff @(posedge gck, negedge rst_n) begin
    if (!rst_n) begin
      instr_done_q <= '0;
      reg_sb       <= '0;
      pred_sb      <= '0;
      pc           <= '0;
    end
    else begin
      instr_done_q <= instr_done_d;

      // On the first cycle of an instruction that's being run record whether
      // a register was written.
      if (ctr == '0 && top_u.ex_u.dst_reg_wr) begin
        reg_sb[top_u.ex_u.dst_reg] <= '1;
      end

      // As above for predicate register.
      if (ctr == '0 && top_u.ex_u.run_instr && top_u.ex_u.dst == DST_P) begin
        pred_sb <= !top_u.ex_u.skip_instr;
      end

      // PC should be saved when instruction is new in EX.
      if (ctr == '0 && top_u.ex_u.enc_vld_q && top_u.ex_u.enc_new_q) begin
        pc <= top_u.ex_u.pc_u.pc_q;
      end
    end
  end

  // Read out register state for use when checking instructions.
  always_comb begin
    for (int unsigned REG = 1; REG < NUM_REGS; REG++) begin
      reg_data[REG] = top_u.ex_u.rf_u.regs_q[REG];
    end
  end

  // Predicate register state.
  always_comb pred = top_u.ex_u.pred_q;

  // TODO Set this high when stalled on URX instruction.
  always_comb uart_rx_rdy = '0;

endmodule
