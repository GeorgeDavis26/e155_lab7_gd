module add_round_key(
    //input   logic         enable,
    input	logic [127:0] w, //4 * (Nr + 1) words
    input   logic [127:0] a,
    output  logic [127:0] y
);
    assign y = (a ^ w);
endmodule
    // typedef enum logic [1:0] {IDLE, ADD};
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
    //         ADD:    y = (a ^ w);
    //                 // begin
    //                 //     //Row 1
    //                 //     y[127:120] <= (a[127:120] ^ w[127:120]);
    //                 //     y[95:88] <= (a[95:88] ^ w[95:88]);
    //                 //     y[63:56] <= (a[63:56] ^ w[63:56]);
    //                 //     y[31:24] <= (a[31:24] ^ w[31:24]);                        
    //                 //     //Row 2
    //                 //     y[119:112] <= (a[119:112]^ y[119:112]);
    //                 //     y[87:80] <= (a[87:80] ^ y[87:80]);
    //                 //     y[55:48] <= (a[55:48] ^ y[55:48]);
    //                 //     y[23:16] <= (a[23:16] ^ y[23:16]);
    //                 //     //Row 3
    //                 //     y[111:104] <= (a[111:104] ^ y[111:104]);
    //                 //     y[79:72] <= (a[79:72] ^ y[79:72]);
    //                 //     y[47:40] <= (a[47:40] ^ y[47:40]);
    //                 //     y[15:8] <= (a[15:8] ^ y[15:8]);
    //                 //     //Row 4
    //                 //     y[103:96] <= (a[103:96] ^ y[103:96]);
    //                 //     y[71:64] <= (a[71:64] ^ y[71:64]);
    //                 //     y[39:32] <= (a[39:32] ^ y[39:32]);
    //                 //     y[7:0] <= (a[7:0] ^ y[7:0]);
    //                 // end
    //         IDLE:  y = a;
    //         default: y = a;
    //     endcase
    // end