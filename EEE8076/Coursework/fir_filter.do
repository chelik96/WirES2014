onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 26 -label ADCDAT /fir_filter_vhd_tst/ADCDAT
add wave -noupdate -height 26 -label DACDAT /fir_filter_vhd_tst/DACDAT
add wave -noupdate -height 26 -label Accumulator /fir_filter_vhd_tst/test_fir_filter/Accumulator
add wave -noupdate -height 26 -label {Multiplier Step} /fir_filter_vhd_tst/test_fir_filter/main/Multiply_Step
add wave -noupdate -height 26 -label {FIR Delay Regs} /fir_filter_vhd_tst/test_fir_filter/FIR_Delay
add wave -noupdate -height 26 -label ADCrdy /fir_filter_vhd_tst/ADCrdy
add wave -noupdate -height 26 -label DACstb /fir_filter_vhd_tst/DACstb
add wave -noupdate -height 26 -label ADCstb /fir_filter_vhd_tst/ADCstb
add wave -noupdate -height 26 -label DACrdy /fir_filter_vhd_tst/DACrdy
add wave -noupdate -height 26 -label CLOCK_50 /fir_filter_vhd_tst/CLOCK_50
add wave -noupdate -height 26 -label RST_N /fir_filter_vhd_tst/RST_N
add wave -noupdate -height 26 -label i /fir_filter_vhd_tst/test_fir_filter/main/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {252479810 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 127
configure wave -valuecolwidth 224
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {525021 ns}
