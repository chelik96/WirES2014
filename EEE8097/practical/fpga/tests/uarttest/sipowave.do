onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color White -height 34 -itemcolor White /sipo_tb/clk
add wave -noupdate -color Cyan -height 34 -itemcolor Cyan /sipo_tb/rdy
add wave -noupdate -color Yellow -height 34 -itemcolor Yellow /sipo_tb/send
add wave -noupdate -color Green -height 34 -itemcolor Green /sipo_tb/sin
add wave -noupdate -color {Pale Green} -height 34 -itemcolor {Pale Green} /sipo_tb/pout
add wave -noupdate -color {Light Blue} -height 34 -itemcolor {Light Blue} /sipo_tb/uut/sr
add wave -noupdate -color Thistle -height 34 -itemcolor Thistle /sipo_tb/uut/c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44478 ps} 0}
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