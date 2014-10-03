onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 24 -expand -group Ports -color White -height 34 -itemcolor White -label clk /tx_tb/clk
add wave -noupdate -height 24 -expand -group Ports -color Salmon -height 34 -itemcolor Salmon -label rst /tx_tb/rst
add wave -noupdate -height 24 -expand -group Ports -color Cyan -height 34 -itemcolor Cyan -label {input (parallel)} -radix hexadecimal /tx_tb/input
add wave -noupdate -height 24 -expand -group Ports -color Green -height 34 -itemcolor Green -label {output (serial)} /tx_tb/output
add wave -noupdate -height 24 -expand -group Ports -color Orange -height 34 -itemcolor Orange -label send /tx_tb/send
add wave -noupdate -height 24 -expand -group Ports -color Yellow -height 34 -itemcolor Yellow /tx_tb/uut/sent
add wave -noupdate -expand -group {Internal Signals} -color Tan -height 34 -itemcolor Tan /tx_tb/uut/p_state
add wave -noupdate -expand -group {Internal Signals} -color Wheat -height 34 -itemcolor Wheat /tx_tb/uut/n_state
add wave -noupdate -expand -group {Internal Signals} -color Goldenrod -height 34 -itemcolor Goldenrod /tx_tb/uut/p_send
add wave -noupdate -expand -group {Internal Signals} -color {Spring Green} -height 34 -itemcolor {Spring Green} /tx_tb/uut/we
add wave -noupdate -expand -group {Internal Signals} -color {Spring Green} -height 34 -itemcolor {Spring Green} /tx_tb/uut/sr_out
add wave -noupdate -expand -group {Internal Signals} -color {Yellow Green} -height 34 -itemcolor {Yellow Green} /tx_tb/uut/rst_c
add wave -noupdate -expand -group {Internal Signals} -color {Yellow Green} -height 34 -itemcolor {Yellow Green} /tx_tb/uut/ovflow
add wave -noupdate -color {Light Blue} -height 34 -itemcolor {Light Blue} -label {c (piso)} /tx_tb/uut/sr/line__19/c
add wave -noupdate -color Thistle -height 34 -itemcolor Thistle -label {c (cnt)} /tx_tb/uut/count/c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {203069 ps} 0}
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
configure wave -gridperiod 5
configure wave -griddelta 10
configure wave -timeline 0
configure wave -timelineunits ns
layout load Mike1
run 1000ns
wave zoom full
update