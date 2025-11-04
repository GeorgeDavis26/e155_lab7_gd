/////////////////////////////////////////////
// aes_core
//   top level AES encryption module
//   when load is asserted, takes the current key and plaintext
//   generates cyphertext and asserts done when complete 11 cycles later
// 
//   See FIPS-197 with Nk = 4, Nb = 4, Nr = 10
//
//   The key and message are 128-bit values packed into an array of 16 bytes as
//   shown below
//        [127:120] [95:88] [63:56] [63:56]    S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
//
//   Equivalently, the values are packed into four words as given
//        [127:96]  [95:64] [63:32] [31:0]      w[0]    w[1]    w[2]    w[3]
/////////////////////////////////////////////

module aes_core(input  logic         clk, 
                input  logic         rst,  
                input  logic         load,
                input  logic [127:0] key,
                input  logic [127:0] plaintext, //in
                output logic         done, 
                output logic [127:0] cyphertext
);

    integer Nr = 10;
    integer round;
    logic reset = ~rst; // active low reset

    logic [31:0] w [0:43]; //4 * (Nr + 1) words
    
    key_expansion key_expansion(
        .clk(clk),      //input
        .reset(reset),  //input 
        .key(key),      //input [127:0]
        .w(w)           //output [31:0][0:43]
    );

    logic subbytes_flag, shiftrows_flag, mixcols_flag, addroundkey_flag;
	assign round = 0;

    typedef enum logic [3:0] {IDLE, ROUND0, SUB_BYTES1, SUB_BYTES2, SHIFT_ROWS, MIX_COLUMNS, ADD_ROUND_KEY};
    statetype state, nextstate;

    logic [127:0] code, nextcode;
    assign nextcode = plaintext; // state <- in
    
    //Next State Register
    always_ff @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            code <= plaintext;
        end
        else begin
            state <= nextstate;
            code <= nextcode;
        end
    end
    
    //round Register
    always_ff @(posedge clk) begin
        if(state == IDLE) round <= 0;
        else if (state == SUB_BYTES1) round++;
        else round <= round;
    end

    //Next State Logic
    always_comb begin
        case(state)
            IDLE:           if(load) nextstate <= ROUND0;
                            else nextstate <= IDLE;
            ROUND0:         nextstate <= SUB_BYTES1;
            SUB_BYTES1:     nextstate <= SUB_BYTES2;
            SUB_BYTES2:     nextstate <= SHIFT_ROWS;   
            SHIFT_ROWS:     if(round == Nr) nextstate <= ADD_ROUND_KEY;
                            else nextstate <= MIX_COLUMNS;
            MIX_COLUMNS:   nextstate <= ADD_ROUND_KEY;
            ADD_ROUND_KEY:  if(round == Nr) nextstate <= IDLE;
                            else nextstate <= SUB_BYTES1;
            default:        nextstate <= IDLE;
        endcase
    end

    //Output Logic for Control Signals
    assign addroundkey_flag = (state == ROUND0);
    assign subbytes_flag = (state == SUB_BYTES1);
    assign shiftrows_flag = (state == SHIFT_ROWS);
    assign mixcols_flag = (state == MIX_COLUMNS);
    assign addroundkey_flag = (state == ADD_ROUND_KEY);

    //Sub Module Calls
    sub_bytes sub_bytes(
        .clk(clk),                  //input
        .enable(subbytes_flag),     //input
        .a(code),                   //input [127:0]
        .y(nextcode)               //output [127:0]
    ); //DONE

    shift_rows shift_rows(
        .enable(shiftrows_flag),    //input
        .a(code),                   //input [127:0]
        .y(nextcode)       //output [127:0]
    ); //DONE

    mix_columns mix_columns(
        .enable(mixcols_flag),      //input
        .a(code),                   //input [127:0]
        .y(nextcode)        //ouput [127:0]
    ); //DONE

    add_round_key add_round_key(
        .enable(addroundkey_flag),  //input
        .w(w[4*round+:3]),    //input [31:0][0:3] 
        .a(code),                   //input [127:0]
        .y(nextcode)        //output [127:0]
    );
endmodule