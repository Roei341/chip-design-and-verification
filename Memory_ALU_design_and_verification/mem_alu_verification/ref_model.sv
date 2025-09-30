class ref_model;

  bit [7:0] mem [0:3];  

  localparam int A_ADR   = 0;
  localparam int B_ADR   = 1;
  localparam int OP_ADR  = 2;
  localparam int EXE_ADR = 3;

  localparam bit [15:0] ERR_DIV0 = 16'hDEAD;

  function void apply_transaction(transaction tr);
    if (!tr.rd_wr) begin
      // write
      case(tr.addr)
        A_ADR:   mem[A_ADR]   = tr.wr_data;
        B_ADR:   mem[B_ADR]   = tr.wr_data;
        OP_ADR:  mem[OP_ADR]  = {5'b0, tr.wr_data[2:0]};
        EXE_ADR: mem[EXE_ADR] = {7'b0, tr.wr_data[0]};
        default: ; 
      endcase
    end
  endfunction

  function bit [15:0] expected_res_out();
    bit [7:0] a_val = mem[A_ADR];
    bit [7:0] b_val = mem[B_ADR];
    bit [2:0] op_val = mem[OP_ADR][2:0];
    bit exe_val = mem[EXE_ADR][0];
    bit [15:0] res_next;

    if (!exe_val) 
      res_next = 16'd0; 
    else begin
      case(op_val)
        3'd0:    res_next = 16'd0;
        3'd1:    res_next = a_val + b_val;
        3'd2:    res_next = a_val - b_val;
        3'd3:    res_next = a_val * b_val;
        3'd4:    res_next = (b_val == 0) ? ERR_DIV0 : (a_val / b_val);
        default: res_next = 16'hxxxx;
      endcase
    end
    return res_next;
  endfunction

endclass
