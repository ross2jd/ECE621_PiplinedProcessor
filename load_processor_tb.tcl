# Load the altera_mf_ver library for altsyncram design
vsim -gui work.processor_tb
# Add waves to waveform

# Clock (Yellow)
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/clk

# Fetch Stage (Plum)
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/stall
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/pc
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch_rw
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch_access_size

# Decode Stage (Cyan)
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/insn_data_out
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_pc
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_ir
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/dec_A
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/dec_B

# Execute Stage (Green)
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_A
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_B
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_O
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_pc
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_ir
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_zero

run 217900 ns
