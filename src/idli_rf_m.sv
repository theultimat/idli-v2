`include "idli_pkg.svh"


// Register file. Extremely simple implementation, could be improved by
// switching to a latch based design.
module idli_rf_m import idli_pkg::*; (
  // Clock - no reset.
  input  var logic    i_rf_gck,

  // LHS and RHS read ports. We get access to a 4b slice and the bit below and
  // above the current slice (for shifts).
  input  var reg_t    i_rf_lhs,
  output var slice_t  o_rf_lhs_data,
  output var logic    o_rf_lhs_next,
  output var logic    o_rf_lhs_prev,
  input  var reg_t    i_rf_rhs,
  output var slice_t  o_rf_rhs_data,
  output var logic    o_rf_rhs_next,
  output var logic    o_rf_rhs_prev,

  // Write slice of data into destination register.
  input  var reg_t    i_rf_dst,
  input  var logic    i_rf_dst_en,
  input  var slice_t  i_rf_dst_data
);

  // Storage for registers. R0/ZR is always zero so no need to back it.
  data_t regs_q [NUM_REGS-1:1];

  // One-hot write enable signal for each register.
  logic [NUM_REGS-1:1] wr_en;


  for (genvar REG = 1; REG < NUM_REGS; REG++) begin : num_reg_b
    // Write enable should be set only for the active register.
    always_comb wr_en[REG] = i_rf_dst_en && i_rf_dst == reg_t'(REG);

    // Write incoming data/rotate existing data.
    always_ff @(posedge i_rf_gck) begin
      if (wr_en[REG]) begin
        regs_q[REG] <= {i_rf_dst_data, regs_q[REG][3:1]};
      end
      else begin
        regs_q[REG] <= {regs_q[REG][0], regs_q[REG][3:1]};
      end
    end


    // Set LHS output data.
    always_comb begin
      o_rf_lhs_data = slice_t'('0);
      o_rf_lhs_next = '0;
      o_rf_lhs_prev = '0;

      for (int unsigned REG = 1; REG < NUM_REGS; REG++) begin
        if (i_rf_lhs == reg_t'(REG)) begin
          o_rf_lhs_data = regs_q[REG][0];
          o_rf_lhs_next = regs_q[REG][1][0];
          o_rf_lhs_prev = regs_q[REG][3][3];
        end
      end
    end

    // Set RHS output data.
    always_comb begin
      o_rf_rhs_data = slice_t'('0);
      o_rf_rhs_next = '0;
      o_rf_rhs_prev = '0;

      for (int unsigned REG = 1; REG < NUM_REGS; REG++) begin
        if (i_rf_rhs == reg_t'(REG)) begin
          o_rf_rhs_data = regs_q[REG][0];
          o_rf_rhs_next = regs_q[REG][1][0];
          o_rf_rhs_prev = regs_q[REG][3][3];
        end
      end
    end
  end : num_reg_b

endmodule
