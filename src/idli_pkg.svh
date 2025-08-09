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
localparam int unsigned NUM_REGS = 16;
typedef logic [3:0] reg_t;

// Link register, zero register.
localparam reg_t REG_ZR = reg_t'('d0);
localparam reg_t REG_LR = reg_t'('d14);
localparam reg_t REG_SP = reg_t'('d15);

// Conditional execution state. Each bit indicates validity or whether an
// instruction should be executed based on the value of P or its inverse.
typedef logic [7:0] cond_t;

// Whether to take the final result from the ALU, shifter, IO pins, or
// counter state.
typedef enum logic [1:0] {
  PIPE_ALU,
  PIPE_SHIFT,
  PIPE_IO,
  PIPE_COUNT
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
  CMP_OP_ANY,
  CMP_OP_INP
} cmp_op_t;

// Possible destinations for operation output.
typedef enum logic [1:0] {
  DST_REG,
  DST_PC,
  DST_UART,
  DST_P
} dst_t;

// Possible source operand locations.
typedef enum logic [1:0] {
  SRC_REG,
  SRC_PC,
  SRC_SQI,
  SRC_UART
} src_t;

// Extra write destination, used by instructions to redirect SQI while also
// writing a register and updating LR.
typedef enum logic [1:0] {
  AUX_NONE,
  AUX_LR,
  AUX_SQI_DST,
  AUX_SQI_LHS
} aux_t;

// Type of memory operation.
typedef enum logic {
  MEM_OP_LD,
  MEM_OP_ST
} mem_op_t;

// Counter operations.
typedef enum logic [1:0] {
  COUNT_OP_CARRY,
  COUNT_OP_ANDP,
  COUNT_OP_ORP
} count_op_t;

// Pin operation.
typedef enum logic [1:0] {
  PIN_OP_IN,
  PIN_OP_OUT,
  PIN_OP_OUTN,
  PIN_OP_OUTP
} pin_op_t;

endpackage

`endif // idli_pkg_svh
