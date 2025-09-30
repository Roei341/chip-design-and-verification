module counter (inf.DUT dut_inf);
  always @(posedge dut_inf.clk or negedge dut_inf.rst_n)
    if (! dut_inf.rst_n )
      dut_inf.count <= 0;
  	else if (dut_inf.load) 
      dut_inf.count <= dut_inf.data_in;
  	else if (dut_inf.enable && !dut_inf.load)
      dut_inf.count <= dut_inf.count + 1;
endmodule



interface inf (input logic clk, rst_n);
  logic enable;
  logic load;
  logic [7:0] data_in;
  logic [7:0] count;
  
  modport DUT (input clk, rst_n, enable, load, data_in, output count);
endinterface