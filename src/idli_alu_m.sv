`include "idli_pkg.svh"


// ALU that operates on a single 4b slice per cycle. Outputs the 4b result and
// ZNCV flags for comparison operations.
module idli_alu_m import idli_pkg::*; (
  // Clock -- no reset.
  input  var logic      i_alu_gck,

  // Control signals.
  input  var ctr_t      i_alu_ctr,
  input  var alu_op_t   i_alu_op,
  input  var logic      i_alu_inv,
  input  var logic      i_alu_cin,

  // Input/output data.
  input  var slice_t    i_alu_lhs,
  input  var slice_t    i_alu_rhs,
  output var slice_t    o_alu_out,

  // Flags, only valid for sampling on the final cycle of an instruction.
  output var logic      o_alu_flag_z,
  output var logic      o_alu_flag_n,
  output var logic      o_alu_flag_c,
  output var logic      o_alu_flag_v
);

  // Need to preserve state for the zero flag as all slice outputs must be
  // checked for zero.
  logic flag_z_q;

  // Slice output for each of the possible ALU operations.
  slice_t add_out;
  slice_t and_out;
  slice_t or_out;
  slice_t xor_out;

  // RHS operand after applying input modifier for inverting.
  slice_t alu_rhs;

  // Carry-in for the sign bit of the ADD, used to check for overflow.
  logic cin_sign;


  // Save zero flag value, resetting for first cycle of an instruction.
  always_ff @(posedge i_alu_gck) begin
    if (&i_alu_ctr) begin
      flag_z_q <= '1;
    end
    else begin
      flag_z_q <= o_alu_flag_z;
    end
  end

  // Invert RHS if required.
  always_comb alu_rhs = i_alu_inv ? ~i_alu_rhs : i_alu_rhs;

  // Compute the bitwise operations.
  always_comb and_out = i_alu_lhs & alu_rhs;
  always_comb xor_out = i_alu_lhs ^ alu_rhs;
  always_comb or_out  = i_alu_lhs | alu_rhs;

  // Compute ADD from XOR and AND, saving the carry in to the sign bit for
  // determining the signed overflow flag. Carry flag is also set accordingly.
  always_comb begin
    logic cin;

    cin = i_alu_cin;
    cin_sign = 'x;

    for (int unsigned BIT = 0; BIT < 4; BIT++) begin
      if (BIT == 3) begin
        cin_sign = cin;
      end

      add_out[BIT] = xor_out[BIT] ^ cin;
      cin = (xor_out[BIT] & cin) | and_out[BIT];
    end

    o_alu_flag_c = cin;
  end

  // Output result based on operation.
  always_comb unique case (i_alu_op)
    ALU_OP_ADD: o_alu_out = add_out;
    ALU_OP_AND: o_alu_out = and_out;
    ALU_OP_OR:  o_alu_out = or_out;
    default:    o_alu_out = xor_out;
  endcase

  // Zero flag is set if the current output is zero and all previous cycles
  // have also been zero.
  always_comb o_alu_flag_z = flag_z_q && ~|o_alu_out;

  // Negative is set if the sign bit is high.
  always_comb o_alu_flag_n = o_alu_out[3];

  // Signed oVerflow flag is set based on the carry in and carry out of the
  // sign bit having different values.
  always_comb o_alu_flag_v = cin_sign ^ o_alu_flag_c;

endmodule
