# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -y ./ -I ./
VVP=vvp

# Look up .PHONY rules for Makefiles
.PHONY: clean submission

test_pulse_generator: test_pulse_generator.sv pulse_generator.sv
	${IVERILOG} $^ -o test_pulse_generator.bin && ${VVP} test_pulse_generator.bin

test_pwm: test_pwm.sv pulse_generator.sv pwm.sv
	@echo "This might take a while, we're testing a lot of clock cycles!"
	${IVERILOG} $^ -o test_pwm.bin && ${VVP} test_pwm.bin

test_triangle_generator: test_triangle_generator.sv triangle_generator.sv
	${IVERILOG} $^ -o test_triangle_generator.bin && ${VVP} test_triangle_generator.bin

test_slt: test_slt.sv slt.sv adder_n.sv adder_1.sv mux4.sv
	${IVERILOG} $^ -o test_slt.bin && ${VVP} test_slt.bin

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv *.pdf
