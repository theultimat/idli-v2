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

  // Write interface to memory and whether or not this is redirect data.
  output var logic    o_ex_redirect,
  output var slice_t  o_ex_data
);

  // Whether instruction is valid and new (i.e. first cycle).
  logic enc_vld_q;
  logic enc_new_q;

  // Whether instruction should actually be executed.
  logic run_instr;
  logic skip_instr;

  // Stall reasons for instruction, one per bit.
  logic [0:0] stall_instr;

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


  // Decode instruction to get control signals. Note that we only flop an
  // encoding if the instruction actually exectued (or we didn't have one).
  idli_decode_m decode_u (
    .i_de_gck       (i_ex_gck),
    .i_de_rst_n     (i_ex_rst_n),

    .i_de_ctr       (i_ex_ctr),
    .i_de_enc       (i_ex_enc),
    .i_de_enc_vld   (!enc_vld_q || run_instr),

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
    .o_de_cond_wr   (cond_wr)
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
    .i_pc_inc       (enc_vld_q),
    .i_pc_redirect  (o_ex_redirect),
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
      enc_new_q <= i_ex_enc_vld && (run_instr || !enc_vld_q);
    end
  end

  // Instruction should be run if we have something valid don't need to stall.
  always_comb run_instr = enc_vld_q && ~|stall_instr;

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
    SRC_PC:             lhs_data = pc_next;
    SRC_SQI:            lhs_data = i_ex_data;
    default: /* UART */ lhs_data = 'x;
  endcase

  always_comb unique case (rhs)
    SRC_REG:            rhs_data = rhs_data_reg;
    SRC_PC:             rhs_data = pc_next;
    SRC_SQI:            rhs_data = i_ex_data;
    default: /* UART */ rhs_data = 'x;
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
  // block so we can read it out in 4b slices.
  always_comb stall_instr[0] = enc_new_q && (lhs == SRC_SQI || rhs == SRC_SQI);

  // Redirect is happening if this instruction is actually being executed and
  // it wrtes to the PC.
  always_comb o_ex_redirect = run_instr && !skip_instr && dst == DST_PC;

  // Data to write to the memory always comes from the ALU except for when we
  // don't have a valid instruction, in which case we output the PC. This
  // ensures the initial redirect at the start of time will start from address
  // zero.
  always_comb o_ex_data = enc_vld_q ? alu_out : pc;

endmodule
