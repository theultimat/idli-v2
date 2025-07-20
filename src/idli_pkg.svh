`ifndef idli_pkg_svh
`define idli_pkg_svh

package idli_pkg;

// Core supports 4 input pins and 4 output pins for general use.
localparam int unsigned NUM_IO_PINS = 4;
typedef logic [NUM_IO_PINS-1:0] io_pins_t;

// We operate primarily on 4b slices of 16b chunks of data.
typedef logic   [3:0] slice_t;
typedef slice_t [3:0] data_t;

// Each instruction takes four cycles so we need a 2b counter.
typedef logic [1:0] ctr_t;

// 16 registers so 4b identifier.
typedef logic [3:0] reg_t;

//// Link register, zero register.
//localparam reg_t REG_ZR = reg_t'('d0);
////localparam reg_t REG_LR = reg_t'('d14);

// Whether to take the final result from the ALU or shift block.
typedef enum logic {
  PIPE_ALU,
  PIPE_SHIFT
} pipe_t;

// Operations supported by the ALU.
typedef enum logic [1:0] {
  ALU_OP_ADD,
  ALU_OP_AND,
  ALU_OP_OR,
  ALU_OP_XOR
} alu_op_t;

// Shift operations.
typedef enum logic [1:0] {
  SHIFT_OP_ROR,
  SHIFT_OP_ROL,
  SHIFT_OP_SRL,
  SHIFT_OP_SRA
} shift_op_t;

// Comparison operations.
typedef enum logic [2:0] {
  CMP_OP_EQ,
  CMP_OP_NE,
  CMP_OP_LT,
  CMP_OP_LTU,
  CMP_OP_GE,
  CMP_OP_GEU,
  CMP_OP_ANY
} cmp_op_t;

//
//// Possible destinations for operation output, excluding predicate write.
//typedef enum logic [1:0] {
//  DST_REG,
//  DST_PC,
//  DST_UART,
//  DST_P
//} dst_t;
//
//// Possible source operand locations.
//typedef enum logic [1:0] {
//  SRC_REG,
//  SRC_PC,
//  SRC_SQI,
//  SRC_UART
//} src_t;
//
//// Extra write destination, used by instructions to redirect SQI while also
//// writing a register and updating LR.
//typedef enum [1:0] {
//  AUX_WR_NONE,
//  AUX_WR_LR,
//  AUX_WR_SQI_DST,
//  AUX_WR_SQI_LHS
//} aux_wr_t;

//// Operation control signals for execution. Note that some instructions are
//// essentially executed in the decode stage and as such don't need any control
//// signals in this structure.
//typedef struct packed {
//  // Pipe selection, ALU or shift.
//  pipe_t pipe;
//
//  // Destination and source locations.
//  dst_t dst;
//  src_t lhs;
//  src_t rhs;
//
//  // Register operand values.
//  reg_t dst_reg;
//  reg_t lhs_reg;
//  reg_t rhs_reg;
//
//  // ALU and comparison controls.
//  alu_op_t  alu_op;
//  logic     alu_rhs_inv;
//  cmp_op_t  cmp_op;
//  logic     cmp_sign;
//  aux_wr_t  aux_wr;
//
//  // Shift control signals.
//  shift_op_t shift_op;
//} op_t;

endpackage

`endif // idli_pkg_svh
