class monitor_out;
  virtual inf vinf;
  mailbox mon2scb_out;

    bit [15:0] res_out;
  
	covergroup cg_out;
      option.per_instance = 1;
      coverpoint res_out {
        bins zero     = {0};
        bins div_err  = {16'hDEAD};
        bins non_zero = default;
      }

    endgroup

  function new(virtual inf vinf, mailbox mon2scb_out);
    this.vinf = vinf;
    this.mon2scb_out = mon2scb_out;
    cg_out = new();
  endfunction

  task main;
    forever begin
      transaction trans = new();
      @(posedge vinf.clk);
      wait(vinf.enable);
      @(posedge vinf.clk);
      trans.rd_data <= vinf.rd_data;
      trans.res_out <= vinf.res_out;   
      @(posedge vinf.clk);
      res_out   = vinf.res_out;

      cg_out.sample();      
      mon2scb_out.put(trans);
      trans.display("[ --Monitor Out-- ]");
    end
  endtask
endclass
