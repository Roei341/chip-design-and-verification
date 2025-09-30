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
    vinf.rx_data <= 0;
    wait (!vinf.reset);
    $display("[---driver---] ---reset ended ---");
  endtask
  
  task main();
    forever begin
      transaction trans;
      gen2drv.get(trans);

      // header
      vinf.rx_data <= trans.header_bytes[0];  
      @(posedge vinf.clk);
      vinf.rx_data <= trans.header_bytes[1];  
      @(posedge vinf.clk);

      // payload
      for (int i = 0; i < 10; i++) begin
        vinf.rx_data <= trans.payload[i];
        @(posedge vinf.clk);
      end

      trans.fr_byte_position = vinf.fr_byte_position;
      trans.frame_detect     = vinf.frame_detect;
	  //@(posedge vinf.clk);
      trans.display("[---Driver---]");
      num_transactions++;
    end
  endtask

endclass