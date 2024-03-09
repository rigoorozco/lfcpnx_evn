quit -sim

vlib  work
vdel -lib work -all 
vlib work

vlog -sv -mfcu \
	"+incdir+/home/rigo/code/lfcpnx_evn/sources" \
	"+incdir+/home/rigo/code/lfcpnx_evn/sources/picorv32" \
	"+incdir+/home/rigo/code/lfcpnx_evn/submodules/picorv32" \
	"+incdir+/home/rigo/code/lfcpnx_evn/submodules/picorv32/picosoc" \
	"+incdir+/home/rigo/code/lfcpnx_evn/test" \
-work work \
	"/home/rigo/code/lfcpnx_evn/sources/lfcpnx_evn.sv" \
	"/home/rigo/code/lfcpnx_evn/sources/picorv32/bram_simple_sp.v" \
	"/home/rigo/code/lfcpnx_evn/sources/picorv32/picosoc_lfcpnx.v" \
	"/home/rigo/code/lfcpnx_evn/submodules/picorv32/picorv32.v" \
	"/home/rigo/code/lfcpnx_evn/submodules/picorv32/picosoc/simpleuart.v" \
	"/home/rigo/code/lfcpnx_evn/test/lfcpnx_evn_tb.sv"\
+define+SIM_FIRMWARE_FILE="../sources/picorv32/firmware.hex" \

vsim \
	-L work -L pmi_work -L ovi_lfcpnx \
	-suppress vsim-7033,vsim-8630,3009,3389 \
	lfcpnx_evn_tb 

view wave
add wave /*
add wave /dut/picosoc/ram/mem

run -all