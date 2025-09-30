`include "interface.sv"
`include "test.sv"

module top;
  bit clk = 0;
  bit reset = 1;
  always #5 clk = ~clk;
  
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
    
  test t1;
  
  initial begin;
    t1 = new(dut_inf);
    t1.run_test();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
   
endmodule