`include "environment.sv"

// -----------------------------------------------------------------
// Random Test
// -----------------------------------------------------------------
class test_random;
  environment env;
  virtual inf vinf;
  
  function new (virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction
  
  task run_test();
    $display("--- [Random Test] Starting default random test ---");
    env.gen.repeat_count = 100;
    env.run(); 
  endtask
  
endclass


// -----------------------------------------------------------------
// Directed Test: 5 Illegal -> 5 Legal -> 5 Illegal
// -----------------------------------------------------------------
class test_alignment_sequence;
  environment env;
  virtual inf vinf;
  transaction trans; 

  function new (virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction

  task run_test();
    $display("--- [Directed Test] Starting test_alignment_sequence (Simplified) ---");
    
    env.gen.repeat_count = 15; 

    env.pre_test(); 

    fork
      // --- Generation Loop ---
      begin 
        for (int i = 0; i < env.gen.repeat_count; i++) begin
          trans = new(); 

          if (i < 5) begin // First 5 are ILLEGAL
            void'(trans.randomize() with { header_kind == ILLEGAL; });
            trans.display($sformatf("[Test Seq %0d/%0d: ILLEGAL]", i+1, env.gen.repeat_count));
          end else if (i < 10) begin // Next 5 are LEGAL (using HEAD_1)
            void'(trans.randomize() with { header_kind == HEAD_1; });
            trans.display($sformatf("[Test Seq %0d/%0d: LEGAL]", i+1, env.gen.repeat_count));
          end else begin // Last 5 are ILLEGAL
            void'(trans.randomize() with { header_kind == ILLEGAL; });
            trans.display($sformatf("[Test Seq %0d/%0d: ILLEGAL]", i+1, env.gen.repeat_count));
          end
          
          env.gen.gen2drv.put(trans); 
        end 
        
        -> env.gen.ended; 
        $display("[Test Seq] Finished sending all %0d transactions.", env.gen.repeat_count);
      end 

      env.drv.main();
    join_any 
    
    $display("[Test Seq] Waiting for generator 'ended' signal...");
    wait (env.gen.ended.triggered);
    $display("[Test Seq] Waiting for driver to process all transactions...");
    wait (env.gen.repeat_count == env.drv.num_transactions); 
    $display("[Test Seq] Driver finished processing.");

    $display("[Test Seq] Adding final delay for scoreboard...");
    repeat (50) @(posedge vinf.clk); 

    // --- Report and Finish ---
    $display("--------------------------------------------------");
    $display("TEST DONE (%s)", $typename(this)); 
    $display("- Transactions generated          : %0d", env.gen.repeat_count);
    $display("- Driver transactions processed   : %0d", env.drv.num_transactions);
    $display("- Scoreboard checks performed     : %0d", env.scb.num_transactions); 
    $display("- Scoreboard errors               : %0d", env.scb.num_errors);
    $display("--------------------------------------------------");
    $finish; // End simulation

  endtask 

endclass 



// -----------------------------------------------------------------
// Directed Test: 5x Half-Legal Headers 
// -----------------------------------------------------------------

class test_half_legal_header;
  environment env;
  virtual inf vinf;
  transaction trans;
  int position_errors = 0; // Counter for the specific error we are checking

  function new (virtual inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction

  task run_test();
    $display("--- [Directed Test] Starting test_half_legal_header (Simplified + Pos Check) ---");
    
    env.gen.repeat_count = 5; 
    env.pre_test(); 

    fork
      begin 
        for (int i = 0; i < env.gen.repeat_count; i++) begin
          trans = new(); 
          void'(trans.randomize() with { header_kind == ILLEGAL; });
          if (i % 2 == 0) begin 
            trans.header_bytes[0] = 8'hAA;
            do begin trans.header_bytes[1] = $urandom_range(0,255); end while (trans.header_bytes[1] == 8'hAF);
            trans.display($sformatf("[Test Seq %0d/%0d: Half-Legal AA]", i+1, env.gen.repeat_count));
          end else begin 
            trans.header_bytes[0] = 8'h55;
            do begin trans.header_bytes[1] = $urandom_range(0,255); end while (trans.header_bytes[1] == 8'hBA);
            trans.display($sformatf("[Test Seq %0d/%0d: Half-Legal 55]", i+1, env.gen.repeat_count));
          end
          env.gen.gen2drv.put(trans); 
        end 
        -> env.gen.ended; 
        $display("[Test Seq] Finished sending all %0d transactions.", env.gen.repeat_count);
      end 

      env.drv.main();
      env.mon_in.main();
      env.mon_out.main();
      env.scb.main(); 

      begin
        $display("[Position Check] Starting monitor...");
        forever begin
          @(posedge vinf.clk); 
          if (vinf.fr_byte_position == 1) begin
             $error("[Position Check] FAIL: fr_byte_position advanced to 1 at time %0t ns", $time);
             position_errors++; 
          end
        end // End forever
      end // End position monitoring block

    join_any 

    $display("[Test Seq] Waiting for generator 'ended' signal...");
    wait (env.gen.ended.triggered); 
    $display("[Test Seq] Waiting for driver to process all transactions...");
    wait (env.gen.repeat_count == env.drv.num_transactions); 
    $display("[Test Seq] Driver finished processing.");

    $display("[Test Seq] Adding final delay for scoreboard...");
    repeat (50) @(posedge vinf.clk); 

    $display("--------------------------------------------------");
    $display("TEST DONE (%s)", $typename(this)); 
    $display("- Transactions generated          : %0d", env.gen.repeat_count);
    $display("- Driver transactions processed   : %0d", env.drv.num_transactions);
    $display("- Scoreboard checks performed     : %0d", env.scb.num_transactions); 
    $display("- Scoreboard errors               : %0d", env.scb.num_errors);
    $display("- Position Check errors (pos == 1): %0d", position_errors); 
    $display("--------------------------------------------------");
    $finish; 

  endtask 

endclass