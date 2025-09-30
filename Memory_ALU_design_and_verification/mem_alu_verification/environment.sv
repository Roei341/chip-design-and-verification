`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"


class environment;
  generator gen;
  driver drv;
  monitor_in mon_in;
  monitor_out mon_out;
  scoreboard scb;
  
  mailbox gen2drv;
  mailbox mon2scb_in;
  mailbox mon2scb_out;
  
  virtual inf vinf;
  
  function new(virtual inf vinf);
    this.vinf = vinf;
    gen2drv = new();
    mon2scb_in = new();
    mon2scb_out = new();
    
    gen = new(gen2drv);
    drv = new(vinf, gen2drv);
    mon_in = new(vinf, mon2scb_in);
    mon_out = new(vinf, mon2scb_out);    
    scb = new(mon2scb_in, mon2scb_out);
  endfunction
  
  task pre_test ();
    drv.reset();
  endtask
  
  task test();
    fork
      gen.main();
      drv.main();
      mon_in.main();
      mon_out.main();
      scb.main();
    join_any            
  endtask
  
  task post_test();
    wait (gen.ended.triggered);
    wait (gen.repeat_count == drv.num_transactions);
    wait (gen.repeat_count == scb.num_transactions);

    $display("Functional Coverage Of Monitor In = %0.2f%%", mon_in.cg_in.get_coverage());
    $display("Functional Coverage Of Monitor Out = %0.2f%%", mon_out.cg_out.get_coverage());
    $display("Functional Coverage Of Scoreboard = %0.2f%%", scb.cg_scb.get_coverage());

    
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
    $finish;
  endtask
endclass