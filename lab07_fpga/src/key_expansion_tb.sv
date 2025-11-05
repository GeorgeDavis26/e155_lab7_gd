`timescale 10ns/1ns

/////////////////////////////////////////////
// testbench_aes_core
// Tests AES with cases from FIPS-197 appendix
// Tests aes_core module apart from the SPI load
// Added 4/28/21 by Josh Brake
// jbrake@hmc.edu
/////////////////////////////////////////////

module testbench_key_expansion();
    logic clk, enable, reset;
    logic [127:0] key;
    logic [31:0]  w [0:43];
    logic [31:0]  wexpected [0:43];
    // device under test
    key_expansion dut(clk, enable, reset, key, start, w);

    // test case
    initial begin   
    // Test case from FIPS-197 Appendix A.1, B
    key       <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
    wexpected[0] <= 32'h2b7e1516;
    wexpected[1] <= 32'h28aed2a6;
    wexpected[2] <= 32'habf71588;
    wexpected[3] <= 32'h09cf4f3c;

    wexpected[4] <= 32'ha0fafe17;
    
    wexpected[5] <= 32'h88542cb1;
    wexpected[6] <= 32'h23a33939;
    wexpected[7] <= 32'h2a6c7605;
    wexpected[8] <= 32'hf2c295f2;
    wexpected[9] <= 32'h7a96b943;
    wexpected[10] <= 32'h5935807a;
    wexpected[11] <= 32'h7359f67f;
    wexpected[12] <= 32'h3d80477d;
    wexpected[13] <= 32'h4716fe3e;
    wexpected[14] <= 32'h1e237e44;
    wexpected[15] <= 32'h6d7a883b;
    wexpected[16] <= 32'hef44a541;
    wexpected[17] <= 32'ha8525b7f;
    wexpected[18] <= 32'hb671253b;
    wexpected[19] <= 32'hdb0bad00;
    wexpected[20] <= 32'hd4d1c6f8;
    wexpected[21] <= 32'h7c839d87;
    wexpected[22] <= 32'hcaf2b8bc;
    wexpected[23] <= 32'h11f915bc;
    wexpected[24] <= 32'h6d88a37a;
    wexpected[25] <= 32'h6d88a37a;
    wexpected[26] <= 32'h6d88a37a;
    wexpected[27] <= 32'hca0093fd;
    wexpected[28] <= 32'h4e54f70e;
    wexpected[29] <= 32'h5f5fc9f3;
    wexpected[30] <= 32'h84a64fb2;
    wexpected[31] <= 32'h4ea6dc4f;
    wexpected[32] <= 32'head27321;
    wexpected[33] <= 32'hb58dbad2;
    wexpected[34] <= 32'h312bf560;
    wexpected[35] <= 32'h7f8d292f;
    wexpected[36] <= 32'hac7766f3;
    wexpected[37] <= 32'h19fadc21;
    wexpected[38] <= 32'h28d12941;
    wexpected[39] <= 32'h575c006e;
    wexpected[40] <= 32'hd014f9a8;
    wexpected[41] <= 32'hc9ee2589;
    wexpected[42] <= 32'he13f0cc8;
    wexpected[43] <= 32'hb6630ca6;

    // Alternate test case from Appendix C.1
    //      key       <= 128'h000102030405060708090A0B0C0D0E0F;
    //      plaintext <= 128'h00112233445566778899AABBCCDDEEFF;
    //      expected  <= 128'h69C4E0D86A7B0430D8CDB78070B4C55A;
    end
    
    // generate clock and load signals
    always begin
			clk = 1'b0; #5;
			clk = 1'b1; #5;
		end


    initial begin
      reset = 1'b1; #22; reset = 1'b0; //Pulse rest to start conversion      
      enable = 1'b1; #22; enable = 1'b0; //Pulse load to start conversion

    end

    // wait until done and then check the result
    always @(posedge clk) begin
      if (start) begin
        if (w == wexpected)
            $display("Testbench ran successfully");
        else $display("Error: w = %p, wexpected %p",
            w, wexpected);
        $stop();
      end
    end
    
endmodule