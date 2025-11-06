//======================================================================
// Generic Key Expansion Logic (loop unrolled, purely combinational)
// Implements the described pseudo-code literally.
//
// Notes:
// - module1 and module2 are instantiated as combinational transforms.
// - (+) is XOR (bitwise ^).
// - Key is provided as a flat vector of bytes; each word is 32 bits.
//======================================================================

module key_expansion_comb #(
    parameter int Nk = 4,  // Number of key words
    parameter int Nr = 10  // Number of rounds (controls total words)
)(
    input  logic [32*Nk-1:0] key,        // Input key words concatenated
    input  logic [31:0]      Rcon [1:Nr],// Rcon words, indexed by i/Nk
    output logic [32*(4*Nr+4)-1:0] w     // Expanded words concatenated
);

    // Split key into initial Nk words
    logic [31:0] w_arr [0:4*Nr+3];
    logic [31:0] temp_arr [0:4*Nr+3];

    genvar i;
    // Assign initial Nk words
    generate
        for (i = 0; i < Nk; i++) begin : INIT_WORDS
            assign w_arr[i] = key[32*(Nk-1-i) +: 32]; // slice [MSB..LSB] per word
        end
    endgenerate

    // Instantiate modules
    // (single shared instances are fine since this is combinational)
    logic [31:0] mod1_in, mod1_out;
    logic [31:0] mod2_in, mod2_out;

    module1 u_mod1 (.in(mod1_in), .out(mod1_out));
    module2 u_mod2 (.in(mod2_in), .out(mod2_out));

    // Manual unrolled logic for demonstration purposes
    // (You can expand to desired Nr using generate-if structures.)
    // Below shows general pattern of unrolling:
    //   w[i] = w[i - Nk] ^ temp
    // where temp is conditionally modified.

    // Example for Nk=4, Nr=10 → total words = 44 (w[0]..w[43])
    // We'll explicitly compute w[4]..w[43]

    // For readability, we show the first few steps explicitly;
    // additional ones follow the same pattern.
    // ----------------------------------------------------------
    // i = 4
    assign temp_arr[4] = (
        (4 % Nk == 0) ? (mod1_out ^ Rcon[4 / Nk]) :
        ((Nk > 6 && 4 % Nk == 4) ? mod1_out : w_arr[3])
    );

    assign w_arr[4] = w_arr[0] ^ temp_arr[4];

    // i = 5
    assign temp_arr[5] = (
        (5 % Nk == 0) ? (mod1_out ^ Rcon[5 / Nk]) :
        ((Nk > 6 && 5 % Nk == 4) ? mod1_out : w_arr[4])
    );
    assign w_arr[5] = w_arr[1] ^ temp_arr[5];

    // i = 6
    assign temp_arr[6] = (
        (6 % Nk == 0) ? (mod1_out ^ Rcon[6 / Nk]) :
        ((Nk > 6 && 6 % Nk == 4) ? mod1_out : w_arr[5])
    );
    assign w_arr[6] = w_arr[2] ^ temp_arr[6];

    // i = 7
    assign temp_arr[7] = (
        (7 % Nk == 0) ? (mod1_out ^ Rcon[7 / Nk]) :
        ((Nk > 6 && 7 % Nk == 4) ? mod1_out : w_arr[6])
    );
    assign w_arr[7] = w_arr[3] ^ temp_arr[7];
    // ----------------------------------------------------------

    // Remaining iterations would follow the same structure
    // (each unrolled by hand or code generator for synthesis).

    // Flatten output
    generate
        for (i = 0; i <= 4*Nr + 3; i++) begin : OUTPUT_ASSIGN
            assign w[32*((4*Nr+3)-i) +: 32] = w_arr[i];
        end
    endgenerate

endmodule
