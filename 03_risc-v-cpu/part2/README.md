# Multicycle RISC-V CPU
This week will be all about simulating a working rv32i (integer subeset of the RISC-V spec) system. The system (in `rv32i_system.sv`) consists of a computation core (datapath, alu, register file, etc.) and a Memory Management Unit (MMU). The MMU will be critical when start connecting our CPU to external peripherals, but for now it just implements a signal RAM.

## Assembler
To test a CPU you need a populated instruction memory. I've provided a simplistic python assembler (`assembler.py`), please skim the file and its usage in `Makefile` before proceeding. `assembler.py` generates `memh` files (ascii hex) that can be loaded by our simulation and synthesis tools.

There is also a `disassembler.py` file, you may find that useful for debugging but I mostly just included it for completeness (it's how I tested the assembler.)

## Running Tests



# This Week's Goals/Timeline
- Monday - implement a few I and R type instructions.
- Thursday, before class: I and R type solutions will be posted, make sure you can simulate that!
- Thursday, during class: implement a load, a store, a branch, and a jump.
- Monday: Final lab day. 
