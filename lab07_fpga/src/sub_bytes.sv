module sub_bytes(
    input   logic         clk, 
    input   logic         enable,
    input   logic [127:0] a,
    output  logic [127:0] y
);

    logic   [127:0]    y_interm

    //Row 1
    sbox_sync S00(a[127:120], clk, y_interm[127:120]);
    sbox_sync S01(a[95:88], clk, y_interm[95:88]);
    sbox_sync S02(a[63:56], clk, y_interm[63:56]);
    sbox_sync S03(a[63:56], clk, y_interm[63:56]);                      
    //Row 2
    sbox_sync S10(a[119:112], clk, y_interm[119:112]);
    sbox_sync S11(a[87:80], clk, y_interm[87:80]);
    sbox_sync S12(a[55:48], clk, y_interm[55:48] );
    sbox_sync S13(a[23:16], clk, y_interm[23:16]);
    //Row 3
    sbox_sync S20(a[111:104], clk, y_interm[111:104]);
    sbox_sync S21(a[79:72], clk, y_interm[79:72]);
    sbox_sync S22(a[47:40], clk, y_interm[47:40]);
    sbox_sync S23(a[15:8], clk, y_interm[15:8]);
    //Row 4
    sbox_sync S30(a[103:96], clk, y_interm[103:96]);
    sbox_sync S31(a[71:64], clk, y_interm[71:64]);
    sbox_sync S32(a[39:32], clk, y_interm[39:32]);
    sbox_sync S33(a[7:0], clk, y_interm[7:0]);

    assign y = enable ? (y_interm) : (a);
endmodule
    // typedef enum logic [1:0] {IDLE, SUB} statetype;
    // statetype state, nextstate;

    // logic [31:0] counter = 0;

    // //Next State Register
    // always_ff @(posedge clk) begin
    //     if(reset) state <= IDLE;
    //     else state <= nextstate;
    // end
    // //Row 1
    // sbox sbox(a[127:120], y[127:120]);
    // sbox sbox(a[95:88], y[95:88]);
    // sbox sbox(a[63:56], y[63:56]);
    // sbox sbox(a[63:56], y[63:56]);                      
    // //Row 2
    // sbox sbox(a[119:112], y[119:112]);
    // sbox sbox(a[87:80], y[87:80]);
    // sbox sbox(a[55:48], y[55:48] );
    // sbox sbox(a[23:16], y[23:16]);
    // //Row 3
    // sbox sbox(a[111:104], y[111:104]);
    // sbox sbox(a[79:72], y[79:72]);
    // sbox sbox(a[47:40], y[47:40]);
    // sbox sbox(a[15:8], y[15:8]);
    // //Row 4
    // sbox sbox(a[103:96], y[103:96]);
    // sbox sbox(a[71:64], y[71:64]);
    // sbox sbox(a[39:32], y[39:32]);
    // sbox sbox(a[7:0], y[7:0]);

    // // Next State Legic
    // always_comb begin
    //     case(state)
    //         IDLE: if(enable) nextstate <= ROWS;
    //               else nextstate <= IDLE;
    //         SUB: nextstate <= IDLE;
    //         default:
    //     endcase
    // end

    // // Output Logic
    // always_comb begin
    //     case(state)
    //         IDLE:       y <= a;
    //         SUB:   begin
    //                 end
    //         default:    y <= a;
    //     endcase
    // end
endmodule