cd "/home/nanjesha/Digital_01/Labs/SENT_interface/"
file delete -force work
vlib work
vmap work
vcom -O0 -work work "CRC4_SENT.vhd"
vcom -O0 -work work "SAE_CRC_CALC_SENT.vhd"
vcom -O0 -work work "PWM_SENT.vhd"
vcom -O0 -work work "FSM_SENT.vhd"
vcom -O0 -work work "MUX_SENT.vhd"
vcom -O0 -work work "SENT_interface.vhd"
vcom -O0 -work work "SENT_interface_tb.vhd"
vsim work.SENT_interface_tb(tb) -t ns -vopt -voptargs=+acc
add wave dut/*
run -all
