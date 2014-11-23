# Load the altera_mf_ver library for altsyncram design
vsim -gui work.processor_tb
# Add waves to waveform

# Clock & Counter(Yellow)
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/clk
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/srec_parse
# add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/cur_pipe_state
#add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/next_pipe_state

# Stall Signals (Purple)
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/exe_dest_reg_stall
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/exe_dest_reg_sel
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/exe_rd
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/exe_rt
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/mem_dest_reg_stall
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_reg_source0_stall
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_reg_source1_stall
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_is_jump
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_jump_counter
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/next_insn_is_nop
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_is_load
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/exe_is_load
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_mx_op1_bypass
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_mx_op2_bypass
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_wx_op1_bypass
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_wx_op2_bypass
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/dec_wm_data_bypass
add wave -position insertpoint -color purple sim:/processor_tb/processor_uut/debug_signal_path_taken

#TEST
add wave -position insertpoint -color orange sim:/processor_tb/processor_uut/reg_file/dest
add wave -position insertpoint -color orange sim:/processor_tb/processor_uut/reg_file/destVal
add wave -position insertpoint -color orange sim:/processor_tb/processor_uut/reg_file/write_enable

# Fetch Stage (Plum)
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/stall
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/pc
#add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch_next_pc
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch/pc
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch/next_pc
#add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch/stall_in
add wave -position insertpoint -color plum sim:/processor_tb/processor_uut/fetch/pc_out

# Decode Stage (Cyan)
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_pc
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/pre_fetch_ir
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/fetch_ir
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/decode_ir
add wave -position insertpoint -radix unsigned -color cyan sim:/processor_tb/processor_uut/rs
add wave -position insertpoint -radix unsigned -color cyan sim:/processor_tb/processor_uut/rt
add wave -position insertpoint -radix unsigned -color cyan sim:/processor_tb/processor_uut/rd
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/immed
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/dec_A
add wave -position insertpoint -radix decimal -color cyan sim:/processor_tb/processor_uut/dec_B
add wave -position insertpoint -color cyan sim:/processor_tb/processor_uut/dec_illegal_insn

# Execute Stage (Green)
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_A
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_B
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_extended
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_op2
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/alu_op1_bypass
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/alu_op2_bypass
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_O
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_zero
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_neg
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_alu_op
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_rd
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_rt
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_dest_reg_sel
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_is_branch
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_is_jump
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_branch_effective_address
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_jump_effective_address
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_branch_type
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_branch_taken
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_next_pc
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_update_pc
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_is_jr
add wave -position insertpoint -color green sim:/processor_tb/processor_uut/exe_cur_pc
# add wave -position insertpoint -color green sim:/processor_tb/processor_uut/branch_resolve/branch_taken
# add wave -position insertpoint -color green sim:/processor_tb/processor_uut/branch_resolve/zero
# add wave -position insertpoint -color green sim:/processor_tb/processor_uut/branch_resolve/neg
# add wave -position insertpoint -color green sim:/processor_tb/processor_uut/branch_resolve/branch_type
# add wave -position insertpoint -color green sim:/processor_tb/processor_uut/branch_resolve/is_branch

# Memory Stage (Coral)
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_reg_data
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_data_in
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_addr_in
add wave -position insertpoint -radix decimal -color coral sim:/processor_tb/processor_uut/mem_alu_result
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/wb_D
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_res_data_sel
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_rw
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_next_pc
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_update_pc
add wave -position insertpoint -color coral sim:/processor_tb/processor_uut/mem_data_out

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
add wave -position insertpoint -color blue sim:/processor_tb/processor_uut/reg_file_write_enable

# SimpleAdd start of execution
#run 45500 ns
# SimpleAdd end of execution - unpipeline
#run 54200 ns
# SimpleAdd end of execution - pipelined (no forwarding)
#run 48500 ns
# SimpleAdd end of execution - pipelined (with forwarding)
#run 47700 ns

# SumArray start of execution
#run 94300 ns
# SumArray end of execution - unpipeline
#run 226000 ns
# SumArray end of execution - pipelined (no forwarding)
#run 158500 ns
# SumArray end of execution - pipelined (with forwarding)
#run 133400 ns

# SimpleIf start of execution
#run 72200 ns
# SimpleIf end of execution - unpipeline
#run 85400 ns
# SimpleIf end of execution - pipelined (no forwarding)
#run 77100 ns
# SimpleIf end of execution - pipelined (with forwarding)
#run 75600 ns

# SwapShift start of execution
#run 122900 ns
# SwapShift end of execution - unpipeline
#run 150600 ns
# SwapShift end of execution - pipelined (no forwarding)
#run 133900 ns
# SwapShift end of execution - pipelined (with forwarding)
#run 130400 ns

# CheckVowel start of execution
#run 224200 ns
# CheckVowel end of execution - unpipeline
#run 845400 ns
# CheckVowel end of execution - pipelined (no forwarding)
#run 485800 ns
# CheckVowel end of execution - pipelined (with forwarding)
#run 379700 ns

# Bubble sort start of execution
#run 218000 ns
#Bubble sort end of exectuion - unpipeline
#run 814700 ns
# Bubble sort end of execution - pipelined (no forwarding)
#run 492400 ns
# Bubble sort end of execution - pipelined (with forwarding)
#run 393300 ns

run 349000 ns