`include "environment.sv"

class test;
  environment env;
  virtual inf vinf;
  function new (virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction
  task run_test();
    env.gen.repeat_count = 80;
    env.run();
  endtask
endclass

class rd_wr_test;
  environment env;
  virtual inf vinf;
  transaction tr;
  function new(virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction
  
  task run_test();
    env.gen.repeat_count = 3;
    fork
      for (int i = 0; i < env.gen.repeat_count; i++) begin
        tr = new();
        tr.randomize();
        if (i == 0) begin
          tr.rd_wr <= 0;
          tr.addr <= 2'b10;
          tr.wr_data <= 8'd32;
        end
        else if (i == 1) begin
          tr.rd_wr <= 1;
        end
        env.gen.gen2drv.put(tr);
        tr.display("[---Rd_Wr_Test---]");
      end
      -> env.gen.ended;
      env.drv.main();
    join_any
    wait (env.gen.ended.triggered);
    wait (env.gen.repeat_count == env.drv.num_transactions);
    $finish;
  endtask
endclass
        

        