vcom -O0 -work work "CRC4_SENT.vhd"
vcom -O0 -work work "SAE_CRC_CALC_SENT.vhd"
vcom -O0 -work work "PWM_SENT.vhd"
vcom -O0 -work work "FSM_SENT.vhd"
vcom -O0 -work work "MUX_SENT.vhd"
vcom -O0 -work work "SENT_interface.vhd"
vcom -O0 -work work "SENT_interface_tb.vhd"
restart -f
run -all
