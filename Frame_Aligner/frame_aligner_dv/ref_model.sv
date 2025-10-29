class ref_model;

  // --- State ---
  int unsigned legal_frames_in_a_row;
  int unsigned non_aligned_byte_count; 
  bit         is_aligned;             

  function new();
    legal_frames_in_a_row  = 0;
    non_aligned_byte_count = 0;
    is_aligned             = 0;
  endfunction

  function bit is_header_legal(bit [7:0] header_bytes[2]);
    return ( (header_bytes[0]==8'hAA && header_bytes[1]==8'hAF) ||
             (header_bytes[0]==8'h55 && header_bytes[1]==8'hBA) );
  endfunction


  function bit predict_frame_detect(bit this_frame_is_legal,
                                    int unsigned na_bytes_since_last_legal);
    bit prev_aligned;
    int prev_legal_count;
    bit expected_output_now;
    bit next_aligned;

    prev_aligned       = is_aligned;
    prev_legal_count   = legal_frames_in_a_row;

    expected_output_now = prev_aligned;


    if (this_frame_is_legal) begin
      legal_frames_in_a_row++;
      non_aligned_byte_count = 0;
    end else begin
      legal_frames_in_a_row  = 0;
      non_aligned_byte_count++;
      non_aligned_byte_count = na_bytes_since_last_legal;
    end

    next_aligned = prev_aligned;
    if (legal_frames_in_a_row >= 3)           next_aligned = 1; 
    if (non_aligned_byte_count >= 48)         next_aligned = 0; 

    is_aligned = next_aligned;
    

    return expected_output_now;
  endfunction

endclass
