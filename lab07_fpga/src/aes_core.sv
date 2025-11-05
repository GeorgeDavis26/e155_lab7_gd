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
//        [127:120] [95:88] [63:56] [31:24]    S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
//
//   Equivalently, the values are packed into four words as given
//        [127:96]  [95:64] [63:32] [31:0]      w[0]    w[1]    w[2]    w[3]
/////////////////////////////////////////////

module aes_core(input  logic         clk, 
				input  logic		 rst, 
                input  logic         load,
                input  logic [127:0] key,
                input  logic [127:0] plaintext, //in
                output logic         done, 
                output logic [127:0] cyphertext
);
    logic [31:0] round;
    logic reset = ~rst; // active low reset
	logic start;
    logic [31:0] w [0:43]; //4 * (Nr + 1) words
    
    key_expansion key_expansion(
        .clk(clk),      //input
		.enable(load),	//input
        .reset(reset),  //input 
        .key(key),      //input [127:0]
		.start(start),	//output
        .w(w)           //output [31:0][0:43]
    );

    logic [127:0] sb_out, sr_out, mc_out, ark_out;

    typedef enum logic [3:0] {IDLE, ROUND0, SUB_BYTES1, SUB_BYTES2, SHIFT_ROWS, MIX_COLUMNS, ADD_ROUND_KEY} statetype;
    statetype state, nextstate;

    logic [127:0] code, nextcode;
    
    //Next State Register
    always_ff @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            code <= 0;
        end
        else begin
            state <= nextstate;
            code <= nextcode;
        end
    end
    
    //round Register
    always_ff @(posedge clk) begin
        if(state == IDLE) round = 0;
        else if (state == SUB_BYTES1) round++;
    end

    always_comb begin
    //Next State Logic
	case(state)
            IDLE:           if(start) nextstate <= ROUND0;
                            else nextstate <= IDLE;
            ROUND0:         nextstate <= SUB_BYTES1;
            SUB_BYTES1:     nextstate <= SUB_BYTES2;
            SUB_BYTES2:     nextstate <= SHIFT_ROWS;   
            SHIFT_ROWS:     if(round == 10) nextstate <= ADD_ROUND_KEY;
                            else nextstate <= MIX_COLUMNS;
            MIX_COLUMNS:   nextstate <= ADD_ROUND_KEY;
            ADD_ROUND_KEY:  if(round == 10) nextstate <= IDLE;
                            else nextstate <= SUB_BYTES1;
            default:        nextstate <= IDLE;
        endcase
	//Output Logic
	case(state)
		IDLE:			nextcode <= plaintext;
		ROUND0:			nextcode <= ark_out;
		SUB_BYTES2: 	nextcode <= sb_out;
		SHIFT_ROWS:		nextcode <= sr_out;
		MIX_COLUMNS:	nextcode <= mc_out;
		ADD_ROUND_KEY:  nextcode <= ark_out;
		default:		nextcode <= code;
		endcase
    end
    //Sub Module Calls
    sub_bytes sb(
        .clk(clk),					//input
		.a(code),                   //input [127:0]
        .y(sb_out)               //output [127:0]
    ); //DONE

    shift_rows sr(
        .a(code),                   //input [127:0]
        .y(sr_out)       //output [127:0]
    ); //DONE

    mix_columns mc(
        .a(code),                   //input [127:0]
        .y(mc_out)        //ouput [127:0]
    ); //DONE

    add_round_key ark(
        .w({w[round], w[round+1], w[round+2], w[round+3]}),    //input [31:0][0:3] 
        .a(code),                   //input [127:0]
        .y(ark_out)        //output [127:0]
    ); //DONE
endmodule