// Wrapper for the top module for debug.
module idli_tb_m();

  // Clock and reset signals.
  logic gck;
  logic rst_n;

  // TODO Add real signals, for now just have a simple toggle to check
  // waveforms are working properly.
  logic toggle_q;

  always_ff @(posedge gck, negedge rst_n) begin
    if (!rst_n) toggle_q <= '0;
    else toggle_q <= ~toggle_q;
  end

endmodule
