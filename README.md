# CPU-8-bit-FPGA-

simple 8-bit single-cycle processor which includes an ALU, a register file and control logic, using Verilog HDL.

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
