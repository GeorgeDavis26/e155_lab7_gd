// AES-128 combinational next-round key expansion
// Inputs:
//   prev_key : 128-bit previous round key (w[4*l .. 4*l+3])
//   round    : integer Rcon index (1..10) corresponding to next expansion step
// Output:
//   next_key : 128-bit next round key (w[4*(l+1) .. 4*(l+1)+3])
//
// Assumes existence of the following combinational modules (black boxes):
//   module rotword(input logic [31:0] in, output logic [31:0] out);
//   module subword(input logic [31:0] in, output logic [31:0] out);
//
// This implements the AES-128 case described in FIPS-197 (KEYEXPANSION).
module aes_keyexpander128_comb (
    input  logic [127:0] prev_key, // previous round key (4 words: w0..w3)
    input  logic  [3:0]  round,    // Rcon index (1..10). If 0, module returns prev_key unchanged.
    output logic [127:0] next_key
);

    // Split prev_key into 4 words (big-endian per-word: byte0 in bits [31:24])
    logic [31:0] prev_w [0:3];
    assign prev_w[0] = prev_key[127:96];
    assign prev_w[1] = prev_key[95:64];
    assign prev_w[2] = prev_key[63:32];
    assign prev_w[3] = prev_key[31:0];

    // Rcon lookup: words [Rcon, 0x00, 0x00, 0x00]
    function automatic logic [31:0] rcon_word(input logic [3:0] r);
        case (r)
            4'd1 : rcon_word = 32'h0100_0000;
            4'd2 : rcon_word = 32'h0200_0000;
            4'd3 : rcon_word = 32'h0400_0000;
            4'd4 : rcon_word = 32'h0800_0000;
            4'd5 : rcon_word = 32'h1000_0000;
            4'd6 : rcon_word = 32'h2000_0000;
            4'd7 : rcon_word = 32'h4000_0000;
            4'd8 : rcon_word = 32'h8000_0000;
            4'd9 : rcon_word = 32'h1b00_0000;
            4'd10: rcon_word = 32'h3600_0000;
            default: rcon_word = 32'h0000_0000; // round==0 or out-of-range -> zero
        endcase
    endfunction

    // intermediate wires
    logic [31:0] rot_out;
    logic [31:0] sub_out;
    logic [31:0] temp;
    logic [31:0] next_w [0:3];

    // Instantiate ROTWORD and SUBWORD (combinational)
    // These module names and ports must match your implementation of ROTWORD and SUBWORD.
    rotword u_rot (.in(prev_w[3]), .out(rot_out));
    subword u_sub (.in(rot_out),   .out(sub_out));

    // Compute temp = SUBWORD(ROTWORD(prev_w[3])) XOR Rcon[round]
    assign temp = (round == 4'd0) ? 32'h0 : (sub_out ^ rcon_word(round));

    // Compute the 4 next words (combinational XOR chain)
    // next_w0 = prev_w0 ^ temp
    // next_w1 = prev_w1 ^ next_w0
    // next_w2 = prev_w2 ^ next_w1
    // next_w3 = prev_w3 ^ next_w2
    assign next_w[0] = prev_w[0] ^ temp;
    assign next_w[1] = prev_w[1] ^ next_w[0];
    assign next_w[2] = prev_w[2] ^ next_w[1];
    assign next_w[3] = prev_w[3] ^ next_w[2];

    // If round == 0, pass through previous key unchanged (convenience)
    // Otherwise output the expanded next key
    assign next_key = (round == 4'd0) ? prev_key :
                      { next_w[0], next_w[1], next_w[2], next_w[3] };

endmodule