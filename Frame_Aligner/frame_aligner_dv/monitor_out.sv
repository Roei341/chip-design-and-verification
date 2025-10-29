
class monitor_out; 
  virtual inf vinf; 
  mailbox mon2scb_out; 
  
  // --- Coverage Addition ---
  bit frame_detect_prev; 

  covergroup cg_out @(posedge vinf.clk); 
    option.per_instance = 1;
    
    // Coverpoint for byte position
    cp_byte_pos : coverpoint vinf.fr_byte_position {
        bins pos_0_1 = {[0:1]}; 
        bins pos_2_10 = {[2:10]};
        bins pos_11 = {11};      
       
    }
    
    cp_frame_detect : coverpoint vinf.frame_detect {
        bins off = {0};
        bins on  = {1};
    }

    cp_frame_detect_trans : coverpoint vinf.frame_detect {
        bins off_to_on  = (0 => 1);
        bins on_to_off  = (1 => 0);
        ignore_bins others = (0 => 0), (1 => 1); 
    }
  endgroup

  function new(virtual inf vinf, mailbox mon2scb_out); 
    this.vinf = vinf; 
    this.mon2scb_out = mon2scb_out; 
    cg_out = new(); 
    frame_detect_prev = 0; 
  endfunction 
  
  task main; 
    forever begin 
      transaction trans = new(); 
      @(posedge vinf.clk); 
      
      frame_detect_prev = vinf.frame_detect; 
      trans.fr_byte_position <= vinf.fr_byte_position; 
      trans.frame_detect <= vinf.frame_detect; 
      mon2scb_out.put(trans); 
    end 
  endtask 
endclass