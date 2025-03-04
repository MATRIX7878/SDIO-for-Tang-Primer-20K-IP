# Simulation is done using the program ghdl. It may be available
# in your OS repository, otherwise it may be downloaded from here:
# https://github.com/ghdl/ghdl

PROJECT = uart
PROJECT = toplevel

TB       = tb_$(PROJECT)
SOURCES += UART.vhd
SOURCES += toplevel.vhd
SOURCES += $(TB).vhd
SAVE     = $(TB).gtkw
WAVE     = $(TB).ghw


#####################################
# Simulation
#####################################

.PHONY: sim
sim: $(SOURCES)
	ghdl -i --std=08 $(SOURCES)
	ghdl -m --std=08 $(TB)
	ghdl -r --std=08 $(TB) --wave=$(WAVE) --stop-time=120us


$WAVE): sim

show: $(WAVE)
	gtkwave $(WAVE) $(SAVE)


#####################################
# Cleanup
#####################################

clean:
	rm -rf *.o
	rm -rf work-obj08.cf
	rm -rf unisim-obj08.cf
	rm -rf xpm-obj08.cf
	rm -rf $(TB)
	rm -rf $(WAVE)

