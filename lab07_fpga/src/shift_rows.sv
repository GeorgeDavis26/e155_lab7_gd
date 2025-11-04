module shift_rows(
    input   logic         enable,
    input   logic [127:0] a,
    output  logic [127:0] y
);
    logic [127:0] y_interm;
 
    always_comb begin
        y_interm[127:120] = a[127:120];
        y_interm[95:88] = a[95:88];
        y_interm[63:56] = a[63:56];
        y_interm[31:24] = a[31:24];                        
        //Row 2
        y_interm[119:112] = a[23:16];
        y_interm[87:80] = a[55:48];
        y_interm[55:48] = a[23:16];
        y_interm[23:16] = a[119:112];
        //Row 3
        y_interm[111:104] = a[47:40];
        y_interm[79:72] = a[15:8];
        y_interm[47:40] = a[111:104];
        y_interm[15:8] = a[79:72];
        //Row 4
        y_interm[103:96] = a[7:0];
        y_interm[71:64] = a[39:32];
        y_interm[39:32] = a[71:64];
        y_interm[7:0]  = a[103:96];
    end

    assign y = enable ? (y_interm) : (a);
endmodule

    // typedef enum logic [1:0] {IDLE, ROWS};
    // statetype state, nextstate

    // //Next State Register
    // always_ff @(posedge clk) begin
    //     if(reset) state <= IDLE;
    //     else state <= nextstate;
    // end

    // // Next State Legic
    // always_comb begin
    //     case(state)
    //         IDLE: if(enable) nextstate <= ROWS;
    //               else nextstate <= IDLE;
    //         ROWS: nextstate <= IDLE;
    //         default:
    //     endcase
    // end

    // // Output Logic
    // always_comb begin
    //     case(state)
    //         IDLE:       y <= a;
    //         ROWS:   begin
    //                     //Row 1
    //                     y[127:120] <= a[127:120];
    //                     y[95:88] <= a[95:88];
    //                     y[63:56] <= a[63:56];
    //                     y[31:24] <= a[31:24];                        
    //                     //Row 2
    //                     y[119:112] <= a[23:16];
    //                     y[87:80] <= a[55:48];
    //                     y[55:48] <= a[23:16];
    //                     y[23:16] <= a[119:112];
    //                     //Row 3
    //                     y[111:104] <= a[47:40];
    //                     y[79:72] <= a[15:8];
    //                     y[47:40] <= a[111:104];
    //                     y[15:8] <= a[79:72];
    //                     //Row 4
    //                     y[103:96] <= a[7:0];
    //                     y[71:64] <= a[39:32];
    //                     y[39:32] <= a[71:64];
    //                     y[7:0]  <= a[103:96];
    //                 end
    //         default:    y <= a;
    //     endcase
    // end