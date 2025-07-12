`ifndef idli_pkg_svh
`define idli_pkg_svh

package idli_pkg;

// We operate primarily on 4b slices of 16b chunks of data.
typedef logic   [3:0] slice_t;
typedef slice_t [3:0] data_t;

endpackage

`endif // idli_pkg_svh
