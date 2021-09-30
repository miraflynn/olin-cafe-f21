# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VIVADO=vivado -mode batch -source

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

DECODERS=decoder_1_to_2.sv decoder_2_to_4.sv decoder_3_to_8.sv

test_decoders: test_decoders.sv $(DECODERS)
	${IVERILOG} $^ -o test_decoders.bin && ${VVP} test_decoders.bin

test_led_array_driver: test_led_array_driver.sv led_array_driver.sv led_array_model.sv $(DECODERS)
	${IVERILOG} $^ -o test_led_array_driver.bin && ${VVP} test_led_array_driver.bin

test_conway_cell: test_conway_cell.sv conway_cell.sv
	${IVERILOG} $^ -o test_conway_cell.bin &&	${VVP} test_conway_cell.bin

test_main: test_main.sv main.sv conway_cell.sv initial_conditions.sv led_array_driver.sv led_array_model.sv $(DECODERS)
	${IVERILOG} $^ -o test_main.bin && ${VVP} test_main.bin

main.bit: main.sv conway_cell.sv led_array_driver.sv $(DECODERS)
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl && cp ./xilinx/01_game_of_life.runs/impl_1/main.bit ./main.bit

program_fpga: main.bit
	@echo "########################################"
	@echo "#### Programming FPGA               ####"
	@echo "########################################"
	${VIVADO} program.tcl

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd vivado*.log vivado*.jou vivado*.str

# Call this to generate your submission zip file.
submission:
	zip submission.zip *.sv README.md docs/* xilinx/*.xpr *.xdc
