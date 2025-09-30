class monitor_in;
  virtual inf vinf;
  mailbox mon2scb_in;

  bit [1:0] addr;
  bit [7:0] wr_data;

  covergroup cg_in;
    option.per_instance = 1;

    coverpoint addr iff (vinf.enable) {
      bins A     = {0};
      bins B     = {1};
      bins OP    = {2};
      bins EXEC  = {3};
    }

    cp_opcode : coverpoint wr_data[2:0] iff (addr == 2) {
      bins nop  = {0};
      bins add  = {1};
      bins sub  = {2};
      bins mul  = {3};
      bins div  = {4};
    }
    
    coverpoint wr_data iff (addr == 3) {
      bins exe0 = {0};
      bins exe1 = {1};
    }

  endgroup

  function new(virtual inf vinf, mailbox mon2scb_in);
    this.vinf = vinf;
    this.mon2scb_in = mon2scb_in;
    cg_in = new();
  endfunction

  task main;
    forever begin
      transaction trans = new();
      @(posedge vinf.clk);
      wait(vinf.enable);
      trans.rd_wr   <= vinf.rd_wr;
      trans.addr    <= vinf.addr;
      trans.wr_data <= vinf.wr_data;
      @(posedge vinf.clk);
      @(posedge vinf.clk);
      addr    <= trans.addr;
      wr_data <= trans.wr_data;      

      cg_in.sample();

      mon2scb_in.put(trans);
      trans.display("[ --Monitor In-- ]");
    end
  endtask
endclass