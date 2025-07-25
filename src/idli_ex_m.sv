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

  // Decode instruction to get control signals.
  idli_decode_m decode_u (
    .i_de_gck       (i_ex_gck),
    .i_de_rst_n     (i_ex_rst_n),

    .i_de_ctr       (i_ex_ctr),
    .i_de_enc       (i_ex_enc),
    .i_de_enc_vld   (i_ex_enc_vld),

    // verilator lint_off PINCONNECTEMPTY
    .o_de_pipe      (),
    .o_de_alu_op    (),
    .o_de_alu_inv   (),
    .o_de_alu_cin   (),
    .o_de_cmp_op    (),
    .o_de_shift_op  (),

    .o_de_dst       (),
    .o_de_dst_reg   (),
    .o_de_lhs       (),
    .o_de_lhs_reg   (),
    .o_de_rhs       (),
    .o_de_rhs_reg   (),
    .o_de_aux       ()
    // verilator lint_on PINCONNECTEMPTY
  );

endmodule
