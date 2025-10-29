`include "ref_model.sv"

class scoreboard;

  // Mailboxes
  mailbox mon2scb_in;   
  mailbox mon2scb_out; 

  // Counters / State
  int num_transactions;     
  int num_errors;

  // Reference model
  ref_model rm;

  transaction tr_out_prev;

  typedef enum {S_IDLE, S_HLSB, S_HMSB, S_PAY} scb_state_e;
  scb_state_e st;

  int unsigned na_bytes_since_last_legal;

  function new(mailbox mon2scb_in, mailbox mon2scb_out);
    this.mon2scb_in  = mon2scb_in;
    this.mon2scb_out = mon2scb_out;
    this.rm          = new();
    this.st          = S_IDLE;
    this.tr_out_prev = null;
    this.na_bytes_since_last_legal = 0;
    num_transactions = 0;
    num_errors       = 0;
  endfunction

  task main;
    byte unsigned b;
    transaction  tr_out_status;    
    transaction  tr_build;         
    bit [7:0]    temp_payload[];
    bit          ok;               
    bit          expected;         
    bit          inc_na_this_cycle; 

    tr_build = null;

    forever begin
      mon2scb_out.get(tr_out_status);

      mon2scb_in.get(b);

      inc_na_this_cycle = 1'b1; 

      unique case (st)

        S_IDLE: begin
          if (b==8'hAA || b==8'h55) begin
            tr_build = new();
            tr_build.payload = new[0];
            tr_build.header_bytes[0] = b;
            st = S_HLSB;
            inc_na_this_cycle = 1'b0; 
          end
          else begin
             expected = rm.predict_frame_detect(
                          /*this_frame_is_legal*/ 1'b0,
                          /*na_bytes_since_last_legal*/ na_bytes_since_last_legal
             );
             if (tr_out_prev.frame_detect !== expected) begin
               $error("SCB FAIL (IDLE_MISS): DUT=%0d, EXP=%0d",
                      tr_out_prev.frame_detect, expected);
               num_errors++;
             end
          end
        end

        S_HLSB: begin
          if (tr_build == null) begin
            st = S_IDLE;
          end else begin
            tr_build.header_bytes[1] = b;
            ok = ((tr_build.header_bytes[0]==8'hAA && b==8'hAF) ||
                  (tr_build.header_bytes[0]==8'h55 && b==8'hBA));
            if (ok) begin
              st = S_HMSB;
              inc_na_this_cycle = 1'b0; 
            end else begin
              expected = rm.predict_frame_detect(
                           /*this_frame_is_legal*/ 1'b0,
                           /*na_bytes_since_last_legal*/ na_bytes_since_last_legal
              ); 
              if (tr_out_prev.frame_detect !== expected) begin
                $error("SCB FAIL (ILLEGAL): DUT=%0d, EXP=%0d",
                       tr_out_prev.frame_detect, expected);
                num_errors++;
              end else begin
                $display("SCB PASS (ILLEGAL): DUT=%0d matches EXP=%0d (tx=%0d)",
                         tr_out_prev.frame_detect, expected, num_transactions);
              end
           
              tr_build = null;
              st = S_IDLE;
            end
          end
        end

        S_HMSB: begin
          st = S_PAY;
          inc_na_this_cycle = 1'b0; 
        end

        S_PAY: begin
          inc_na_this_cycle = 1'b0; 
          temp_payload = new[tr_build.payload.size()+1];
          foreach (tr_build.payload[i]) temp_payload[i] = tr_build.payload[i];
          temp_payload[temp_payload.size()-1] = b;
          tr_build.payload = temp_payload;

          if (tr_build.payload.size() == 9) begin 
            expected = rm.predict_frame_detect(
                         /*this_frame_is_legal*/ 1'b1,
                         /*na_bytes_since_last_legal*/ 0
                       );

            if (tr_out_prev.frame_detect != expected) begin
              $error("SCB FAIL: DUT=%0d, EXP=%0d",
                     tr_out_prev.frame_detect, expected );
              num_errors++;
            end else begin
              $display("SCB PASS: DUT=%0d matches EXP=%0d (tx=%0d)",
                       tr_out_prev.frame_detect, expected, num_transactions);
            end

            num_transactions++;
            na_bytes_since_last_legal = 0; 
            tr_build = null;
            st = S_IDLE;
          end
        end

      endcase

      if (inc_na_this_cycle) na_bytes_since_last_legal++;

      tr_out_prev = tr_out_status;

    end // forever
  endtask


endclass