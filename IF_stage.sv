module IF(input clk, reset, EX_branch_flag, EX_jump_flag,

	input [31:0] EX_ALUout, EX_jump_addr,
 	output [31:0] IF_IR,
	output wire [6:0] IF_op, IF_funct7,
	output wire [2:0] IF_funct3,
	output wire[31:0] IF_PC);

reg [31:0] PC, PC_plus; 	//Process counter 
reg [31:0] IR_Mem [0:255];	// The memory block containing all the instruction registers (IRs) that shall be executed.

always @ (posedge clk) begin
	PC <= PC_plus;
end

		assign PC_plus = 	reset ? 32'b0 :		// If there's a reset signal. let PC equal zero.
			EX_branch_flag 	? EX_ALUout: 		// If there's a branch condition (which is determined in the EX stage),
			EX_jump_flag 	? EX_jump_addr: 	// the next address to the PC will be the address calculated by the ALU
					PC + 1;			
			
assign IF_IR = IR_Mem[PC];	
assign IF_PC = PC;

//Signals for the controller

assign IF_op = IF_IR[6:0];	assign IF_funct3 = IF_IR[14:12];	assign IF_funct7 = IF_IR[31:25];

endmodule
