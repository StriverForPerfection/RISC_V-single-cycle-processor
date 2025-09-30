module controller(input wire [6:0] IF_op, IF_funct7, input wire [2:0] IF_funct3,

		output reg imm_sel,	//Flag to select the second operand for the ALU operation.
		output reg[4:0] ALU_operation,

		output reg MEM_write_flag,	//Flag for whether to write to or read from MEM.

 		output reg WB_LMD_flag,		//Flag for whether WB outputs LMD or not.

		output reg WB_ALUout_flag,      //Flag for whether WB outputs EX_ALUout or not.
						// (it won't be written if the operation is STORE or BRANCH).

		output reg RegBank_en		// Enable for writing to the RegBank.
);

// Encoding of the bits of OPCode of the instruction

	localparam I_load_type = 	7'b0000011; // = 3
	localparam I_type = 		7'b0010011; // = 19
	localparam U_ADD_type = 	7'b0010111; // = 23
	localparam S_type = 		7'b0100011; // = 35
	localparam R_type = 		7'b0110011; // = 51
	localparam U_LOAD_type = 	7'b0110111; // = 55
	localparam B_type = 		7'b1100011; // = 99
	localparam J_type = 		7'b1101111; // = 111

assign RegBank_en = (WB_LMD_flag || WB_ALUout_flag); //If neither the EX_ALUout or MEM_LMD 
				// values need to be written into the RegBank, don't enable writing to it. In addition, in this case WB outputs 32'bx.

always_comb begin

	imm_sel = 1'b0;
	MEM_write_flag = 1'b0;	//Means mode is set to read from memory when it equals zero.
	
	WB_LMD_flag = 1'b0;
	WB_ALUout_flag = 1'b1;

	case(IF_op)

		I_load_type, I_type, U_ADD_type, U_LOAD_type, S_type, B_type, J_type:	imm_sel = 1'b1;
		default: imm_sel = 1'b0;

	endcase

	case(IF_op)

		I_load_type: begin
			ALU_operation = (IF_funct3 == 3'b010) ? 5'd0 : 5'dx;
			MEM_write_flag = 1'b0;
			WB_LMD_flag = 1'b1;
			WB_ALUout_flag = 1'b0;
		end

		I_type: begin

			case(IF_funct3)

				3'b000: ALU_operation = 5'd1;
				3'b001: ALU_operation = 5'd2;
				3'b010: ALU_operation = 5'd3;
				3'b011: ALU_operation = 5'd4;
				3'b100: ALU_operation = 5'd5;
				3'b101: ALU_operation = (IF_funct7[5] == 0) ? 5'd6 : 5'd7;
				3'b110: ALU_operation = 5'd8;
				3'b111: ALU_operation = 5'd9;
				default: ALU_operation = 5'bx;
			endcase
		end

		U_ADD_type: begin
			ALU_operation = 5'd10;
			MEM_write_flag = 1'b0;
		end

		S_type: begin

			MEM_write_flag = 1'b1;
			WB_LMD_flag = 1'b0;
			WB_ALUout_flag = 1'b0;	//Result isn't stored in RegBank for Stores.

			case(IF_funct3)
				
				3'b000: ALU_operation = 5'd11;
				3'b001: ALU_operation = 5'd12;
				3'b010: ALU_operation = 5'd13;
				default: ALU_operation = 5'bx;
			endcase	
		end
		R_type: begin

			case(IF_funct3)

				3'b000: ALU_operation = (IF_funct7[5] == 0) ? 5'd14 : 5'd15;
				3'b001: ALU_operation = 5'd16;
				3'b010: ALU_operation = 5'd17;
				3'b011: ALU_operation = 5'd18;
				3'b100: ALU_operation = 5'd19;
				3'b101: ALU_operation = (IF_funct7[5] == 0) ? 5'd20 : 5'd21;
				3'b110: ALU_operation = 5'd22;
				3'b111: ALU_operation = 5'd23;
				default: ALU_operation = 5'bx;

			endcase
		end

		U_LOAD_type: begin

			ALU_operation = 5'd24;
			MEM_write_flag = 1'b0;
			WB_LMD_flag = 1'b1;
		end

		B_type: begin

			MEM_write_flag = 1'b0;
			WB_LMD_flag = 1'b0;
			WB_ALUout_flag = 1'b0;	//Result isn't stored to register on branches.
			imm_sel = 1'b0;

			case(IF_funct3)

				3'b000: ALU_operation = 5'd25;
				3'b001: ALU_operation = 5'd26;
				3'b100: ALU_operation = 5'd27;
				3'b101: ALU_operation = 5'd28;
				3'b110: ALU_operation = 5'd29;
				3'b111: ALU_operation = 5'd30;
				default: ALU_operation = 5'bx;
			endcase
		end
		
		J_type: begin
			MEM_write_flag = 1'b0;
			WB_LMD_flag = 1'b0;
			WB_ALUout_flag = 1'b1;	//PC + 1 is stored to a register on jumps.

			ALU_operation = 5'd31;
		end

		default: ALU_operation = 5'bx;
	endcase

end

endmodule
