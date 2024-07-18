if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -work work [pwd]/toplevel.vhd
vcom -work work [pwd]/SD.vhd
vcom -work work [pwd]/UART.vhd

vsim toplevel

add wave *

force clk 0, 1 13.5 -r 27
force RST 0 0
force det 0 0, 1 100
force RX 'h54 200

view structure
view signals

run 100 us

view -undock wave
wave zoomfull