`include "environment.sv"

class test;
  environment env;
  virtual inf vinf;
  function new (virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction
  task run_test();
    env.gen.repeat_count = 100;
    env.run();
  endtask
endclass
