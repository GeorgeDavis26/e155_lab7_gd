/////////////////////////////////////////////
// add_round_key
//   adds or bitwise xor's the input set of 4 words
//   with a section of the w derived from
//.  key and key expansion
/////////////////////////////////////////////


module add_round_key(
    //input   logic         enable,
    input	logic [127:0] w, //4 * (Nr + 1) words
    input   logic [127:0] a,
    output  logic [127:0] y
);
    assign y = (a ^ w);
endmodule