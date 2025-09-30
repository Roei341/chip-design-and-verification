class driver;
  int num_transactions;
  virtual inf vinf;
  mailbox gen2drv;
  
  function new(virtual inf vinf, mailbox gen2drv);
    this.vinf = vinf;
    this.gen2drv = gen2drv;
  endfunction
  
  task reset;
    wait (vinf.reset);
    $display(" [---Driver---] ---reset started ---");
    vinf.enable <= 0;
    vinf.rd_wr <= 0;
    vinf.wr_data <= 0;
    wait (!vinf.reset);
    $display("[---driver---] ---reset ended ---");
  endtask
  
  task main();
    forever begin
      transaction trans;
      gen2drv.get(trans);
      @(posedge vinf.clk);
      vinf.enable <= 1;
      vinf.rd_wr <= trans.rd_wr;
      vinf.addr <= trans.addr;
      vinf.wr_data <= trans.wr_data;      
      @(posedge vinf.clk);
      //vinf.enable <= 0;
      trans.rd_data = vinf.rd_data;
      trans.res_out = vinf.res_out;
      @(posedge vinf.clk);
      trans.display("[---Driver---]");
      num_transactions++;
    end
  endtask
endclass