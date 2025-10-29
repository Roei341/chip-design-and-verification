class monitor_in; 
  virtual inf vinf;
  mailbox mon2scb_in; 

  // --- Coverage Addition ---
  covergroup cg_in @(posedge vinf.clk);
    option.per_instance = 1; 
    cp_rx_data : coverpoint vinf.rx_data {
      bins header_AA = {8'hAA};
      bins header_AF = {8'hAF};
      bins header_55 = {8'h55};
      bins header_BA = {8'hBA};
      bins zeros    = {8'h00};
      bins ff       = {8'hFF};
      bins others   = default; 
    }
  endgroup

  function new(virtual inf vinf, mailbox mon2scb_in); 
    this.vinf = vinf; 
    this.mon2scb_in = mon2scb_in; 
    cg_in = new(); 
  endfunction 
  
  task main; 
    forever begin 
      @(posedge vinf.clk); 
      mon2scb_in.put(vinf.rx_data); 
    end 
  endtask 
endclass