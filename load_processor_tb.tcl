# Load the altera_mf_ver library for altsyncram design
vsim -gui work.processor_tb
# Add waves to waveform
add wave -position insertpoint sim:/processor_tb/*
add wave -position insertpoint sim:/processor_tb/processor_uut/*
add wave -position insertpoint sim:/processor_tb/processor_uut/decoder/*

run 214400 ns
