`include "immediate_generator.sv"

module ID(
	input clk,
	input [31:0] IF_IR, WB_out,
	input reset, RegBank_en,

	output reg [31:0] ID_rs2,
	output reg [31:0] ID_rs1,
	output reg [31:0] ID_imm,

	output reg[4:0] ID_rd);
	
	
	// Encoding of the bits of OPCode of the instruction

	localparam I_load_type = 7'b0000011; // = 3
	localparam I_type = 7'b0010011; // = 19
	localparam U_ADD_type = 7'b0010111; // = 23
	localparam S_type = 7'b0100011; // = 35
	localparam R_type = 7'b0110011; // = 51
	localparam U_LOAD_type = 7'b0110111; // = 55
	localparam B_type = 7'b1100011; // = 99
	localparam J_type = 7'b1101111; // = 111


reg [31:0] [31:0] RegBank;


// Output destination
assign ID_rd = IF_IR[11:7];


always @ ( posedge clk or posedge reset) begin

if(reset) begin		// This is for the reset or initialization of the RegBank
		for (int i = 0; i <= 9; i++) begin

			RegBank[i] = i;

		end

		for (int i = 10; i <= 19; i++) begin

			RegBank[i] = -i;

		end
		
		for (int i = 20; i < 32; i++) begin

			RegBank[i] = i;

		end

	end else if (RegBank_en)

		RegBank[ID_rd] = WB_out;

	else  RegBank = RegBank;
end

// Output operands
assign ID_rs2 = RegBank[IF_IR[24:20]];
assign ID_rs1 = RegBank[IF_IR[19:15]];
imm_gen Emily(.IF_IR(IF_IR), .imm(ID_imm));


endmodule