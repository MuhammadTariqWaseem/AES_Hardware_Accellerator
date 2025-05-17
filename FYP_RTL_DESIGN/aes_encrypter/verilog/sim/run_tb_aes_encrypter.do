# Clean old work library (optional)
if {[file exists work]} {
    vdel -lib work -all
}


# Create the work library
vlib work


vlog -sv tb_aes_encrypter.sv ../rtl/aes_encrypter.sv 

vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/fifo_128/verilog/rtl/fifo_128.sv 
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/key_expansion/verilog/rtl/key_expansion.sv 
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/key_expansion/verilog/rtl/sub_word.sv 
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/memory/verilog/rtl/aes_sbox.sv 
# vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/memory/mem_file/sbox.mif
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/mix_column/verilog/rtl/mix_column.sv 
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/mix_column/verilog/rtl/gf_mul.sv 
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/shift_rows/verilog/rtl/shift_rows.sv 
vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/sub_byte/verilog/rtl/sub_byte.sv 
# vlog -sv C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/memory/verilog/sim/db/altsyncram* 
vsim -novopt tb_aes_encrypter
# vsim work.tb_aes_encrypter
# add wave *
do wave_tb_aes_encrypter.do
run -all


# # Create required libraries
# vlib work
# vlib altera_mf

# # Compile Altera (Intel) Megafunctions Library (Required for altsyncram)
# vlog -work altera_mf "C:/intelFPGA_lite/16.1/quartus/eda/sim_lib/altera_mf.v"

# # Compile RTL and Testbench
# vlog -sv tb_aes_encrypter.sv 
# vlog -sv ../rtl/aes_encrypter.sv 

# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/fifo_128/verilog/rtl/fifo_128.sv"
# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/key_expansion/verilog/rtl/key_expansion.sv"
# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/key_expansion/verilog/rtl/sub_word.sv"
# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/memory/verilog/rtl/aes_sbox.sv"
# # Compile altsyncram memory file if needed
# # vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/memory/mem_file/sbox.mif"

# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/mix_column/verilog/rtl/mix_column.sv"
# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/mix_column/verilog/rtl/gf_mul.sv"
# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/shift_rows/verilog/rtl/shift_rows.sv"
# vlog -sv "C:/Users/PMLS/Desktop/FYP_RTL_DESIGN/sub_byte/verilog/rtl/sub_byte.sv"

# # Load simulation with Altera libraries
# vsim -L altera_mf work.tb_aes_encrypter

# # Add all signals to waveform
# add wave *

# # Run simulation
# run -all

