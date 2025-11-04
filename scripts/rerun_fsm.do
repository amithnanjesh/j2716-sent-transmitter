vcom -O0 -work work "FSM_SENT.vhd"
vcom -O0 -work work "FSM_SENT_tb.vhd"
restart -f
run -all
