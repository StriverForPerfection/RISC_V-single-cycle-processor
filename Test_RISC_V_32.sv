`include "RISC_V_32_top.sv"

module test_MIPS;

reg clk, reset;

	RISC_top Rocky(.clk(clk), .reset(reset));

initial begin
clk = 1'b0; reset = 1'b1;
 
#30 reset = 1'b0;	//This line is repeated here such that I can make reset
		//equal to zero after some time without being in the repeat cycle.
end

initial begin
	forever begin

		#20 clk = ~clk; 
	end
end


// Encoding of the bits of OPCode of the instruction

	localparam I_load_type = 	7'b0000011; // = 3
	localparam I_type = 		7'b0010011; // = 19
	localparam U_ADD_type = 	7'b0010111; // = 23
	localparam S_type = 		7'b0100011; // = 35
	localparam R_type = 		7'b0110011; // = 51
	localparam U_LOAD_type = 	7'b0110111; // = 55
	localparam B_type = 		7'b1100011; // = 99
	localparam J_type = 		7'b1101111; // = 111

initial begin
	// I_LOAD_type tests
	Rocky.Fady.IR_Mem[0] = {12'd5 ,5'd5 , 3'b010, 5'd24, I_load_type}; //ALU_op0: Load the tenth value from memory into reg 24.

	//I_type tests
	Rocky.Fady.IR_Mem[1] = {12'd10 ,5'd3 , 3'b000, 5'd25, I_type};		//ALU_op1: Add 10 to value at reg3 and store the result in reg 25
	Rocky.Fady.IR_Mem[2] = {12'd7 ,5'd25 , 3'b001, 5'd26, I_type};		//ALU_op2: Shift left logically by 7 the value at reg3 and store the result in reg 26
	
	//less than signed tests
	Rocky.Fady.IR_Mem[3] = {12'd10 ,5'd3 , 3'b010, 5'd25, I_type};			//ALU_op3: Set reg25 to 1 if reg3 < 10
	Rocky.Fady.IR_Mem[4] = {12'b111111111101 ,5'd1 , 3'b010, 5'd25, I_type};	//ALU_op3: Set reg25 to 1 if reg1 < -3
	Rocky.Fady.IR_Mem[5] = {12'd10 ,5'd14 , 3'b010, 5'd25, I_type};			//ALU_op3: Set reg25 to 1 if reg14 < 10 (reg14 = -14)
	Rocky.Fady.IR_Mem[6] = {12'b111111111101 ,5'd15, 3'b010, 5'd25, I_type};	//ALU_op3: Set reg25 to 1 if reg15 < -3 (reg15 = -15)
	
	//less than unsigned tests
	Rocky.Fady.IR_Mem[7] = {12'd10 ,5'd3 , 3'b011, 5'd25, I_type};		//ALU_op4: Set reg25 to 1 if reg3 < 10
	Rocky.Fady.IR_Mem[8] = {12'd10 ,5'd12 , 3'b011, 5'd25, I_type};		//ALU_op4: Set reg25 to 1 if reg12 < 10 (Reg12 = -12). This shall yield 
										//a false result because of using a negative num for an unsig operation.

	Rocky.Fady.IR_Mem[9] = {12'd10 ,5'd3 , 3'b100, 5'd25, I_type};		//ALU_op5: XOR 10 to value at reg3 and store in reg 25

	Rocky.Fady.IR_Mem[10] = {12'd5 ,5'd3 , 3'b101, 5'd25, I_type};		//ALU_op6: Shift right logically by 5 the value at reg3 and store the result in reg 25
	Rocky.Fady.IR_Mem[11] = {7'b0100000, 5'd5 ,5'd18 , 3'b101, 5'd25, I_type};	//ALU_op7: Shift right arithmetically by 5 the value at reg18 and store the result in reg 25

	Rocky.Fady.IR_Mem[12] = {12'd10 ,5'd3 , 3'b110, 5'd25, I_type};		//ALU_op8: OR 10 to value at reg3 and store in reg 25
	Rocky.Fady.IR_Mem[13] = {12'd10 ,5'd3 , 3'b111, 5'd25, I_type};		//ALU_op9: AND 10 to value at reg3 and store in reg 25
	
	//U_ADD type test
	Rocky.Fady.IR_Mem[14] = {20'd128, 5'd25, U_ADD_type};			//ALU_op10: ADD 128 to PC and store the result in reg 25

	//S_type
	Rocky.Fady.IR_Mem[15] = {7'b0, 5'd13, 5'd5, 3'b000, 5'd3, S_type};		//ALU_op11: store reg13[7:0] at address (3 + reg5) of memory
	Rocky.Fady.IR_Mem[16] = {7'b0, 5'd13, 5'd5, 3'b001, 5'd3, S_type};		//ALU_op12: store reg13[15:0] at address (3 + reg5) of memory
	Rocky.Fady.IR_Mem[17] = {7'b0, 5'd13, 5'd5, 3'b010, 5'd3, S_type};		//ALU_op13: store reg13[31:0] at address (3 + reg5) of memory
	
	//R_type
	Rocky.Fady.IR_Mem[18] = {7'b0, 5'd8, 5'd9, 3'b000, 5'd25, R_type};		//ALU_op14: ADD reg8 to reg9 and store in reg25
	Rocky.Fady.IR_Mem[19] = {7'b0100000, 5'd8, 5'd9, 3'b000, 5'd25, R_type};	//ALU_op15: SUB reg8 from reg9 and store in reg25
	Rocky.Fady.IR_Mem[20] = {7'b0000000, 5'd8, 5'd9, 3'b001, 5'd25, R_type};	//ALU_op16: shift left logically reg9 by reg8

	//less than signed tests
	Rocky.Fady.IR_Mem[21] = {7'b0, 5'd8, 5'd9, 3'b010, 5'd25, R_type};	//ALU_op17: Set reg25 to 1 if reg9 < reg8
	Rocky.Fady.IR_Mem[22] = {7'b0, 5'd11, 5'd9, 3'b010, 5'd25, R_type};	//ALU_op17: Set reg25 to 1 if reg9 < reg11
	Rocky.Fady.IR_Mem[23] = {7'b0, 5'd9, 5'd11, 3'b010, 5'd25, R_type};	//ALU_op17: Set reg25 to 1 if reg11 < reg9 (reg11 = -11)
	Rocky.Fady.IR_Mem[24] = {7'b0, 5'd12, 5'd11, 3'b010, 5'd25, R_type};	//ALU_op17: Set reg25 to 1 if reg11 < reg12 (reg12 = -12)
	
	//less than unsigned tests
	Rocky.Fady.IR_Mem[25] = {7'b0, 5'd8, 5'd9, 3'b011, 5'd25, R_type};		//ALU_op18: Set reg25 to 1 if reg9 < reg8
	Rocky.Fady.IR_Mem[26] = {7'b0, 5'd3, 5'd2, 3'b011, 5'd25, R_type};  		//ALU_op18: Set reg25 to 1 if reg2 < reg3

	Rocky.Fady.IR_Mem[27] = {7'b0, 5'd5, 5'd15, 3'b100, 5'd25, R_type};  		//ALU_op19: Set reg25 to reg5 ^ reg15
	Rocky.Fady.IR_Mem[28] = {7'b0, 5'd8, 5'd10, 3'b101, 5'd25, R_type};  		//ALU_op20: shift right logically reg10 by reg8
	Rocky.Fady.IR_Mem[29] = {7'b0100000, 5'd3, 5'd2, 3'b101, 5'd25, R_type};  	//ALU_op21: shift right arithmetically reg3 by reg2
	Rocky.Fady.IR_Mem[30] = {7'b0, 5'd3, 5'd2, 3'b110, 5'd25, R_type};  		//ALU_op22: Set reg25 to reg2 | reg3
	Rocky.Fady.IR_Mem[31] = {7'b0, 5'd3, 5'd2, 3'b111, 5'd25, R_type};  		//ALU_op23: Set reg25 to reg2 & reg3
	
	//U_LOAD_type
	Rocky.Fady.IR_Mem[32] = {20'd1, 5'd25, U_LOAD_type};	  	//ALU_op24: load the value at the 2**12 th MEM location into reg 25

	//B_type		//EX_branch_flag follows the pattern 0110 1001 0110 1001. If this pattern is observed in the waveform, the 
				// branch instructions work properly.

	//Branch if equal
	Rocky.Fady.IR_Mem[33] = {7'b0, 5'd3, 5'd2, 3'b000, 5'b10000, B_type}; //ALU_op25: branch if reg 3 = reg2 to PC + 16. EX_branch_flag = 0
	Rocky.Fady.IR_Mem[34] = {7'b0, 5'd3, 5'd3, 3'b000, 5'b11000, B_type}; //ALU_op25: branch if reg 3 = reg3 to PC + 24. EX_branch_flag = 1
	
	//Branch if not equal
	Rocky.Fady.IR_Mem[58] = {7'b0, 5'd3, 5'd2, 3'b001, 5'b10000, B_type}; //ALU_op26: branch if reg 3 != reg2  to PC + 16. EX_branch_flag = 1
	Rocky.Fady.IR_Mem[74] = {7'b0, 5'd3, 5'd3, 3'b001, 5'b10000, B_type}; //ALU_op26: branch if reg 3 != reg3  to PC + 16. EX_branch_flag = 0

	//Branch if < 
	Rocky.Fady.IR_Mem[75] = {7'b0, 5'd4, 5'd2, 3'b100, 5'b10000, B_type}; //ALU_op27: branch if reg 2 < reg4  to PC + 16. EX_branch_flag = 1
	Rocky.Fady.IR_Mem[91] = {7'b0, 5'd4, 5'd5, 3'b100, 5'b10000, B_type}; //ALU_op27: branch if reg 5 < reg4  to PC + 16. EX_branch_flag = 0
	Rocky.Fady.IR_Mem[92] = {7'b0, 5'd13, 5'd2, 3'b100, 5'b10000, B_type}; //ALU_op27: branch if reg 2 < reg13  to PC + 16. EX_branch_flag = 0
	Rocky.Fady.IR_Mem[93] = {7'b0, 5'd2, 5'd13, 3'b100, 5'b10000, B_type}; //ALU_op27: branch if reg 13 < reg2  to PC + 16. EX_branch_flag = 1

	//Branch if >= 
	Rocky.Fady.IR_Mem[109] = {7'b0, 5'd4, 5'd2, 3'b101, 5'b10000, B_type}; //ALU_op28: branch if reg 2 >= reg4  to PC + 16. EX_branch_flag = 0
	Rocky.Fady.IR_Mem[110] = {7'b0, 5'd4, 5'd5, 3'b101, 5'b10000, B_type}; //ALU_op28: branch if reg 5 >= reg4  to PC + 16. EX_branch_flag = 1
	Rocky.Fady.IR_Mem[126] = {7'b0, 5'd13, 5'd2, 3'b101, 5'b10000, B_type}; //ALU_op28: branch if reg 2 >= reg13  to PC + 16. EX_branch_flag = 1
	Rocky.Fady.IR_Mem[142] = {7'b0, 5'd2, 5'd13, 3'b101, 5'b10000, B_type}; //ALU_op28: branch if reg 13 >= reg2  to PC + 16. EX_branch_flag = 0

	//Branch if < unsigned
	Rocky.Fady.IR_Mem[143] = {7'b0, 5'd4, 5'd2, 3'b110, 5'b10000, B_type}; //ALU_op29: branch if reg 2 < reg4  to PC + 16. EX_branch_flag = 1
	Rocky.Fady.IR_Mem[159] = {7'b0, 5'd4, 5'd5, 3'b110, 5'b10000, B_type}; //ALU_op29: branch if reg 5 < reg4  to PC + 16. EX_branch_flag = 0
	//Branch if >= unsigned
	Rocky.Fady.IR_Mem[160] = {7'b0, 5'd4, 5'd2, 3'b111, 5'b10000, B_type}; //ALU_op30: branch if reg 2 >= reg4  to PC + 16. EX_branch_flag = 0
	Rocky.Fady.IR_Mem[161] = {7'b0, 5'd4, 5'd5, 3'b111, 5'b10000, B_type}; //ALU_op30: branch if reg 5 >= reg4  to PC + 16. EX_branch_flag = 1
	
	//J_type
	Rocky.Fady.IR_Mem[177] = {20'b00000000001000000000, 5'd25, J_type};	//ALU_op31: set PC to PC + 2; PC + 1 will be stored at reg26
end
endmodule

