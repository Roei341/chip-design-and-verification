class transaction;
  rand bit rd_wr;
  rand bit [7:0] wr_data;
  rand bit [1:0] addr;
  bit [7:0] rd_data;
  bit [15:0] res_out;
  
  constraint oper_c {
    if (addr == 2'b10) 
      wr_data[2:0] dist {0 := 5, 1 := 20, 2 := 20, 3 := 20, 4 := 20}; 
  }
  
  constraint addr_c {
    addr dist { 0 := 30, 1 := 30, 2 := 30, 3 := 5 };
  }  
  
  constraint addr_execute {
    if (addr == 2'b11)
      wr_data[2:0] dist {0 := 5, 1 := 95};
  }   
  
  function void display(string name);
    $display("--------------------------------");
    $display("- %s", name);
    $display("rd_wr = %d, Wr_Data = %d, Addr = %d", rd_wr, wr_data, addr);
    $display("Rd_Data = %d, Res_Out=%d", rd_data, res_out);
    $display("--------------------------------");
  endfunction
endclass  