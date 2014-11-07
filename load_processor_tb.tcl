# Load the altera_mf_ver library for altsyncram design
vsim -gui work.processor_tb
# Add waves to waveform

# Clock & Counter(Yellow)
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/clk
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/srec_parse
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/cur_pipe_state
#add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/next_pipe_state

# Fetch Stage (Plum)
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/stall
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/pc
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch_next_pc


# Decode Stage (Cyan)
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_pc
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_ir
add wave -position insertpoint -radix unsigned -color cyan sim:/processor_tb/processor_uut/rs
add wave -position insertpoint -radix unsigned -color cyan sim:/processor_tb/processor_uut/rt
add wave -position insertpoint -radix unsigned -color cyan sim:/processor_tb/processor_uut/rd
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/immed
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/dec_A
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/dec_B
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/dec_illegal_insn

# Execute Stage (Green)
add wave -position insertpoint -radix decimal -color green sim:/processor_tb/processor_uut/exe_A
add wave -position insertpoint -radix decimal -color green sim:/processor_tb/processor_uut/exe_B
add wave -position insertpoint -radix decimal -color green sim:/processor_tb/processor_uut/exe_extended
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
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_update_pc

# Memory Stage (Coral)
add wave -position insertpoint -radix decimal -color coral sim:/processor_tb/processor_uut/mem_data_in
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_addr_in
add wave -position insertpoint -radix decimal -color coral sim:/processor_tb/processor_uut/mem_alu_result
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_sign_extend_out
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_res_data_sel
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_rw
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_next_pc

# Write back stage (Blue)
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_res_data_sel
add wave -position insertpoint -radix decimal -color blue sim:/processor_tb/processor_uut/wb_data
add wave -position insertpoint -radix unsigned -color blue sim:/processor_tb/processor_uut/wb_rt
add wave -position insertpoint -radix unsigned -color blue sim:/processor_tb/processor_uut/wb_rd
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_dest_reg_sel
add wave -position insertpoint -radix unsigned -color blue sim:/processor_tb/processor_uut/dest_reg
add wave -position insertpoint -radix unsigned -color blue sim:/processor_tb/processor_uut/wb_write_to_reg
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_next_pc
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_update_pc
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/wb_is_jal

run 217700 ns
#run 229600 ns
#run 233500 ns