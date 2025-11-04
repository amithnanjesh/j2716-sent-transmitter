vcom -O0 -work work "CRC4_SENT.vhd"
vcom -O0 -work work "CRC4_SENT_tb.vhd"
vcom -O0 -work work "SAE_CRC_CALC_SENT.vhd"
vcom -O0 -work work "SAE_CRC_CALC_SENT_tb.vhd"
restart -f
run -all
