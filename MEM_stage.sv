module MEM(	
		input wire EX_branch_flag,	// For B_type operations
		input wire MEM_write_flag,	// For S_type operations
		input wire reset,		// To reset data_MEM_block at the beginning
		input wire [4:0] ALU_operation,

		input wire [31:0] EX_ALUout,
		input wire [31:0] EX_rs2,

		output reg [31:0] MEM_LMD,
		output wire [31:0] MEM_ALUout);

	//Data memory, contrary to the instruction memory of the IF stage.
	reg [31:0] data_MEM_block [0 : 255];

	assign MEM_ALUout = EX_ALUout;

always_comb begin	// Data memory update logic

	if(reset) begin		// This is for the reset or initialization of the data memory.

		for (int i = 0; i < 255; i++) begin	//This module was compiled with warnings till this for loop for initialization was addedd.

			data_MEM_block[i] = i * 30;	//You can really use any values you want to initialize the data memory.
		end

	end else if(MEM_write_flag) begin // Memory store and load logic

		case(ALU_operation)	
			5'd11:	data_MEM_block[EX_ALUout][7:0] = EX_rs2[7:0];		//Store byte
			5'd12:	data_MEM_block[EX_ALUout][15:0] = EX_rs2[15:0];		//Store half
			5'd13:	data_MEM_block[EX_ALUout] = EX_rs2;			//Store word
				
			default: data_MEM_block = data_MEM_block;
		endcase
	end else data_MEM_block = data_MEM_block;		
end

assign MEM_LMD = (ALU_operation == 5'd0 || ALU_operation == 5'd24) ? data_MEM_block[EX_ALUout] : 32'bx; 		//Load word

endmodule
