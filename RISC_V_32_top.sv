`include "IF_stage.sv"
`include "ID_stage.sv"
`include "EX_stage.sv"
`include "MEM_stage.sv"
`include "WB_stage.sv"
`include "control_unit.sv"

module RISC_top(input clk, reset);

						//// IF stage and port declarations ////
	wire EX_branch_flag, EX_jump_flag;
	wire [31:0] EX_ALUout, EX_jump_addr;
 	wire [31:0] IF_IR;
	wire [6:0] IF_op, IF_funct7;
	wire [2:0] IF_funct3;
	wire [31:0] IF_PC;

IF Fady(
.clk(clk),
.reset(reset),
.EX_branch_flag(EX_branch_flag),
.EX_jump_flag(EX_jump_flag), .EX_jump_addr(EX_jump_addr),
.EX_ALUout(EX_ALUout),

.IF_IR(IF_IR),
.IF_op(IF_op),
.IF_funct7(IF_funct7),
.IF_funct3(IF_funct3),
.IF_PC(IF_PC)
);
						//// ID stage and port declarations ////

	wire [31:0] WB_out;
	wire RegBank_en;

	wire [31:0] ID_rs2;
	wire [31:0] ID_rs1;
	wire [31:0] ID_imm;

	wire [4:0] ID_rd;

ID Darly(
.clk(clk),
.IF_IR(IF_IR),
.WB_out(WB_out),
.reset(reset),
.RegBank_en(RegBank_en),

.ID_rs2(ID_rs2),
.ID_rs1(ID_rs1),
.ID_imm(ID_imm),
.ID_rd(ID_rd)
);
						//// ID stage and port declaration ////

	wire imm_sel; 			// Selector for the second operand for the ALU
	wire [4:0] ALU_operation;	// Selector for the ALU operation
	wire [31:0] EX_rs2;

EX Xavier(
.IF_PC(IF_PC),
.ID_rs2(ID_rs2),
.ID_rs1(ID_rs1),
.ID_imm(ID_imm),
.imm_sel(imm_sel),
.ALU_operation(ALU_operation),

.EX_branch_flag(EX_branch_flag),
.EX_jump_flag(EX_jump_flag),
.EX_ALUout(EX_ALUout),
.EX_jump_addr(EX_jump_addr),
.EX_rs2(EX_rs2)
);

						//// MEM stage and port declaration ////

		wire [31:0] MEM_LMD;
		wire [31:0] MEM_ALUout;
		wire MEM_write_flag;

MEM Mason(
.EX_branch_flag(EX_branch_flag),
.MEM_write_flag(MEM_write_flag),
.reset(reset),
.ALU_operation(ALU_operation),
.EX_ALUout(EX_ALUout),
.EX_rs2(EX_rs2),

.MEM_LMD(MEM_LMD),
.MEM_ALUout(MEM_ALUout)
);

						//// WB stage and port declaration ////
	wire WB_LMD_flag, WB_ALUout_flag;

WB Willy(
.WB_LMD_flag(WB_LMD_flag),
.WB_ALUout_flag(WB_ALUout_flag),
.ID_rd(ID_rd),
.EX_ALUout(EX_ALUout),
.MEM_LMD(MEM_LMD),
.MEM_ALUout(MEM_ALUout),
.WB_out(WB_out)
);

controller Cayley(
.IF_op(IF_op),
.IF_funct7(IF_funct7),
.IF_funct3(IF_funct3),
.imm_sel(imm_sel),
.ALU_operation(ALU_operation),
.MEM_write_flag(MEM_write_flag),
.WB_LMD_flag(WB_LMD_flag),
.WB_ALUout_flag(WB_ALUout_flag),
.RegBank_en(RegBank_en)
);

endmodule
