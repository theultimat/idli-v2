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

  // Decoded operand information.
  dst_t dst;
  reg_t dst_reg;
  reg_t lhs_reg;
  reg_t rhs_reg;


  // Decode instruction to get control signals.
  idli_decode_m decode_u (
    .i_de_gck       (i_ex_gck),
    .i_de_rst_n     (i_ex_rst_n),

    .i_de_ctr       (i_ex_ctr),
    .i_de_enc       (i_ex_enc),

    // verilator lint_off PINCONNECTEMPTY
    .o_de_pipe      (),
    .o_de_alu_op    (),
    .o_de_alu_inv   (),
    .o_de_alu_cin   (),
    .o_de_cmp_op    (),
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
    .o_de_aux       ()
    // verilator lint_on PINCONNECTEMPTY
  );

  // Register file.
  idli_rf_m rf_u (
    .i_rf_gck       (i_ex_gck),

    .i_rf_lhs       (lhs_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_rf_lhs_data  (),
    .o_rf_lhs_next  (),
    .o_rf_lhs_prev  (),
    // verilator lint_on PINCONNECTEMPTY

    .i_rf_rhs       (rhs_reg),
    // verilator lint_off PINCONNECTEMPTY
    .o_rf_rhs_data  (),
    .o_rf_rhs_next  (),
    .o_rf_rhs_prev  (),
    // verilator lint_on PINCONNECTEMPTY

    .i_rf_dst       (dst_reg),
    .i_rf_dst_en    (dst == DST_REG && run_instr),
    .i_rf_dst_data  ('x)
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

endmodule
