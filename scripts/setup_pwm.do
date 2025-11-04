cd "/home/nanjesha/Digital_01/Labs/SENT_interface"
file delete -force work
vlib work
vmap work
vcom -O0 -work work "PWM_SENT.vhd"
vcom -O0 -work work "PWM_SENT_tb.vhd"
vsim work.PWM_SENT_tb(tb) -t ns -vopt -voptargs=+acc
add wave *

run -all
