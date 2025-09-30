`include "ref_model.sv"


class scoreboard;

  mailbox mon2scb_in;
  mailbox mon2scb_out;
  int num_transactions;
  int num_errors;
  ref_model rm; 
  
  bit [1:0] addr;
  bit [7:0] wr_data;
  bit [15:0] res_out;

  covergroup cg_scb;
    option.per_instance = 1;
    
    cp_opcode : coverpoint wr_data[2:0] iff (addr == 2) {
      bins nop  = {0};
      bins add  = {1};
      bins sub  = {2};
      bins mul  = {3};
      bins div  = {4};
    }  
  
    cp_result : coverpoint res_out {
      bins zero     = {0};
      bins div_err  = {16'hDEAD};
      bins non_zero = default;
    }
    
    cross cp_opcode, cp_result;
    
  endgroup 
    
  function new(mailbox mon2scb_in, mailbox mon2scb_out);
    this.mon2scb_in = mon2scb_in;
    this.mon2scb_out = mon2scb_out;
    this.rm = new();
    cg_scb = new();
  endfunction

  task main;
    transaction tr_in;
    transaction tr_out;

    forever begin
      mon2scb_in.get(tr_in);
      mon2scb_out.get(tr_out);
      addr <= tr_in.addr;
      wr_data <= tr_in.wr_data;
      res_out <= tr_out.res_out;
      
      cg_scb.sample();  // כאן יתבצע ה־cross

      rm.apply_transaction(tr_in);              
      if (tr_out.res_out != rm.expected_res_out()) begin
        $error("SCB FAIL: got %0d expected %0d", tr_out.res_out, rm.expected_res_out());
      	num_errors++;
      end else
       $display("SCB PASS: res_out=%0d", tr_out.res_out);  

      num_transactions++;
    
    if (num_errors == 0)
      $display("So far the entire test passed successfully (%0d transactions)", num_transactions);
    else
      $display("So far there are %0d errors out of %0d transactions",num_errors, num_transactions);
    end
   endtask

  
endclass
