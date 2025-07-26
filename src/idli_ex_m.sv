`include "idli_pkg.svh"


// Execution units and processor state.
module idli_ex_m import idli_pkg::*; (
  // Clock and reset.
  input  var logic    i_ex_gck,
  input  var logic    i_ex_rst_n,

  // Sync counter and encodings from memory.
  input  var ctr_t    i_ex_ctr,
  input  var data_t   i_ex_enc,
  input  var logic    i_ex_enc_vld
);

  // Whether instruction is valid.
  logic enc_vld_q;

  // Whether instruction should actually be executed.
  logic run_instr;
  logic skip_instr;

  // Decoded operand information.
  dst_t dst;
  reg_t dst_reg;
  reg_t lhs_reg;
  reg_t rhs_reg;

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

  // LHS and RHS operand data.
  slice_t lhs_data;
  slice_t rhs_data;
  slice_t lhs_data_reg;
  slice_t rhs_data_reg;

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


  // Decode instruction to get control signals.
  idli_decode_m decode_u (
    .i_de_gck       (i_ex_gck),
    .i_de_rst_n     (i_ex_rst_n),

    .i_de_ctr       (i_ex_ctr),
    .i_de_enc       (i_ex_enc),

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
    .o_de_dst_reg   (dst_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_de_lhs       (),
    // verilator lint_on PINCONNECTEMPTY
    .o_de_lhs_reg   (lhs_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_de_rhs       (),
    // verilator lint_on PINCONNECTEMPTY
    .o_de_rhs_reg   (rhs_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_de_aux       (),
    // verilator lint_on PINCONNECTEMPTY

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
    .i_rf_dst_en    (dst == DST_REG && run_instr && !skip_instr),
    .i_rf_dst_data  (alu_out)
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


  // Flop the encoding valid signal.
  always_ff @(posedge i_ex_gck, negedge i_ex_rst_n) begin
    if (!i_ex_rst_n) begin
      enc_vld_q <= '0;
    end
    else if (&i_ex_ctr) begin
      enc_vld_q <= i_ex_enc_vld;
    end
  end

  // Instruction should be run if we have something valid.
  // TODO Account for stall signals etc.
  always_comb run_instr = enc_vld_q;

  // Instruction may be skipped based on the conditional execution state. The
  // state holds a run of bits indicating that an instruction should be run if
  // P is true (1) or if P is false (0). The state is only considered valid if
  // any bit other than LSB is high. Note that this is whether or not the
  // instruction should be skipped, hence the inverse of P.
  always_comb unique casez (cond_q)
    8'b000000?: skip_instr = '0;
    default:    skip_instr = cond_q[0] ? ~pred_q : pred_q;
  endcase

  // For now input data is always taken directly from RF.
  always_comb lhs_data = lhs_data_reg;
  always_comb rhs_data = rhs_data_reg;

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

endmodule
