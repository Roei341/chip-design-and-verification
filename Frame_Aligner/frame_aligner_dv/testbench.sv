`include "interface.sv"
`include "test.sv" 

module top;
  bit clk = 0;
  bit reset = 1;
  always #5 clk = ~clk;

  // --- Test Selection ---
  // Change the value of TEST_NAME to select the desired test.
  // Options: "test_random", "test_alignment_sequence", "test_half_legal_header"
  localparam string TEST_NAME = "test_random"; 

  initial begin
    reset = 1;
    #15 reset = 0;
  end

  inf dut_inf(clk, reset);

  frame_aligner dut(
    .clk(dut_inf.clk),
    .reset(dut_inf.reset),
    .rx_data(dut_inf.rx_data),
    .fr_byte_position(dut_inf.fr_byte_position),
    .frame_detect(dut_inf.frame_detect)
  );

  initial begin
    $display("--- Starting Testbench: Running test '%s' ---", TEST_NAME);

    // Instantiate and run the selected test
    if (TEST_NAME == "test_random") begin
        test_random t1 = new(dut_inf);
        t1.run_test();
    end else if (TEST_NAME == "test_alignment_sequence") begin
        test_alignment_sequence t1 = new(dut_inf);
        t1.run_test();
    end else if (TEST_NAME == "test_half_legal_header") begin
        test_half_legal_header t1 = new(dut_inf);
        t1.run_test();
    end else begin
        $fatal(1, "ERROR: Invalid TEST_NAME specified in top.sv: %s", TEST_NAME);
    end
    
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule