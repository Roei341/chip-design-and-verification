class transaction;

  bit [3:0] fr_byte_position ;
  bit frame_detect;
  
  rand bit [7:0] payload[];  //dynamic array for the payload data

  typedef enum bit [1:0] {HEAD_1, HEAD_2, ILLEGAL} header_type_t; //3 kinds of headers choosing randomally 

  rand header_type_t header_kind;
 
  bit [7:0] header_bytes[2];

  constraint payload_len {
    if (header_kind == ILLEGAL) {
      // Case 1: The header is illegal, simulate "noise"
      payload.size inside {[10:40]};
    } else {
      // Case 2: The header is legal (HEAD_1 or HEAD_2), send a valid frame
      payload.size == 10;
    }
  }  
  constraint header_values {
    header_kind dist {HEAD_1 := 30, HEAD_2 := 20, ILLEGAL := 40};
  }
  
  function void post_randomize();
    payload = new[payload.size()];
    foreach (payload[i])
      payload[i] = $urandom_range(0,255);
    case (header_kind)
      HEAD_1: begin
      header_bytes[0] = 8'hAA; // LSB
      header_bytes[1] = 8'hAF; // MSB
      end

      HEAD_2: begin
      header_bytes[0] = 8'h55;
      header_bytes[1] = 8'hBA;
      end

      ILLEGAL: begin
      header_bytes[0] = $urandom_range(0,255);
      header_bytes[1] = $urandom_range(0,255);
      end
endcase

  endfunction 
  
  function void display(string name);
    $display("--------------------------------");
    $display("- %s", name);    
    $write("header_bytes = ");
    foreach (header_bytes[i]) $write("%02h ", header_bytes[i]);
    $display("");
    $write("payload = ");
    foreach (payload[i]) $write("%02h ", payload[i]);
    $display("");
    $display("fr_byte_position = %d, frame_detect=%d", fr_byte_position, frame_detect);
    $display("--------------------------------");
  endfunction

endclass  