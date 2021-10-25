IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VIVADO=vivado -mode batch -source

test_add: test_add.sv add32.sv add1.sv
	${IVERILOG} $^ -o test_add.bin &&	${VVP} test_add.bin

test_mux: test_mux.sv mux32.sv mux2.sv
	${IVERILOG} $^ -o test_mux.bin &&	${VVP} test_mux.bin