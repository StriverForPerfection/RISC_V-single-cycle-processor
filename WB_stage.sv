module WB(
	input wire WB_LMD_flag, WB_ALUout_flag,
	input wire [4:0] ID_rd,
	input wire [31:0] EX_ALUout,

	input wire [31:0] MEM_LMD,
	input wire [31:0] MEM_ALUout,
	output reg [31:0] WB_out);

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
	
	if(WB_LMD_flag)

		WB_out = MEM_LMD;

	else if (WB_ALUout_flag)

		WB_out = EX_ALUout;

	else WB_out = 32'bx;

end

endmodule
