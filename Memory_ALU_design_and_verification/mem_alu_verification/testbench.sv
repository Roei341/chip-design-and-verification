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
  
  memory_alu dut(
    .clk(dut_inf.clk),
    .reset(dut_inf.reset),
    .enable(dut_inf.enable),
    .rd_wr(dut_inf.rd_wr),
    .addr(dut_inf.addr),
    .wr_data(dut_inf.wr_data),
    .rd_data(dut_inf.rd_data),
    .res_out(dut_inf.res_out)
  );
    
  //rd_wr_test t1;
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