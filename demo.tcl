# Load the altera_mf_ver library for altsyncram design
vsim -gui work.processor_tb
# Add waves to waveform

# Clock & SREC Parser Signal(Yellow)
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/clk
add wave -position insertpoint -color yellow sim:/processor_tb/processor_uut/srec_parse

# Fetch Stage (Plum) - Data Lines
add wave -position insertpoint -color plum -group Fetch -label PC sim:/processor_tb/processor_uut/pc
add wave -position insertpoint -color plum -group Fetch -label next_PC sim:/processor_tb/processor_uut/fetch_next_pc
# Fetch Stage (Purple) - Control Lines
add wave -position insertpoint -color purple -group Fetch_Control -label Stall sim:/processor_tb/processor_uut/stall

# Decode Stage (Cyan) - Data Lines
add wave -position insertpoint -color cyan -group Decode -label next_PC sim:/processor_tb/processor_uut/decode_pc
add wave -position insertpoint -color cyan -group Decode -label IR sim:/processor_tb/processor_uut/decode_ir
add wave -position insertpoint -color cyan -group Decode -label rs sim:/processor_tb/processor_uut/rs
add wave -position insertpoint -color cyan -group Decode -label rt sim:/processor_tb/processor_uut/rt
add wave -position insertpoint -color cyan -group Decode -label rd sim:/processor_tb/processor_uut/rd
add wave -position insertpoint -color cyan -group Decode -label Source1_value sim:/processor_tb/processor_uut/dec_A
add wave -position insertpoint -color cyan -group Decode -label Source2_value sim:/processor_tb/processor_uut/dec_B

# Execute Stage (Green) - Data Lines
add wave -position insertpoint -color green -group Execute -label ALU_operand1 sim:/processor_tb/processor_uut/alu_op1_bypass
add wave -position insertpoint -color green -group Execute -label ALU_operand2 sim:/processor_tb/processor_uut/exe_op2
add wave -position insertpoint -color green -group Execute -label ALU_result sim:/processor_tb/processor_uut/exe_alu_result
add wave -position insertpoint -color green -group Execute -label ALU_result_negative sim:/processor_tb/processor_uut/exe_neg
add wave -position insertpoint -color green -group Execute -label ALU_result_zero sim:/processor_tb/processor_uut/exe_zero
add wave -position insertpoint -color green -group Execute -label Branch_Taken sim:/processor_tb/processor_uut/exe_branch_taken
add wave -position insertpoint -color green -group Execute -label next_PC sim:/processor_tb/processor_uut/exe_next_pc
# Exectue Stage (Web Green) - Control Lines
add wave -position insertpoint -color darkgreen -group Execute_Control -label ALU_operation sim:/processor_tb/processor_uut/exe_alu_op
add wave -position insertpoint -color darkgreen -group Execute_Control -label Is_JAL sim:/processor_tb/processor_uut/exe_is_jal
add wave -position insertpoint -color darkgreen -group Execute_Control -label Is_Branch sim:/processor_tb/processor_uut/exe_is_branch
add wave -position insertpoint -color darkgreen -group Execute_Control -label Is_Load sim:/processor_tb/processor_uut/exe_is_load
add wave -position insertpoint -color darkgreen -group Execute_Control -label MX_Bypass_Op1 sim:/processor_tb/processor_uut/mx_op1_bypass
add wave -position insertpoint -color darkgreen -group Execute_Control -label MX_Bypass_Op2 sim:/processor_tb/processor_uut/mx_op2_bypass
add wave -position insertpoint -color darkgreen -group Execute_Control -label WX_Bypass_Op1 sim:/processor_tb/processor_uut/wx_op1_bypass
add wave -position insertpoint -color darkgreen -group Execute_Control -label WX_Bypass_Op2 sim:/processor_tb/processor_uut/wx_op2_bypass
add wave -position insertpoint -color darkgreen -group Execute_Control -label Flush sim:/processor_tb/processor_uut/exe_flush_pipeline
add wave -position insertpoint -color darkgreen -group Execute_Control -label Stall sim:/processor_tb/processor_uut/exe_stall_pipeline

# Memory Stage (Orange) - Data Lines
add wave -position insertpoint -color orange -group Memory -label Address sim:/processor_tb/processor_uut/mem_addr_in
add wave -position insertpoint -color orange -group Memory -label Data sim:/processor_tb/processor_uut/mem_data_in
add wave -position insertpoint -color orange -group Memory -label Read_Write sim:/processor_tb/processor_uut/mem_rw
# Memory Stage (Orange Red) - Control Lines
add wave -position insertpoint -color orangered -group Memory_Control -label WM_Bypass_Data sim:/processor_tb/processor_uut/wm_data_bypass
add wave -position insertpoint -color orangered -group Memory_Control -label Stall sim:/processor_tb/processor_uut/mem_stall_pipeline

# Write back stage (Blue) - Data Lines
add wave -position insertpoint -color skyblue -group WriteBack -label Dest_Reg sim:/processor_tb/processor_uut/dest_reg
add wave -position insertpoint -color skyblue -group WriteBack -label Dest_Value sim:/processor_tb/processor_uut/wb_data
# Write back stage (Blue) - Control Lines
add wave -position insertpoint -color blue -group WriteBack_Control -label Is_JAL sim:/processor_tb/processor_uut/wb_is_jal
add wave -position insertpoint -color blue -group WriteBack_Control -label Write_To_RegFile sim:/processor_tb/processor_uut/reg_file_write_enable

#This run will get us to the end of the SREC parser
run -all 
