`include "idli_pkg.svh"


// Execution units and processor state.
module idli_ex_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic    i_ex_gck,
  input  var logic    i_ex_rst_n,

  // Sync counter and data from memory.
  input  var ctr_t    i_ex_ctr,
  input  var data_t   i_ex_enc,
  input  var logic    i_ex_enc_vld,
  input  var slice_t  i_ex_data,

  // Write interface to memory and whether or not this is redirect data or a
  // stall is required.
  output var logic    o_ex_redirect,
  output var slice_t  o_ex_data,
  output var logic    o_ex_stall,
  output var logic    o_ex_mem_wr,
  input  var logic    i_ex_mem_acp,

  // UART TX interface.
  output var slice_t  o_ex_utx_data,
  output var logic    o_ex_utx_vld,
  input  var logic    i_ex_utx_acp,

  // UART RX interface.
  input  var slice_t  i_ex_urx_data,
  input  var logic    i_ex_urx_vld,
  output var logic    o_ex_urx_acp
);

  // Memory operations occur over the course of multiple cycles, so we need
  // to track how far though the instruction we are. The general process is to
  //  1) Redirect the memories to the LD/ST address.
  //  2) For each data register, read/write data from/to memory.
  typedef enum logic {
    STATE_ADDR,
    STATE_DATA
  } state_t;

  // Encoding to feed into the decoder.
  data_t enc;
  logic  de_enc_vld;

  // Whether instruction is valid and new (i.e. first cycle).
  logic enc_vld_q;
  logic enc_new_q;

  // Whether instruction should actually be executed.
  logic run_instr;
  logic skip_instr;

  // Stall reasons for instruction.
  logic stall_sqi;
  logic stall_utx;
  logic stall_urx;

  // Decoded operand information.
  dst_t dst;
  reg_t dst_reg_raw;
  reg_t dst_reg;
  logic dst_reg_wr;
  reg_t lhs_reg;
  reg_t rhs_reg;
  aux_t aux;
  src_t lhs;
  src_t rhs;

  // ALU control and data signals.
  alu_op_t  alu_op;
  logic     alu_inv;
  logic     alu_cin_raw;
  logic     alu_cin;
  slice_t   alu_out;
  logic     alu_z;
  logic     alu_n;
  logic     alu_c;
  logic     alu_v;

  // LHS and RHS operand and destination data.
  slice_t lhs_data;
  slice_t rhs_data;
  slice_t lhs_data_reg;
  slice_t rhs_data_reg;
  slice_t dst_data;

  // Saved carry flag.
  logic carry_q;

  // Predicate register for comparison results.
  logic pred_q;
  logic pred_d;

  // Decoded comparison operation.
  cmp_op_t cmp_op;

  // Conditional execution state and whether it is being written by an
  // instruction.
  cond_t  cond_q;
  cond_t  cond_wr_data;
  logic   cond_wr;

  // Current and next sequential PC value. Typically used for updating LR.
  slice_t pc;
  slice_t pc_next;
  logic   pc_inc;

  // Whether operation is first or last of a memory operation.
  logic mem_op;
  logic mem_op_last;

  // State for the memory operation.
  state_t mem_state_q;
  state_t mem_state_d;

  // Current and final register for memory operations.
  reg_t mem_first_q;
  reg_t mem_first_raw;
  reg_t mem_last_q;
  reg_t mem_last_raw;
  reg_t mem_first_d;

  // Memory operation. Only valid when in progress.
  mem_op_t mem_op_raw;
  mem_op_t mem_op_q;


  // Decode instruction to get control signals. Note that we only flop an
  // encoding if the instruction actually exectued (or we didn't have one).
  idli_decode_m decode_u (
    .i_de_gck       (i_ex_gck),
    .i_de_rst_n     (i_ex_rst_n),

    .i_de_ctr       (i_ex_ctr),
    .i_de_enc       (enc),
    .i_de_enc_vld   (de_enc_vld),

    // verilator lint_off PINCONNECTEMPTY
    .o_de_pipe      (),
    // verilator lint_on PINCONNECTEMPTY
    .o_de_alu_op    (alu_op),
    .o_de_alu_inv   (alu_inv),
    .o_de_alu_cin   (alu_cin_raw),
    .o_de_cmp_op    (cmp_op),
    // verilator lint_off PINCONNECTEMPTY
    .o_de_shift_op  (),
    // verilator lint_on PINCONNECTEMPTY

    .o_de_dst       (dst),
    .o_de_dst_reg   (dst_reg_raw),
    .o_de_lhs       (lhs),
    .o_de_lhs_reg   (lhs_reg),
    .o_de_rhs       (rhs),
    .o_de_rhs_reg   (rhs_reg),
    .o_de_aux       (aux),

    .o_de_cond      (cond_wr_data),
    .o_de_cond_wr   (cond_wr),

    .o_de_mem_first (mem_first_raw),
    .o_de_mem_last  (mem_last_raw),
    .o_de_mem_op    (mem_op_raw)
  );

  // Register file.
  idli_rf_m rf_u (
    .i_rf_gck       (i_ex_gck),

    .i_rf_lhs       (lhs_reg),
    .o_rf_lhs_data  (lhs_data_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_rf_lhs_next  (),
    .o_rf_lhs_prev  (),
    // verilator lint_on PINCONNECTEMPTY

    .i_rf_rhs       (rhs_reg),
    .o_rf_rhs_data  (rhs_data_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_rf_rhs_next  (),
    .o_rf_rhs_prev  (),
    // verilator lint_on PINCONNECTEMPTY

    .i_rf_dst       (dst_reg),
    .i_rf_dst_en    (dst_reg_wr),
    .i_rf_dst_data  (dst_data)
  );

  // ALU.
  idli_alu_m alu_u (
    .i_alu_gck    (i_ex_gck),

    .i_alu_ctr    (i_ex_ctr),
    .i_alu_op     (alu_op),
    .i_alu_inv    (alu_inv),
    .i_alu_cin    (alu_cin),

    .i_alu_lhs    (lhs_data),
    .i_alu_rhs    (rhs_data),
    .o_alu_out    (alu_out),

    .o_alu_flag_z (alu_z),
    .o_alu_flag_n (alu_n),
    .o_alu_flag_c (alu_c),
    .o_alu_flag_v (alu_v)
  );

  // Program counter wrapper.
  idli_pc_m pc_u (
    .i_pc_gck       (i_ex_gck),
    .i_pc_rst_n     (i_ex_rst_n),

    .i_pc_ctr       (i_ex_ctr),
    .i_pc_inc       (pc_inc),
    .i_pc_redirect  (o_ex_redirect && !mem_op && !mem_op_last),
    .i_pc_data      (alu_out),

    .o_pc           (pc),
    .o_pc_next      (pc_next)
  );


  // Flop the encoding valid signal.
  always_ff @(posedge i_ex_gck, negedge i_ex_rst_n) begin
    if (!i_ex_rst_n) begin
      enc_vld_q <= '0;
    end
    else if (&i_ex_ctr) begin
      enc_vld_q <= i_ex_enc_vld && !o_ex_redirect;
    end
  end

  // Remember whether this is the first cycle of an instruction.
  always_ff @(posedge i_ex_gck) begin
    if (&i_ex_ctr) begin
      enc_new_q <= i_ex_enc_vld
                && (run_instr || !enc_vld_q)
                && mem_state_q != STATE_DATA;
    end
  end

  // Instruction should be run if we have something valid don't need to stall.
  // A valid instruction can come from the outside world or be generated as
  // part of a memory operation.
  always_comb run_instr = (enc_vld_q || mem_state_q == STATE_DATA)
                       && ~|{stall_sqi, stall_utx, stall_urx};

  // Instruction may be skipped based on the conditional execution state. The
  // state holds a run of bits indicating that an instruction should be run if
  // P is true (1) or if P is false (0). The state is only considered valid if
  // any bit other than LSB is high. Note that this is whether or not the
  // instruction should be skipped, hence the inverse of P.
  always_comb unique casez (cond_q)
    8'b000000?: skip_instr = '0;
    default:    skip_instr = cond_q[0] ? ~pred_q : pred_q;
  endcase

  // LHS/RHS data depends on the source value.
  // TODO Implement UART!
  always_comb unique case (lhs)
    SRC_REG:            lhs_data = lhs_data_reg;
    SRC_PC:             lhs_data = pc;
    SRC_SQI:            lhs_data = i_ex_data;
    default: /* UART */ lhs_data = i_ex_urx_data;
  endcase

  always_comb unique case (rhs)
    SRC_REG:            rhs_data = rhs_data_reg;
    SRC_PC:             rhs_data = pc;
    SRC_SQI:            rhs_data = i_ex_data;
    default: /* UART */ rhs_data = i_ex_urx_data;
  endcase

  // Carry in for ALU comes from the encoding on the first cycle of an
  // instruction or the saved value if we're mid-operation.
  // TODO Account for the CARRY instruction setting persistent flags!
  always_comb alu_cin = |i_ex_ctr ? carry_q : alu_cin_raw;

  // Save carry flag for the next slice of an operation.
  always_ff @(posedge i_ex_gck) begin
    carry_q <= alu_c;
  end

  // Predicate register is written on the final cycle of an instruction based
  // on the comparison operation performed.
  // TODO Write predicate from pin.
  always_comb begin
    pred_d = pred_q;

    if (dst == DST_P && run_instr && !skip_instr) begin
      // Value to write depends on the ALU flags and comparison operation that
      // was performed.
      unique case (cmp_op)
        CMP_OP_EQ:              pred_d = alu_z;
        CMP_OP_LT:              pred_d = alu_n != alu_v;
        CMP_OP_LTU:             pred_d = !alu_c;
        CMP_OP_GE:              pred_d = alu_n == alu_v;
        CMP_OP_GEU:             pred_d = alu_c;
        default: /* NE, ANY */  pred_d = !alu_z;
      endcase
    end
  end

  // Flop new value of P on final cycle of instruction.
  always_ff @(posedge i_ex_gck) begin
    if (&i_ex_ctr) begin
      pred_q <= pred_d;
    end
  end

  // Update the conditional execution state. If this is written by an
  // instruction then on the final cycle write in the new value from the
  // encoding. If not, the value shifts right by one for each instruction.
  always_ff @(posedge i_ex_gck, negedge i_ex_rst_n) begin
    if (!i_ex_rst_n) begin
      cond_q <= cond_t'('0);
    end
    else if (&i_ex_ctr && run_instr) begin
      cond_q <= cond_wr && !skip_instr ? cond_wr_data
                                       : cond_t'({1'b0, cond_q[7:1]});
    end
  end

  // Destination register comes from the encoding but may also be LR from the
  // auxiliary write operation.
  always_comb dst_reg = aux == AUX_LR ? REG_LR : dst_reg_raw;

  // Write enable for destination register is based on whether we're actually
  // writing to a register and whether the instruction is actually being
  // executed.
  always_comb dst_reg_wr = (dst == DST_REG || aux == AUX_LR)
                        && run_instr
                        && !skip_instr;

  // Register write data depends on the pipe and auxiliary write status.
  // TODO Implement other pipes! Assumes ALU for now.
  always_comb dst_data = aux == AUX_LR ? pc_next : alu_out;

  // Instruction needs to stall if this is its first cycle but it reads from
  // SQI. In this case we need to wait for the data to be reversed in the SQI
  // block so we can read it out in 4b slices. We may also need to stall on
  // SQI for LD instructions while waiting for the redirect to take place or
  // ST until block is ready to accept data.
  always_comb begin
    stall_sqi = enc_new_q && (lhs == SRC_SQI || rhs == SRC_SQI);

    if (mem_state_q == STATE_DATA) begin
      stall_sqi = mem_op_q == MEM_OP_LD ? !enc_vld_q : !i_ex_mem_acp;
    end
  end

  // UART TX instructions can only run if the block is accepting and we have
  // all of our data.
  always_comb stall_utx = dst == DST_UART && !i_ex_utx_acp && !stall_sqi;

  // UART RX is similar to TX except we need to wait for there to be something
  // to read out of the RX buffer. We don't need to wait for SQI as it
  // shouldn't be active at the same time as URX.
  always_comb stall_urx = (lhs == SRC_UART || rhs == SRC_UART) && !i_ex_urx_vld;

  // Redirect is happening if this instruction is actually being executed and
  // it writes to the PC, is the address of a memory operation, or is
  // a redirect at the end of a memory operation.
  always_comb o_ex_redirect = run_instr
                           && !skip_instr
                           && (dst == DST_PC || mem_op || mem_op_last);

  // Data to write to the memory always comes from the ALU except for when we
  // don't have a valid instruction, in which case we output the PC. This
  // ensures the initial redirect at the start of time will start from address
  // zero. We also need to make sure the LD/ST address is taken from the
  // correct register and ST data is written.
  always_comb begin
    o_ex_data = pc;

    if (!mem_op_last) begin
      if (enc_vld_q) begin
        o_ex_data = aux == AUX_SQI_LHS ? lhs_data_reg : alu_out;
      end
      else if (mem_state_q == STATE_DATA) begin
        o_ex_data = alu_out;
      end
    end
  end

  // UART TX data always comes from the ALU and is valid when we UART is the
  // destination.
  always_comb o_ex_utx_data = alu_out;
  always_comb o_ex_utx_vld  = dst == DST_UART
                           && enc_vld_q
                           && run_instr
                           && !skip_instr;

  // UART RX data can be accepted when we're waiting for UART data at we're
  // about to start on a new 4 GCK cycle.
  always_comb o_ex_urx_acp = enc_vld_q
                          && run_instr
                          && (lhs == SRC_UART || rhs == SRC_UART)
                          && !skip_instr;

  // We need to stall the memory if any of the stall reasons are set except
  // for we're waiting for SQI data if the instruction is valid.
  always_comb o_ex_stall = |{stall_utx, stall_urx} && enc_vld_q;

  // This is a memory operation if the auxiliary write is to SQI.
  always_comb mem_op = (aux == AUX_SQI_DST || aux == AUX_SQI_LHS)
                    && run_instr
                    && !skip_instr;

  // Update state for the memory operations.
  always_ff @(posedge i_ex_gck, negedge i_ex_rst_n) begin
    if (!i_ex_rst_n) begin
      mem_state_q <= STATE_ADDR;
    end
    else if (&i_ex_ctr) begin
      mem_state_q <= mem_state_d;
    end
  end

  // Determine next state for the memory operation.
  // TODO Currently only supports LD, need ST support!
  always_comb unique case (mem_state_q)
    STATE_ADDR: mem_state_d = mem_op ? STATE_DATA : mem_state_q;
    default:    mem_state_d = mem_op_last ? STATE_ADDR : STATE_DATA;
  endcase

  // Update start and end register for memory operations. This is taken from
  // the decoder when the memory operation starts, and is incremented on each
  // cycle for which valid data is processed.
  always_ff @(posedge i_ex_gck) begin
    if (~|i_ex_ctr && mem_op) begin
      mem_first_q <= mem_first_raw;
      mem_last_q  <= mem_last_raw + reg_t'(mem_op_raw == MEM_OP_ST);
      mem_op_q    <= mem_op_raw;
    end
    else if (&i_ex_ctr) begin
      mem_first_q <= mem_first_d;
    end
  end

  // Next register is incremented on the first cycle of valid memory data
  // unless it's the final register.
  always_comb begin
    mem_first_d = mem_first_q;

    if (mem_state_q == STATE_DATA && !mem_op_last) begin
      mem_first_d += mem_op_q == MEM_OP_LD ? reg_t'(enc_vld_q)
                                           : reg_t'(i_ex_mem_acp);
    end
  end

  // Data to feed into the decoder is typically the value read from memory
  // unless we're in the data section of a memory operation.
  always_comb begin
    enc = i_ex_enc;

    // LD -> ADD A, ZR, SQI
    // ST -> ADD ZR, A, ZR
    if (mem_op || mem_state_q == STATE_DATA) begin
      enc = mem_op_q == MEM_OP_LD ? '{REG_SP, REG_ZR, mem_first_d, 4'h0}
                                  : '{REG_ZR, mem_first_d, REG_ZR, 4'h0};
    end
  end

  // Want decode to flop new encoding if and of the following are true:
  //  1) We don't have a valid instruction.
  //  2) We're running an instruction.
  //  3) The next instruction is a memory data operation.
  always_comb de_enc_vld = !enc_vld_q
                        || run_instr
                        || mem_state_d == STATE_DATA;

  // Last cycle of memory operation when we've written the final register.
  // For ST this is the cycle *after* the final register so the PC can be
  // written after the final data.
  always_comb begin
    if (mem_op_q == MEM_OP_LD) begin
      mem_op_last = enc_vld_q && mem_first_q == mem_last_q
                              && mem_state_q == STATE_DATA;
    end
    else begin
      mem_op_last = i_ex_mem_acp && mem_first_q == mem_last_q
                                 && mem_state_q == STATE_DATA;
    end
  end

  // Increment PC when we have a valid instruction, we're not stalling, and
  // we're not part way through a memory operation.
  always_comb pc_inc = enc_vld_q
                    && !o_ex_stall
                    && mem_state_q != STATE_DATA;

  // Write enable is only set for store instructions.
  always_comb o_ex_mem_wr = mem_op_q == MEM_OP_ST && mem_state_q == STATE_DATA;

endmodule
