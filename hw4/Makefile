IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VIVADO=vivado -mode batch -source

test_add: test_add.sv add32.sv add1.sv
	${IVERILOG} $^ -o test_add.bin &&	${VVP} test_add.bin