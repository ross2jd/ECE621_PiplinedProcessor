project compileall

vsim -gui work.processor_tb
restart -force -nowave

# Clock (plum)
add wave -color plum -radix binary clk 

# Memory (yellow)
add wave -color yellow -radix hexadecimal srec_parse

run -all
view wave