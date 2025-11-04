cd "/home/nanjesha/Digital_01/Labs/SENT_interface"
file delete -force work
vlib work
vmap work
vcom -O0 -work work "FSM_SENT.vhd"
vcom -O0 -work work "FSM_SENT_tb.vhd"
vsim work.FSM_SENT_tb(tb) -t ns -vopt -voptargs=+acc
add wave *

run -all
