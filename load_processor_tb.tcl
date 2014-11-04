# Load the altera_mf_ver library for altsyncram design
vsim -gui work.processor_tb
# Add waves to waveform

# Clock & Counter(Yellow)
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/clk
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/srec_parse
add wave -position insertpoint -radix decimal -color yellow sim:/processor_tb/pipe_stage_counter

# Fetch Stage (Plum)
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/stall
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/pc

# Decode Stage (Cyan)
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_pc
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_ir
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/dec_A
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/dec_B
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/dec_illegal_insn

# Execute Stage (Green)
add wave -position insertpoint -radix decimal -color green sim:/processor_tb/processor_uut/exe_A
add wave -position insertpoint -radix decimal -color green sim:/processor_tb/processor_uut/exe_op2
add wave -position insertpoint -radix decimal -color green sim:/processor_tb/processor_uut/exe_O
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_zero
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_neg
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_alu_op
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_is_branch
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_is_jump
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_branch_effective_address
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_jump_effective_address
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_branch_type
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_branch_taken
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_next_pc

# Memory Stage (Coral)
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_data_in
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_addr_in
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_sign_extend_out

# Write back stage (Blue)
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_data
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/dest_reg
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_next_pc



run 217900 ns
