interface inf #(parameter ADDR_WIDTH = 2, parameter DATA_WIDTH = 8) 
  (input logic clk, reset);
  logic enable;
  logic rd_wr;
  logic [ADDR_WIDTH-1 : 0] addr;
  logic [DATA_WIDTH-1 : 0] wr_data;
  logic [DATA_WIDTH-1 : 0] rd_data;
  logic [2*DATA_WIDTH-1 : 0] res_out;
  
  modport DUT(input clk, reset, enable, rd_wr, addr, wr_data, output rd_data, res_out);
endinterface