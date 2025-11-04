module rot_word(
    input   logic           enable,
    input   logic   [31:0]  a,
    output  logic   [31:0]  y
);

    assign y[7:0] = enable ? (a[8:15]) : (a[7:0]);      //a0 <- a1
    assign y[8:15] = enable ? (a[16:23]) : (a[8:15]);   //a1 <- a2
    assign y[16:23] = enable ? (a[24:31]) : (a[16:23]); //a2 <- a3
    assign y[24:31] = enable ? (a[7:0]) : (a[24:31]);   //a3 <- a0
endmodule