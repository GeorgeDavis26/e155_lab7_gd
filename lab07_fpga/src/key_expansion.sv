module key_expansion(
    input   logic         clk, 
	input 	logic		  enable,
    input   logic         reset, 
    input   logic [127:0] key,
	output	logic 		  start,
    output  logic [31:0]  w [0:43] //4 * (Nr + 1) words
);

	logic [31:0] i;
	
    typedef enum logic [3:0] {IDLE, GEN_W, LOGIC, END} statetype;
    statetype state, nextstate;
	
    logic [31:0] temp, rot_temp, sub_temp; // temp word to assign to w
	
    logic [31:0] rcon [1:10];
    assign rcon = {
        32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000, 32'h10000000,
        32'h20000000, 32'h40000000, 32'h80000000, 32'h1B000000, 32'h36000000
    };

    //Next State Register
    always_ff @(posedge clk) begin
        if(reset) state <= IDLE;
        else state <= nextstate;
    end
	
    // Next State Logic
    always_comb begin
        case(state)
            IDLE:       if(enable) nextstate <= GEN_W;
                        else nextstate <= IDLE;
            GEN_W:      if(i == 4-1) nextstate <= LOGIC;   //w[i] <- key[4*i..4*i+3]
                        else nextstate <= GEN_W;                
            //WHEN THE LOOP CONCLUDES i=Nk
            LOGIC:  		if(i == (4*10+3)) nextstate <= END;    
							else nextstate <= LOGIC;
			END:			nextstate <= END;
            default:    	nextstate <= state;
        endcase
    end
	
	//OUTPUT LOGIC
	always_comb begin
		case(state)
			GEN_W:	begin 
					w[i] = key[32*i +: 32];
					i++;
					end
			LOGIC:	begin 
					temp = w[i-1];
					if (i%4 == 0) w[i] = w[i-4] ^ sub_temp ^ rcon[i/4];
					else w[i] = w[i-4] ^ temp;
					i++;
					end
			default: i = 0;
		endcase
	end

	//rotate word
	assign rot_temp[7:0] = (state == LOGIC) ? (temp[15:8]) : (temp[7:0]);      //a0 <- a1
    assign rot_temp[15:8] = (state == LOGIC) ? (temp[23:16]) : (temp[15:8]);   //a1 <- a2
    assign rot_temp[23:16] = (state == LOGIC) ? (temp[31:24]) : (temp[23:16]); //a2 <- a3
    assign rot_temp[31:24] = (state == LOGIC) ? (temp[7:0]) : (temp[31:24]);   //a3 <- a0
	
	//sub word
    sbox_sync A0(
        .a(rot_temp[7:0]),         //input [7:0]
        .clk(clk),          //input
        .y(sub_temp[7:0])   //output [7:0]
    );
    sbox_sync A1(
        .a(rot_temp[15:8]),        //input [7:0]
        .clk(clk),          //input
        .y(sub_temp[15:8])  //output [7:0]
    );
    sbox_sync A2(
        .a(rot_temp[23:16]),       //input [7:0]
        .clk(clk),          //input
        .y(sub_temp[23:16]) //output [7:0]
    );
    sbox_sync A3(
        .a(rot_temp[31:24]),       //input [7:0]
        .clk(clk),          //input
        .y(sub_temp[31:24]) //output [7:0]
    );              

////////////////////////////////OLD
	////temp ^ Rcon[i/k]
	//assign temp = (state = RCON) ? (sub_temp ^ Rcon[i/Nk] : ();

	////ASSIGN_W
	//assign w[i] = (state = ASSIGN_W) ? (w[i-4] ^ temp) : ();	
	//assign subword_flag = (state == GEN_TEMP1B);
	//assign start = (state == END);
	
	//rot_word rot_word(.
        //enable(rotword_flag),   //input
        //.a(temp_in),               //input [31:0]
        //.y(rot_temp)            //output [31:0]
    //);
	
    //sub_word sub_word( //consumes a clk cycle
        //.clk(clk),              //input
        //.enable(subword_flag),  //input 
        //.a(rot_temp),               //input [31:0]
        //.y(temp_out)            //output [31:0]
    //);
	
	            //ROTWORD:    	nextstate <= GEN_TEMP1B;    //RotWord(temp)
            //SUBWORD: 		nextstate <= GEN_TEMP1C;    //SubWord(RotWord(temp))
            //SUBWORD_SBOX:	nextstate <= GEN_TEMP1D;    //Stall for sbox_sync
            //RCON: 		    nextstate <= GEN_TEMP2;     //SubWord(RotWord(temp)) ^ Rcon(i/Nk)
            //ASSIGN_W:  		if(i == (4*10+3)) nextstate <= END;    //w[i] <- w[i-Nk]^temp
							//else nextstate <= GEN_TEMP0;
	
endmodule