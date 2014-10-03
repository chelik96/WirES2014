onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Violet Red} /cnt_tb/rst
add wave -noupdate -color Gray90 /cnt_tb/clk
add wave -noupdate -color Cyan /cnt_tb/ovf
add wave -noupdate /cnt_tb/uut/c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 90
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 5
configure wave -griddelta 10
configure wave -timeline 0
configure wave -timelineunits ns
layout load Mike1
run 300ns
wave zoom full
update