# RISC_V-single-cycle-processor

## What’s RISC-V?

RISC-V is an open-source instruction set architecture (ISA) that allows users to design custom processors tailored to their specific needs and targets in PPA. An ISA allows designers to define how a processor behaves and what operations it can and can’t do.

	RISC stands for “Reduced Instruction Set Computing,” meaning that processors built upon the RISC architecture utilize instructions that are simple in the sense that only one operation (ADD, SUB, Shift…) may be performed per instruction. Contrary to RISC, “CISC” stands for “Complex Instruction Set Computing.” This “complex” mainly relates to that each instruction can perform several operations.

RISC’s power resides in that its simplicity results in easier decoding, execution and hardware design, leading to a faster processing speed. In addition, its simplicity, modularity, and extensibility allow RISC based processors to be tailored for an extensive variety of applications.



## Single-cycle RISC-V processor design
To understand what “single-cycle” means, we have to explain how exactly a RISC-V processor executes instructions.

There are 5 stages involved:
1.	Instruction Fetch (IF) stage: The instruction is fetched from memory.

2.	Instruction Decode (ID) stage: the instruction is decoded to determine the operands, operation type, storage location and control signals.


3.	Execute (EX) stage: The Arithmetic and/or Logical operation is executed inside the ALU.

4.	Memory (MEM) stage: The instruction is stored in memory. This only happens for some instructions only, where the memory isn’t the main storage location.


5.	Write back (WB) stage: The instruction is written back to the register bank.

If an instruction passes through all of these stages in one clock cycle, the design is a single-cycle RISC. However, if we add pipeline registers between each two stages, this results in several clock signals being required for the data signals to propagate from the registers between IF and ID, for example, to the pipeline register between ID and EX. This results in more clock being required per instruction. However, as a tradeoff, the clock frequency can be significantly increased and the throughput of the processor significantly increases as well due to the design being pipelined.

## Instruction formats:


<img width="657" height="272" alt="image" src="https://github.com/user-attachments/assets/b0870e10-a50b-4658-9fff-9d82fbeb30b1" />

_Figure 1: Formats for all the possible instructions the designed processor can implement._
<br> <br> <br> 

<img width="744" height="631" alt="image" src="https://github.com/user-attachments/assets/3612774e-28f8-472e-87b2-cceaeeb81049" />

_Figure 2: Subset implemented. The numbers are the operation numbers for the control logic of the ALU._

<br> <br> <br> 

<img width="554" height="246" alt="image" src="https://github.com/user-attachments/assets/bd4c4891-9199-4914-97e3-22afa8970bac" />

_Figure 3: Acronym meanings. (source: DDCA-RISC-V ed by Sarah Harris)._
<br> <br> <br> 

## Data path and control path diagrams

 
<img width="1123" height="513" alt="image" src="https://github.com/user-attachments/assets/3a02e2d4-2db6-4962-9234-4c964b1ae05f" />

_Figure 4: RISC_V processor data and control paths._
<br> <br> <br> 

Design methodology and module descriptions
The methodology used in the design was to divide the design into modules, where each module represents one of the five stages, in addition to two modules to complement the operation of the stages.

## Modules
1.	IF_stage: Increments the process counter (PC) on each clock cycle or sets the PC to the correct value according to the result of the latest instruction (such as branch and jump instructions). The PC is used to fetch the “correct” next instruction form the instruction memory.

IF also sends portions of the instruction to the control unit.

2.	ID_stage: Receives the instruction form the IF stage and outputs the operands rs2, rs1 and imm (immediate value) from the register bank to be used by the ALU in the EX stage.

3.	EX_stage: Receives the operands from the ID stage to perform the desired operation on them. The selection between rs2 and immediate as well as the operation type and the ALU output are determined by control signals from the control unit.

4.	MEM_stage: Receives the outputs of the EX stage and either stores the result in memory (S_type operations) or outputs the a value from memory to be loaded somewhere in the register bank (Load operations).

5.	WB_stage: Receives the output of both the EX stage and the MEM stage. It chooses between either the memory value or the ALU result to be stored into the register bank.

6.	immediate_genrator: Generates the immediate value in the appropriate format according to the type of instruction.

7.	control_unit: Generates control signals based on the operation type to organize and control the data path signal propagation behaviour and ensure the instruction is executed properly.

8.	RISC_V_32_top: Encapsulates all of the other modules and ensures the connections between them are correct and that input and output port lengths are correct.

Test bench and waveforms:

By monitoring the waveform and results stored at the expected registers, updated values of PC on branch and jump statements as well as newer values stored in memory for store operations, we conclude that the processor is fully operational and works as purported.

 <img width="1125" height="427" alt="image" src="https://github.com/user-attachments/assets/b57064c4-d718-4322-b338-d0ecc33d0b6a" />

_Figure 5: Waveform sample._
<br> <br> <br> 
