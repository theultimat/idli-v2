`ifndef idli_pkg_svh
`define idli_pkg_svh

package idli_pkg;

// Core supports 4 input pins and 4 output pins for general use.
localparam int unsigned NUM_IO_PINS = 4;
typedef logic [NUM_IO_PINS-1:0] io_pins_t;

// We operate primarily on 4b slices of 16b chunks of data.
typedef logic   [3:0] slice_t;
typedef slice_t [3:0] data_t;

endpackage

`endif // idli_pkg_svh
