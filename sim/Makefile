# Run simulation

SOURCES += ../src/reg_8bit_generalpurpose.vhd
SOURCES += ../src/reg_16bit_updownload.vhd
SOURCES += ../src/reg_16bit_xfer.vhd
SOURCES += ../src/alu.vhd
SOURCES += ../src/cpu.vhd
SOURCES += ../src/pipeline_roms.vhd
SOURCES += ../src/ram.vhd
SOURCES += ../src/system.vhd

SIM_SOURCES += sim_clk.vhd
SIM_SOURCES += tb_system.vhd

TB   = tb_system
WAVE = $(TB).ghw
SAVE = $(TB).gtkw


################################################
## Help
################################################

.PHONY: help
help:
	@echo
	@echo "Possible targets:"
	@echo "  make sim  : Run simulation"
	@echo "  make help : This message"
	@echo


################################################
## Simulation
################################################

.PHONY: sim
sim: $(WAVE)
	gtkwave $(WAVE) $(SAVE)

$(WAVE): $(SOURCES) $(SIM_SOURCES)
	ghdl -i --std=08 $(SOURCES) $(SIM_SOURCES)
	ghdl -m --std=08 -frelaxed $(TB)
	ghdl -r --std=08 -frelaxed $(TB) --wave=$(WAVE) --stop-time=1us --max-stack-alloc=16384


################################################
## Cleanup
################################################

.PHONY: clean
clean:
	rm -rf work-obj08.cf
	rm -rf $(WAVE)
	rm -rf $(ROM)

