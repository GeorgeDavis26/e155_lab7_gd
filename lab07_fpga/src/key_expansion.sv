module key_expansion(
    input   logic         clk, 
    input   logic         reset, 
    input   logic [127:0] key,
    output  logic [31:0]  w [0:43] //4 * (Nr + 1) words
);

    //constants
    integer WORD_WIDTH = 32;
    integer BYTE_WIDTH = 8;
    integer Nk = 4;
    integer Nr = 10;
	integer i = 0;
	
    typedef enum logic [3:0] {IDLE, GEN_W, GEN_TEMP0, GEN_TEMP1A, GEN_TEMP1B, GEN_TEMP1C, GEN_TEMP1D, GEN_TEMP2};
    statetype state, nextstate;

    logic [31:0] temp, nexttemp; // temp word to assign to w

    logic [31:0] rcon [1:10];
    assign rcon = {
        32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000, 32'h10000000,
        32'h20000000, 32'h40000000, 32'h80000000, 32'h1B000000, 32'h36000000
    };

    //Next State Register
    always_ff @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            temp <= 0;
        end
        else begin
            state <= nextstate;
            temp <= nexttemp;
        end
    end
    //Counter Register
    always_ff @(posedge clk) begin
        if(state == IDLE) i <= 0;
        else if (state == GEN_TEMP0) i++;
    end

    // Next State Logic
    always_comb begin
        case(state)
            IDLE:       if(enable) nextstate <= GEN_W;
                        else nextstate <= IDLE;
            GEN_W:      if(i == Nk-1) nextstate <= GEN_TEMP0;   //w[i] <- key[4*i..4*i+3]
                        else nextstate <= GEN_W;                
            //WHEN THE LOOP CONCLUDES i=Nk
            GEN_TEMP0:  if(i % Nk == 0) nextstate <= GEN_TEMP1A;    //temp <- w[i-1]
                        else nextstate <= GEN_TEMP2;
            GEN_TEMP1A: nextstate <= GEN_TEMP1B;    //RotWord(temp)
            GEN_TEMP1B: nextstate <= GEN_TEMP1C;    //SubWord(RotWord(temp))
            GEN_TEMP1C: nextstate <= GEN_TEMP1D;    //Stall for sbox_sync
            GEN_TEMP1D: nextstate <= GEN_TEMP2;     //SubWord(RotWord(temp)) ^ Rcon(i/Nk)
            GEN_TEMP2:  if(i == (4*Nr+3)) nextstate <= IDLE;    //w[i] <- w[i-Nk]^temp
                        else nextstate <= GEN_TEMP0;
            default:    nextstate <= state;
        endcase
    end
    
	assign addroundkey_flag = (state == ROUND0);
    assign subbytes_flag = (state == SUB_BYTES1);
    assign shiftrows_flag = (state == SHIFT_ROWS);
    assign mixcols_flag = (state == MIX_COLUMNS);
    assign addroundkey_flag = (state == ADD_ROUND_KEY);
	
    // Output Logic
    always_comb begin
        case(state)
            GEN_W:          w[i] <= key[(i * WORD_WIDTH) +: (i*WORD_WIDTH-1)];
            GEN_TEMP0:      temp <= w[i-1];
            GEN_TEMP1A:     rotword_flag <= 1;
            GEN_TEMP1B:     subword_flag <= 1;
            GEN_TEMP1D:     temp <= temp ^ rcon[i/Nk];
            GEN_TEMP2:      w[i] <= w[i-Nk]^temp;
            default:		w[i] <= 0;
        endcase
    end
    sub_word sub_word( //consumes a clk cycle
        .clk(clk),              //input
        .enable(subword_flag),  //input 
        .a(temp),               //input [31:0]
        .y(nexttemp)            //output [31:0]
    );
    rot_word rot_word(.
        enable(rotword_flag),   //input
        .a(temp),               //input [31:0]
        .y(nexttemp)            //output [31:0]
    );
endmodule