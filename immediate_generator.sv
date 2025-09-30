module imm_gen(input [31:0] IF_IR,
		output reg [31:0] imm);

// Encoding of the bits of OPCode of the instruction

	localparam I_load_type = 	7'b0000011; // = 3
	localparam I_type = 		7'b0010011; // = 19
	localparam U_ADD_type = 	7'b0010111; // = 23
	localparam S_type = 		7'b0100011; // = 35
	localparam R_type = 		7'b0110011; // = 51
	localparam U_LOAD_type = 	7'b0110111; // = 55
	localparam B_type = 		7'b1100011; // = 99
	localparam J_type = 		7'b1101111; // = 111

always_comb begin
	
	case(IF_IR[6:0])	//assign ALU operation type according to the OPCode.
		
		I_load_type:		imm = (IF_IR[14:12] == 3'b010) ? { {20{IF_IR[31]}}, IF_IR[31:20]} : 32'bx;
		I_type:			imm =  { {20{IF_IR[31]}}, IF_IR[31:20]};
		U_ADD_type, U_LOAD_type: imm = {IF_IR[31:12], 12'b0}; 
		S_type:			imm = { {20{IF_IR[31]}}, IF_IR[31:25], IF_IR[11:7]};
		B_type: 		imm = { {20{IF_IR[31]}}, IF_IR[7], IF_IR[30:25], IF_IR[11:8], 1'b0};
		J_type:			imm = { {12{IF_IR[31]}}, IF_IR[19:12], IF_IR[20], IF_IR[30:21], 1'b0};
		default: 		imm = 32'bx;

	endcase
	
end

endmodule