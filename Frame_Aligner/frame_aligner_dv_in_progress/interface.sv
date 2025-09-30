interface inf (input logic clk, reset);
   logic  [7:0] rx_data;
   logic  [3:0]  fr_byte_position; 
   logic frame_detect;
  
  modport DUT(input clk, rx_data, reset, output fr_byte_position, frame_detect);
endinterface