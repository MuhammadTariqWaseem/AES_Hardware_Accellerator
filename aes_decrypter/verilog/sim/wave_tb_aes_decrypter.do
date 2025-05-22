onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/clk
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/rst
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/data_in
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/key
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/valid_in
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/data_out
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/valid_out
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/fifo_rd_en_t
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/valid_key
add wave -noupdate -radix hexadecimal /tb_aes_decrypter/exp_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1374014 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1372790 ps} {1375117 ps}
