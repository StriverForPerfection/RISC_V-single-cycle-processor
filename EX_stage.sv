module EX(
	//Input variables from the ID stage
	input wire [31:0] IF_PC,

	input wire [31:0] ID_rs2,
	input wire [31:0] ID_rs1,
	input wire[31:0] ID_imm,
	
	input imm_sel, 			// Selector for the second operand for the ALU
	input [4:0] ALU_operation,	// Selector for the ALU operation

	output reg EX_branch_flag,	// For B_type operations
	output reg EX_jump_flag,	// For J_type operations

	output reg [31:0] EX_ALUout, EX_jump_addr,
	output wire [31:0] EX_rs2);
	

	// Encoding of the bits of OPCode of the instruction

	localparam I_load_type = 7'b0000011; // = 3
	localparam I_type = 7'b0010011; // = 19
	localparam U_ADD_type = 7'b0010111; // = 23
	localparam S_type = 7'b0100011; // = 35
	localparam R_type = 7'b0110011; // = 51
	localparam U_LOAD_type = 7'b0110111; // = 55
	localparam B_type = 7'b1100011; // = 99
	localparam J_type = 7'b1101111; // = 111


//Operand choice
reg [31:0] operand_B;
	
assign operand_B = imm_sel ? ID_imm : ID_rs2;
assign EX_rs2 = ID_rs2;		//Required for S_type instructions to be stored at the calculated memory location.


always_comb begin
	
	EX_branch_flag = 1'b0;
	EX_jump_flag = 1'b0;
	EX_jump_addr = 32'bx;

	case(ALU_operation)

	// I_LOAD_type //
	5'd0: EX_ALUout = ID_rs1 + operand_B;				////load_word

	// I_type //
	5'd1: EX_ALUout = ID_rs1 + operand_B;				////add immediate

	5'd2: EX_ALUout = (ID_rs1 << operand_B[4:0]);			////shift left logical immediate

	5'd3: begin							//// Set less than imm (i.e.: signed)

		if (ID_rs1[31] == 0 &&  operand_B[31] == 0) //If both values of the inequality are positive, perform a regular comparison.

			EX_ALUout = (ID_rs1 < operand_B);	

		else if (ID_rs1[31] == 1 &&  operand_B[31] == 0)	//IF ID_rs1 is negative and imm is positive, surely the less than
									//flag is 1.
			EX_ALUout = 32'd1;

		else if (ID_rs1[31] == 0 &&  operand_B[31] == 1) 	//IF ID_rs1 is positive and imm is negative, surely the less than
			
			EX_ALUout = 32'd0;				// flag is 0.

		else		//Wheteher both values are negative or positive, the comparison operator still gives correct results.
		
			EX_ALUout = (ID_rs1 < operand_B);		
	end				
	5'd4: EX_ALUout = (ID_rs1 < operand_B);				//// Set less than imm unsigned

	5'd5: EX_ALUout = ID_rs1 ^ operand_B;				//// Xor immediate

	5'd6: EX_ALUout = ID_rs1 >> operand_B[4:0];			//// Shift right logical immediate
	5'd7: EX_ALUout = $signed(ID_rs1) >>> operand_B[4:0];			//// Shift right arithmetic immediate
	5'd8: EX_ALUout = ID_rs1 | operand_B;				//// Or immedaite
	5'd9: EX_ALUout = ID_rs1 & operand_B;				//// And immediate
	
	// U type //
	5'd10: EX_ALUout = {operand_B[31:12], 1'b0} + IF_PC;

	// S-type // (all outputs are addresses for storage in memory)
	5'd11: EX_ALUout = ID_rs1 + operand_B;				//// Store byte
	5'd12: EX_ALUout = ID_rs1 + operand_B;				//// Store half
	5'd13: EX_ALUout = ID_rs1 + operand_B;				//// Store word

	// R_type // 
	5'd14: EX_ALUout = ID_rs1 + operand_B;				//// Add
	5'd15: EX_ALUout = ID_rs1 - operand_B;				//// Sub
	5'd16: EX_ALUout = ID_rs1 << operand_B[4:0];			//// Shift left logical

	5'd17: begin							//// Set less than (i.e.: signed)

		if (ID_rs1[31] == 0 &&  operand_B[31] == 0) //If both values of the inequality are positive, perform a regular comparison.

			EX_ALUout = (ID_rs1 < operand_B);	

		else if (ID_rs1[31] == 1 &&  operand_B[31] == 0)	//IF ID_rs1 is negative and ID_rs_2 is positive, surely the less 
									// than flag is 1
			EX_ALUout = 32'd1;

		else if (ID_rs1[31] == 0 &&  operand_B[31] == 1) //IF ID_rs1 is positive and ID_rs_2 is negative, surely the less than
			
			EX_ALUout = 32'd0;				// flag is 0

		else begin			//Wheteher both values are negative or positive, the comparison operator still gives correct results.
		
			EX_ALUout = (ID_rs1 < operand_B);	
		end	
	end

	5'd18: EX_ALUout = (ID_rs1 < operand_B);			//// Set less than unsigned
	5'd19: EX_ALUout = ID_rs1 ^ operand_B;				//// XOR
	5'd20: EX_ALUout = ID_rs1 >> operand_B[4:0];			//// Shift right logical
	5'd21: EX_ALUout = $signed(ID_rs1) >>> operand_B[4:0];			//// Shift right arithmetic
	5'd22: EX_ALUout = ID_rs1 | operand_B;				//// OR
	5'd23: EX_ALUout = ID_rs1 & operand_B;				//// AND
	
	// U_LOAD_type //
	5'd24: EX_ALUout = {operand_B[31:1], 1'b0};			//// Load upper immediate

	// B_type //
	5'd25: begin
		EX_ALUout = (ID_rs1 == operand_B) ? IF_PC + ID_imm : 32'bx;	//// Branch if =
		EX_branch_flag = (ID_rs1 == operand_B) ? 1'b1 : 1'b0;
	end

	5'd26: begin
		EX_ALUout = (ID_rs1 != operand_B) ? IF_PC + ID_imm : 32'bx;	//// Branch if not =
		EX_branch_flag = (ID_rs1 != operand_B) ? 1'b1 : 1'b0;
	end

	5'd27: begin							//// Branch if < (signed)

		if (ID_rs1[31] == 0 &&  operand_B[31] == 0) begin //If both values of the inequality are +ve, perform a regular comparison.

			EX_ALUout = (ID_rs1 < operand_B) ? IF_PC + ID_imm : 32'bx;
			EX_branch_flag = (ID_rs1 < operand_B) ? 1'b1 : 1'b0;

		end else if (ID_rs1[31] == 0 &&  operand_B[31] == 1)	begin //IF ID_rs1 is positive and ID_rs_2 is negative, surely the 
										// flag is 1.
			
			EX_ALUout = 32'bx;;
			EX_branch_flag = 1'b0;

		end else if (ID_rs1[31] == 1 &&  operand_B[31] == 0) begin 	//IF ID_rs1 is negative and ID_rs_2 is positive, surely the
										// flag is 0.
			EX_ALUout = IF_PC + ID_imm;
			EX_branch_flag = 1'b1;				

		end else begin	//Wheteher both values are negative or positive, the comparison operator still gives correct results.
		
			EX_ALUout = (ID_rs1 < operand_B) ? IF_PC + ID_imm : 32'bx;
			EX_branch_flag = (ID_rs1 < operand_B) ? 1'b1 : 1'b0;	
		end
	end

	5'd28: begin							//// Branch if > or = (signed)

		if (ID_rs1[31] == 0 &&  operand_B[31] == 0) begin //If both values of the inequality are +ve, perform a regular comparison.

			EX_ALUout = (ID_rs1 > operand_B || (ID_rs1 == operand_B)) ? IF_PC + ID_imm : 32'bx;
			EX_branch_flag = (ID_rs1 > operand_B || (ID_rs1 == operand_B)) ? 1'b1 : 1'b0;

		end else if (ID_rs1[31] == 0 &&  operand_B[31] == 1) begin //IF ID_rs1 is positive and ID_rs_2 is negative, surely the >= 
									// than flag is 0.
			
			EX_ALUout = IF_PC + ID_imm;
			EX_branch_flag = 1'b1;

		end else if (ID_rs1[31] == 1 &&  operand_B[31] == 0) begin //IF ID_rs1 is negative and ID_rs_2 is positive, surely the >=
			
			EX_ALUout = 32'bx;
			EX_branch_flag = 1'b0;				// flag is 1.

		end else begin	//Wheteher both values are negative or positive, the comparison operator still gives correct results.
		
			EX_ALUout = (ID_rs1 > operand_B || (ID_rs1 == operand_B)) ? IF_PC + ID_imm : 32'bx;
			EX_branch_flag = (ID_rs1 > operand_B || (ID_rs1 == operand_B)) ? 1'b1 : 1'b0;	
		end
	end

	5'd29: begin
		EX_ALUout = (ID_rs1 < operand_B) ? IF_PC + ID_imm : 32'bx;	//// Branch if < (unsigned)
		EX_branch_flag = (ID_rs1 < operand_B) ? 1'b1 : 1'b0;
	end
	5'd30: begin
		EX_ALUout = ((ID_rs1 > operand_B) || (ID_rs1 == operand_B)) ? IF_PC + ID_imm : 32'bx;	//// Branch if > or = (unsigned)
		EX_branch_flag = ((ID_rs1 > operand_B) || (ID_rs1 == operand_B)) ? 1'b1 : 1'b0;
	end
	5'd31:	begin

		EX_ALUout = IF_PC + 1;	//Not + 4 because my Memory design is word addressable.	//// Jump and Link
		EX_jump_addr = IF_PC + ID_imm;	

		EX_jump_flag = 1'b1;
	end

	default: EX_ALUout = 32'bx;

	endcase
end

endmodule
