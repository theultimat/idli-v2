`include "idli_pkg.svh"


// Execution units and processor state.
module idli_ex_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic      i_ex_gck,
  input  var logic      i_ex_rst_n,

  // Sync counter and data from memory.
  input  var ctr_t      i_ex_ctr,
  input  var data_t     i_ex_enc,
  input  var logic      i_ex_enc_vld,
  input  var slice_t    i_ex_data,

  // Write interface to memory and whether or not this is redirect data or a
  // stall is required.
  output var logic      o_ex_redirect,
  output var slice_t    o_ex_data,
  output var logic      o_ex_stall,
  output var logic      o_ex_mem_wr,
  input  var logic      i_ex_mem_acp,

  // UART TX interface.
  output var slice_t    o_ex_utx_data,
  output var logic      o_ex_utx_vld,
  input  var logic      i_ex_utx_acp,

  // UART RX interface.
  input  var slice_t    i_ex_urx_data,
  input  var logic      i_ex_urx_vld,
  output var logic      o_ex_urx_acp,

  // IO pin interface.
  input  var io_pins_t  i_ex_io_pins,
  output var io_pins_t  o_ex_io_pins
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
  logic   lhs_data_reg_next;
  logic   lhs_data_reg_prev;
  slice_t rhs_data_reg;
  slice_t dst_data;

  // Saved carry flag.
  logic carry_q;

  // Predicate register for comparison results.
  logic pred_q;
  logic pred_d;
  logic pred_wr_en;

  // Decoded comparison operation.
  cmp_op_t cmp_op;

  // Conditional execution state and whether it is being written by an
  // instruction.
  cond_t  cond_q;
  cond_t  cond_wr_data;
  logic   cond_wr;
  logic   cond_op;

  // Current and next sequential PC value. Typically used for updating LR.
  slice_t pc;
  slice_t pc_next;
  logic   pc_inc;

  // Whether operation is first or last of a memory operation.
  logic mem_op;
  logic mem_op_last;
  logic mem_op_last_q;

  // When to redirect at end of a memory operation.
  logic mem_end_redirect;

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

  // Is this instruction PUTP?
  logic putp;

  // Pipe for instruction.
  pipe_t pipe;

  // Shift operation and result.
  shift_op_t shift_op;
  slice_t    shift_out;
  logic      shift_in_prev;
  logic      shift_c;

  // Count operation state and mode.
  count_op_t  count_op_q;
  count_op_t  count_op_raw;
  slice_t     count_raw;
  slice_t     count_q;
  logic       count_dec;
  logic       carry_set;
  logic       count_first_q;
  logic       carry_vld;

  // Input and output pins.
  io_pins_t   in_pins_q;
  io_pins_t   out_pins_q;
  logic [1:0] pin_idx;
  reg_t       pin_reg;
  pin_op_t    pin_op;
  logic       run_pin_op;
  slice_t     pin_data;


  // Decode instruction to get control signals. Note that we only flop an
  // encoding if the instruction actually exectued (or we didn't have one).
  idli_decode_m decode_u (
    .i_de_gck       (i_ex_gck),
    .i_de_rst_n     (i_ex_rst_n),

    .i_de_ctr       (i_ex_ctr),
    .i_de_enc       (enc),
    .i_de_enc_vld   (de_enc_vld),
    .i_de_pred      (pred_q),

    .o_de_pipe      (pipe),
    .o_de_alu_op    (alu_op),
    .o_de_alu_inv   (alu_inv),
    .o_de_alu_cin   (alu_cin_raw),
    .o_de_cmp_op    (cmp_op),
    .o_de_shift_op  (shift_op),
    .o_de_carry_vld (carry_vld),
    .o_de_putp      (putp),

    .o_de_dst       (dst),
    .o_de_dst_reg   (dst_reg_raw),
    .o_de_lhs       (lhs),
    .o_de_lhs_reg   (lhs_reg),
    .o_de_rhs       (rhs),
    .o_de_rhs_reg   (rhs_reg),
    .o_de_aux       (aux),

    .o_de_cond      (cond_wr_data),
    .o_de_cond_wr   (cond_wr),
    .o_de_cond_op   (cond_op),

    .o_de_mem_first (mem_first_raw),
    .o_de_mem_last  (mem_last_raw),
    .o_de_mem_op    (mem_op_raw),

    .o_de_count_op  (count_op_raw),
    .o_de_count     (count_raw),

    .o_de_pin_op    (pin_op),
    .o_de_pin_reg   (pin_reg),
    .o_de_pin_idx   (pin_idx)
  );

  // Register file.
  idli_rf_m rf_u (
    .i_rf_gck       (i_ex_gck),

    .i_rf_lhs       (run_pin_op ? pin_reg : lhs_reg),
    .o_rf_lhs_data  (lhs_data_reg),
    .o_rf_lhs_next  (lhs_data_reg_next),
    .o_rf_lhs_prev  (lhs_data_reg_prev),

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
    .i_pc_redirect  (o_ex_redirect && !mem_op && !mem_end_redirect),
    .i_pc_data      (alu_out),

    .o_pc           (pc),
    .o_pc_next      (pc_next)
  );

  // Shift unit.
  idli_shift_m shift_u (
    .i_shift_gck    (i_ex_gck),

    .i_shift_ctr    (i_ex_ctr),
    .i_shift_op     (shift_op),

    .i_shift_in       (lhs_data_reg),
    .i_shift_in_next  (lhs_data_reg_next),
    .i_shift_in_prev  (shift_in_prev),
    .o_shift_out      (shift_out),
    .o_shift_cout     (shift_c)
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
  // instruction or the saved value if we're mid-operation. If CARRY is active
  // then the saved value should continue to be passed forward. On the first
  // cycle of a CARRY we need to pass in the original value to ensure the
  // operation is correct (e.g. CIN must be set for first of a SUB).

  always_comb alu_cin = |i_ex_ctr || carry_set && !count_first_q ? carry_q
                                                                 : alu_cin_raw;

  // Save carry flag if CARRY is active, otherwise clear the carry on the
  // final cycle of an instruction.
  always_ff @(posedge i_ex_gck) begin
    if (&i_ex_ctr && (!carry_set || !carry_vld)) begin
      carry_q <= '0;
    end
    else if (run_instr && !skip_instr) begin
      if (pipe == PIPE_ALU) begin
        carry_q <= alu_c;
      end
      else if (pipe == PIPE_SHIFT && &i_ex_ctr) begin
        // Only update on final cycle for shifts so we can shift right through
        // the carry flag.
        carry_q <= shift_c;
      end
    end
  end

  // Predicate register is written on the final cycle of an instruction based
  // on the comparison operation performed.
  // TODO Write predicate from pin.
  always_comb begin
    pred_d = pred_q;

    // NEED TO SUPPORT PUTP!

    if (dst == DST_P && run_instr && !skip_instr) begin
      // PUTP needs special handling to take the bottom bit on the first
      // cycle.
      if (putp) begin
        pred_d = alu_out[0];
      end
      else begin
        // Value to write depends on the ALU flags and comparison operation that
        // was performed.
        unique case (cmp_op)
          CMP_OP_EQ:              pred_d = alu_z;
          CMP_OP_LT:              pred_d = alu_n != alu_v;
          CMP_OP_LTU:             pred_d = !alu_c;
          CMP_OP_GE:              pred_d = alu_n == alu_v;
          CMP_OP_GEU:             pred_d = alu_c;
          CMP_OP_INP:             pred_d = in_pins_q[pin_idx];
          default: /* NE, ANY */  pred_d = !alu_z;
        endcase
      end

      // Apply modifier from ANDP/ORP if required.
      if (count_q > '0) begin
        if (count_op_q == COUNT_OP_ANDP) begin
          pred_d &= pred_q;
        end
        else if (count_op_q == COUNT_OP_ORP) begin
          pred_d |= pred_q;
        end
      end
    end
  end

  // Write enable for predicate is final cycle of all P writing operations
  // except PUTP which must be written on the first cycle.
  always_comb begin
    pred_wr_en = dst == DST_P && run_instr && !skip_instr;

    case (1'b1)
      putp:     pred_wr_en &= ~|i_ex_ctr;
      default:  pred_wr_en &= &i_ex_ctr;
    endcase
  end

  // Flop new value of P on final cycle of instruction.
  always_ff @(posedge i_ex_gck) begin
    if (pred_wr_en) begin
      pred_q <= pred_d;
    end
  end

  // Update the conditional execution state. If this is written by an
  // instruction then on the final cycle write in the new value from the
  // encoding. If not, the value shifts right by one for each instruction.
  // Special care needs to be taken for memory operations as these span
  // multiple cycles.
  always_ff @(posedge i_ex_gck, negedge i_ex_rst_n) begin
    if (!i_ex_rst_n) begin
      cond_q <= cond_t'('0);
    end
    else if (&i_ex_ctr && run_instr) begin
      if (cond_wr && !skip_instr) begin
        cond_q <= cond_wr_data;
      end
      else if (mem_state_q != STATE_DATA) begin
        cond_q <= cond_t'({1'b0, cond_q[7:1]});
      end
    end
  end

  // Destination register comes from the encoding but may also be LR from the
  // auxiliary write operation. All COUNT operations are redirected to write
  // ZR as we don't care what the output was from ALU/SHIFT.
  always_comb begin
    dst_reg = aux == AUX_LR ? REG_LR : dst_reg_raw;

    if (pipe == PIPE_COUNT) begin
      dst_reg = REG_ZR;
    end
    else if (run_pin_op) begin
      dst_reg = pin_reg;
    end
  end

  // Write enable for destination register is based on whether we're actually
  // writing to a register and whether the instruction is actually being
  // executed.
  always_comb begin
    dst_reg_wr = (dst == DST_REG || aux == AUX_LR) && run_instr && !skip_instr;

    if (run_pin_op && pin_op == PIN_OP_IN) begin
      dst_reg_wr = '1;
    end
  end

  // Register write data depends on the pipe and auxiliary write status.
  always_comb dst_data = aux  == AUX_LR     ? pc_next   :
                         pipe == PIPE_SHIFT ? shift_out :
                         pipe == PIPE_IO    ? pin_data  : alu_out;

  // Instruction needs to stall if this is its first cycle but it reads from
  // SQI. In this case we need to wait for the data to be reversed in the SQI
  // block so we can read it out in 4b slices. We may also need to stall on
  // SQI for LD instructions while waiting for the redirect to take place or
  // ST until block is ready to accept data. Also make sure this is the ALU
  // pipe as no other instructions should be able to stall. COND is marked as
  // going down the ALU pipe but is a special case that should be ignored.
  always_comb begin
    stall_sqi = enc_new_q && (lhs == SRC_SQI || rhs == SRC_SQI)
                          && !cond_op
                          && pipe == PIPE_ALU;

    if (mem_state_q == STATE_DATA) begin
      stall_sqi = mem_op_q == MEM_OP_LD ? !enc_vld_q : !i_ex_mem_acp;
    end
  end

  // UART TX instructions can only run if the block is accepting and we have
  // all of our data.
  always_comb stall_utx = dst == DST_UART
                       && !i_ex_utx_acp
                       && !stall_sqi
                       && pipe == PIPE_ALU;

  // UART RX is similar to TX except we need to wait for there to be something
  // to read out of the RX buffer. We don't need to wait for SQI as it
  // shouldn't be active at the same time as URX.
  always_comb stall_urx = (lhs == SRC_UART || rhs == SRC_UART)
                       && !i_ex_urx_vld
                       && pipe == PIPE_ALU;

  // Redirect at end of memory operation happens on last of LD and cycle after
  // the last for ST.
  always_comb mem_end_redirect = mem_op_q == MEM_OP_LD ? mem_op_last
                                                       : mem_op_last_q;

  // Redirect is happening if this instruction is actually being executed and
  // it writes to the PC, is the address of a memory operation, or is
  // a redirect at the end of a memory operation.
  always_comb o_ex_redirect = run_instr
                           && !skip_instr
                           && (dst == DST_PC || mem_op || mem_end_redirect);

  // Data to write to the memory always comes from the ALU except for when we
  // don't have a valid instruction, in which case we output the PC. This
  // ensures the initial redirect at the start of time will start from address
  // zero. We also need to make sure the LD/ST address is taken from the
  // correct register and ST data is written.
  always_comb begin
    o_ex_data = pc;

    if (!mem_end_redirect) begin
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
    default:    mem_state_d = mem_end_redirect ? STATE_ADDR : STATE_DATA;
  endcase

  // Update start and end register for memory operations. This is taken from
  // the decoder when the memory operation starts, and is incremented on each
  // cycle for which valid data is processed.
  always_ff @(posedge i_ex_gck) begin
    if (~|i_ex_ctr && mem_op) begin
      mem_first_q <= mem_first_raw;
      mem_last_q  <= mem_last_raw;
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

  // Flop last state for redirect at end of store.
  always_ff @(posedge i_ex_gck) begin
    if (&i_ex_ctr) begin
      mem_op_last_q <= mem_op_last;
    end
  end

  // Increment PC when we have a valid instruction, we're not stalling, and
  // we're not part way through a memory operation.
  always_comb pc_inc = enc_vld_q
                    && !o_ex_stall
                    && mem_state_q != STATE_DATA;

  // Write enable is only set for store instructions.
  always_comb o_ex_mem_wr = mem_op_q == MEM_OP_ST && mem_state_q == STATE_DATA
                                                  && !mem_end_redirect;

  // Update the counter value. If this is a count operation then we should
  // store the new value in the register, otherwise we should decrement the
  // counter until it reaches zero when an instruction is run. This should
  // only apply to memory operations on their final cycles. Note that the
  // counter decreases even if the instruction is skipped due to predication.
  always_ff @(posedge i_ex_gck, negedge i_ex_rst_n) begin
    if (!i_ex_rst_n) begin
      count_q <= '0;
    end
    else if (&i_ex_ctr && run_instr) begin
      if (pipe == PIPE_COUNT && !skip_instr) count_q <= count_raw;
      else if (count_dec)                    count_q <= count_q - 4'b1;
    end
  end

  // Condition under which we should decrement the counter.
  always_comb count_dec = count_q > '0
                       && !mem_op
                       && (mem_state_q != STATE_DATA || mem_end_redirect);

  // Update count operation when we have a valid count instruction.
  always_ff @(posedge i_ex_gck) begin
    if (&i_ex_ctr && run_instr && !skip_instr && pipe == PIPE_COUNT) begin
      count_op_q <= count_op_raw;
    end
  end

  // Set when we want to chain the previous carry into the next instruction.
  always_comb carry_set = count_q > '0 && count_op_q == COUNT_OP_CARRY
                                       && carry_vld;

  // Shift input previous bit comes from the register unless CARRY is set in
  // which case we forward it on. Only valid on the final cycle as this only
  // applies to right shifts. Also note we need to make sure the correct bit
  // gets fed in for the non-CARRY cases, including the first cycle after the
  // carry has been set.
  always_comb begin
    shift_in_prev = lhs_data_reg_prev;

    if (shift_op != SHIFT_OP_ROL && &i_ex_ctr) begin
      shift_in_prev = shift_op == SHIFT_OP_SRL ? '0 : lhs_data_reg[3];

      if (!count_first_q && carry_set) begin
        shift_in_prev = carry_q;
      end
    end
  end

  // Remember if this is the first cycle for which a COUNT operation has been
  // set.
  always_ff @(posedge i_ex_gck) begin
    if (&i_ex_ctr && run_instr && !skip_instr) begin
      count_first_q <= pipe == PIPE_COUNT;
    end
  end

  // Always flop incoming pins on each cycle.
  always_ff @(posedge i_ex_gck) begin
    in_pins_q <= i_ex_io_pins;
  end

  // Run signal but exclusively for pins and accounting for skips.
  always_comb run_pin_op = run_instr && !skip_instr
                                     && pipe == PIPE_IO;

  // Pin data is to/from the pin on the first cycle and zero for all others.
  always_comb begin
    pin_data = '0;

    if (~|i_ex_ctr) begin
      unique case (pin_op)
        PIN_OP_IN:    pin_data = slice_t'(in_pins_q[pin_idx]);
        PIN_OP_OUT:   pin_data = slice_t'(lhs_data_reg[0]);
        PIN_OP_OUTN:  pin_data = slice_t'({3'b0, ~lhs_data_reg[0]});
        default:      pin_data = slice_t'(pred_q);
      endcase
    end
  end

  // Flop output pin value on the first cycle.
  always_ff @(posedge i_ex_gck) begin
    if (run_pin_op && ~|i_ex_ctr && pin_op != PIN_OP_IN) begin
      out_pins_q[pin_idx] <= pin_data[0];
    end
  end

  // Output current pin state.
  always_comb o_ex_io_pins = out_pins_q;

endmodule
