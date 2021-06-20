# CPU-8-bit-FPGA-

8 bit CPU single thread pipeline processor. Which include ALU, ram, instruction memory, data memory and ext. This CPU is base on Harvard architecture. This implementation was improved using pipelining mechanisms and it gained around 4-time performance improvement. In addition to that direct-mapped cache was introduced to Instruction and data memories. which were implemented as a memory hierarchy to achieve high-performance in-memory access. Also, a custom assembler was implemented to support programming the CPU. This CPU is able to execute most algorithms.


![alt text](https://github.com/praveendhananjaya/CPU-8-bit-FPGA-/blob/main/doc/instructions.png?raw=true)

* OP-CODE :- field identifies the instruction's operation. This should be used by the control logic to interpret the remaining fields and derive the control signals.
* DESTINATION :- field specifies either the register to be written to in the register file,or an immediate value (jump or branch target offset).
* SOURCE 1 :- field specifies the 1st operand to be read from the register file.
* SOURCE 2 :- is the 2nd operand from the register file, or an immediate value (loadi).

# ALU

![alt text](https://github.com/praveendhananjaya/CPU-8-bit-FPGA-/blob/main/doc/ALU.png?raw=true)

At the heart of every computer processor is an Arithmetic Logic Unit (ALU). This is the part of the computer which performs arithmetic and logic operations on numbers, e.g. addition, subtraction, etc. 

    instructions add, sub, and, or, mov, and loadi , j , beq
    
![alt text](https://github.com/praveendhananjaya/CPU-8-bit-FPGA-/blob/main/doc/ALU_table.png?raw=true)

# Register File

![alt text](https://github.com/praveendhananjaya/CPU-8-bit-FPGA-/blob/main/doc/register_file.png?raw=true)

    8×8 register file. (register0 - register7)


# Integration & Control

![alt text](https://github.com/praveendhananjaya/CPU-8-bit-FPGA-/blob/main/doc/CPU.png?raw=true)


![alt text](https://github.com/praveendhananjaya/CPU-8-bit-FPGA-/blob/main/doc/timing.png?raw=true)
