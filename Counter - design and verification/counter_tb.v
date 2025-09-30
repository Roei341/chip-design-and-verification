class transaction;
  rand bit [7:0] data_in;
  bit load;
  bit enable = 1;
  bit [7:0] count;
  function void display(string name);
    $display("--------------------------------");
    $display("- %s", name);
    $display("Data in = %d, Load = %d, Enable = %d", data_in, load, enable);
    $display(" -count = %d", count);
    $display("--------------------------------");
  endfunction
endclass

class generator;
  transaction trans;
  int repeat_count;
  mailbox gen2drv;
  event ended;
  
  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction
  
  task main();
    repeat (repeat_count) begin
      trans = new();
      if (! trans.randomize())
        $fatal("Trans randimization failed");
      trans.display ("[---generator---]");
      gen2drv.put(trans);
    end
    -> ended;
  endtask
endclass

class driver;
  int num_transactions;
  virtual inf vinf;
  mailbox gen2drv;
  
  function new(virtual inf vinf, mailbox gen2drv);
    this.vinf = vinf;
    this.gen2drv = gen2drv;
  endfunction
  
  task reset_n;
    wait (!vinf.rst_n);
    $display(" [---Driver---] ---reset started ---");
    vinf.enable <= 0;
    vinf.load <= 0;
    vinf.data_in <= 0;
    wait (vinf.rst_n);
    $display("[---driver---] ---reset ended ---");
  endtask
  
  task main();
    forever begin
      transaction trans;
      gen2drv.get(trans);
      @(posedge vinf.clk);
      vinf.enable <= trans.enable;
      vinf.load <= trans.load;
      vinf.data_in <= trans.data_in;
      @(posedge vinf.clk);
      vinf.enable <= 0;
      trans.count = vinf.count;
      @(posedge vinf.clk);
      trans.display("[---Driver---]");
      num_transactions++;
    end
  endtask
endclass

class environment;
  generator gen;
  driver drv;
  mailbox gen2drv;
  virtual inf vinf;
  
  function new(virtual inf vinf);
    this.vinf = vinf;
    gen2drv = new();
    gen = new(gen2drv);
    drv = new(vinf, gen2drv);
  endfunction
  
  task pre_test ();
    drv.reset_n();
  endtask
  
  task test();
    fork
      gen.main();
      drv.main();
    join_any
  endtask
  
  task post_test();
    wait (gen.ended.triggered);
    wait (gen.repeat_count == drv.num_transactions);
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
    $finish;
  endtask
endclass


c

class load_test;
  virtual inf vinf;
  transaction t;
  environment env;
  
  function new(virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction;
  
  task run_test();
    env.gen.repeat_count = 25;
    fork  
      for (int i = 0; i<env.gen.repeat_count; i++) begin
        t = new();
        t.randomize();
        if (i == 10) begin
          t.load = 1;
          t.data_in = 8'h33;
        end
        else begin 
          t.load = 0;
        end
        t.display("[---Test Load---]");
        env.gen.gen2drv.put(t);
      end
      -> env.gen.ended;
      env.drv.main();
    join_any
    wait (env.gen.ended.triggered);
    wait (env.gen.repeat_count == env.drv.num_transactions);
    $finish;
  endtask
endclass

class enable_test;
  virtual inf vinf;
  transaction t;
  environment env;
  function new(virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction
  
  task run_test();
    env.gen.repeat_count = 20;
    fork
      for (int i = 0; i < env.gen.repeat_count; i++) begin
        t = new();
        t.randomize();
        if (i == 10)
          t.enable = 0;
        else
          t.enable = 1;
        t.display("[---Enable Test---]");
        env.gen.gen2drv.put(t);
      end
      -> env.gen.ended;
      env.drv.main();
    join_any
    wait (env.gen.ended.triggered);
    wait (env.gen.repeat_count == env.drv.num_transactions);
    $finish;
  endtask
endclass
          
module top;
  bit clk = 0;
  bit rst_n = 1;
  always #5 clk = ~clk;
  
  initial begin
    rst_n = 0;
    #15 rst_n = 1;
  end
  
  inf dut_inf(clk, rst_n);
  counter dut(dut_inf);
  //test t1;
  load_test t1;
  //enable_test t1;
  initial begin;
    t1 = new(dut_inf);
    t1.run_test();
  end
  
  
 
endmodule

