vcom -O0 -work work "PWM_SENT.vhd"
vcom -O0 -work work "PWM_SENT_tb.vhd"
restart -f
run -all
