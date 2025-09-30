module memory_alu #(parameter ADDR_WIDTH = 2, parameter DATA_WIDTH = 8) (
  input logic clk, reset, enable, rd_wr,
  input logic [ADDR_WIDTH-1 : 0] addr,
  input logic [DATA_WIDTH-1 : 0] wr_data,
  output logic [DATA_WIDTH-1 : 0] rd_data,
  output logic [2*DATA_WIDTH-1 : 0] res_out
);
  /* Inner parameters */
  logic [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];
  logic [DATA_WIDTH-1 : 0] rd_data_temp;
  logic [DATA_WIDTH-1:0] A_DAT;
  logic [DATA_WIDTH-1:0] B_DAT;
  logic [2:0] oper;
  logic [2*DATA_WIDTH-1:0] res_out_temp;
  logic execute;

  always @(posedge clk, posedge reset)
    if (reset) begin
      for (int i=0; i<2**ADDR_WIDTH; i++)
        mem[i] <= 8'b0;
    end
  	
  	else if (enable && !rd_wr)
      mem[addr] <= wr_data;
  
  	else if (enable && rd_wr)
      rd_data_temp <= mem[addr];
  
  always @(posedge clk)		//delay of 1 clock cycle
    rd_data <= rd_data_temp;
  
  always @(*) begin
    A_DAT <= mem[0];
  	B_DAT <= mem[1];
    oper <= mem[2][2:0];
    execute <= mem[3][0];
  	if (oper == 0)
      res_out_temp <= 0;
  	else if (oper == 1)
      res_out_temp <= A_DAT + B_DAT;
  	else if (oper == 2)
      res_out_temp <= A_DAT - B_DAT;  	
  	else if (oper == 3)
      res_out_temp <= A_DAT * B_DAT;    
  	else if (oper == 4) begin
      if (B_DAT == 0)
        res_out_temp <= 16'hdead;
      else
        res_out_temp <= A_DAT / B_DAT;
    end
    else
      res_out_temp <= res_out;
  
  	if (execute == 8'b1)
      res_out <= res_out_temp;
  end //always
  
endmodule

            
