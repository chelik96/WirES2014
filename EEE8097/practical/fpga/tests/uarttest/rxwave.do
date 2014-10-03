onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 34 -expand -group Ports -color White -height 34 -itemcolor White /rx_tb/uut/clk
add wave -noupdate -height 34 -expand -group Ports -color Cyan -height 34 -itemcolor Cyan /rx_tb/uut/rst
add wave -noupdate -height 34 -expand -group Ports -color Yellow -height 34 -itemcolor Yellow /rx_tb/uut/input
add wave -noupdate -height 34 -expand -group Ports -color Green -height 34 -itemcolor Green /rx_tb/uut/output
add wave -noupdate -height 34 -expand -group {Internal Signals} -color Thistle -height 34 -itemcolor Thistle /rx_tb/uut/p_state
add wave -noupdate -height 34 -expand -group {Internal Signals} -color {Light Blue} -height 34 -itemcolor {Light Blue} /rx_tb/uut/n_state
add wave -noupdate -height 34 -expand -group {Internal Signals} -color Khaki -height 34 -itemcolor Khaki /rx_tb/uut/sr_clk
add wave -noupdate -height 34 -expand -group {Internal Signals} -color Tan -height 34 -itemcolor Tan /rx_tb/uut/sr_rst
add wave -noupdate -height 34 -expand -group {Internal Signals} -color Coral -height 34 -itemcolor Coral /rx_tb/uut/sr_send
add wave -noupdate -height 34 -expand -group {Internal Signals} -color {Medium Aquamarine} -height 34 -itemcolor {Medium Aquamarine} /rx_tb/uut/ovflow
add wave -noupdate -height 34 -expand -group {Internal Signals} -color {Light Steel Blue} -height 34 -itemcolor {Light Steel Blue} /rx_tb/uut/rst_c
add wave -noupdate -height 34 -expand -group {Internal Signals} -color Plum -height 34 -itemcolor Plum /rx_tb/uut/reg
add wave -noupdate -height 34 -expand -group {Internal Signals} -color Orchid -height 34 -itemcolor Orchid /rx_tb/uut/i
add wave -noupdate -height 34 -expand -group {Component Counters} -color {Yellow Green} -height 34 -itemcolor {Yellow Green} -label {c (counter)} /rx_tb/uut/count/c
add wave -noupdate -height 34 -expand -group {Component Counters} -color {Cadet Blue} -height 34 -itemcolor {Cadet Blue} -label {sr (sipo)} /rx_tb/uut/sr/sr
add wave -noupdate -height 34 -expand -group {Component Counters} -color {Pale Green} -height 34 -itemcolor {Pale Green} -label {c (sipo)} /rx_tb/uut/sr/c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44059 ps} 0}
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
run 1500ns
wave zoom full
update
