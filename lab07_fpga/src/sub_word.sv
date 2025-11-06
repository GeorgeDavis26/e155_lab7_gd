/////////////////////////////////////////////
// sub_word
//   performs AES subword function by converting 
//.  the input word to its corrosponding
//.  word in the cryptic aes sbox array
/////////////////////////////////////////////

module sub_word(
    input   logic               clk,
    input   logic               enable,
    input   logic   [31:0]      a,
    output  logic   [31:0]      y
);

    logic   [31:0]    y_interm;

    sbox_sync A0(
        .a(a[7:0]),         //input [7:0]
        .clk(clk),          //input
        .y(y_interm[7:0])   //output [7:0]
    );
    sbox_sync A1(
        .a(a[15:8]),        //input [7:0]
        .clk(clk),          //input
        .y(y_interm[15:8])  //output [7:0]
    );
    sbox_sync A2(
        .a(a[23:16]),       //input [7:0]
        .clk(clk),          //input
        .y(y_interm[23:16]) //output [7:0]
    );
    sbox_sync A3(
        .a(a[31:24]),       //input [7:0]
        .clk(clk),          //input
        .y(y_interm[31:24]) //output [7:0]
    );              

    assign y = enable ? (y_interm) : (a);
endmodule