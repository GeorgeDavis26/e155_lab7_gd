/////////////////////////////////////////////
// shift_rows
//   shifts rows of the input set of 4 words
//   depending on the AES 128 shift rows
//.  specification.
/////////////////////////////////////////////


module shift_rows(
    //input   logic         enable,
    input   logic [127:0] a,
    output  logic [127:0] y
);
    //logic [127:0] y_interm;
 
    always_comb begin
        y[127:120] = a[127:120];
        y[95:88] = a[95:88];
        y[63:56] = a[63:56];
        y[31:24] = a[31:24];                        
        //Row 2
        y[119:112] = a[87:80];
        y[87:80] = a[55:48];
        y[55:48] = a[23:16];
        y[23:16] = a[119:112];
        //Row 3
        y[111:104] = a[47:40];
        y[79:72] = a[15:8];
        y[47:40] = a[111:104];
        y[15:8] = a[79:72];
        //Row 4
        y[103:96] = a[7:0];
        y[71:64] = a[103:96];
        y[39:32] = a[71:64];
        y[7:0]  = a[39:32];
    end

    //assign y = enable ? (y_interm) : (a);
endmodule