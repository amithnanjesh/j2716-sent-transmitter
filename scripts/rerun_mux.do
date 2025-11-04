vcom -O0 -work work "MUX_SENT.vhd"
vcom -O0 -work work "MUX_SENT_tb.vhd"
restart -f
run -all
