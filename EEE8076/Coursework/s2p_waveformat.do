onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Cyan -height 30 -itemcolor Cyan -label ADCDAT /s2p_adaptor_vhd_tst/ADCDAT
add wave -noupdate -color Green -height 30 -itemcolor Green -label DACDAT /s2p_adaptor_vhd_tst/DACDAT
add wave -noupdate -color Green -height 30 -itemcolor Green -label DACrdy /s2p_adaptor_vhd_tst/DACrdy
add wave -noupdate -color Cyan -height 30 -itemcolor Cyan -label ADCrdy /s2p_adaptor_vhd_tst/ADCrdy
add wave -noupdate -color Green -height 30 -itemcolor Green -label DACstb /s2p_adaptor_vhd_tst/DACstb
add wave -noupdate -color Cyan -height 30 -itemcolor Cyan -label ADCstb /s2p_adaptor_vhd_tst/ADCstb
add wave -noupdate -color Green -height 30 -itemcolor Green -label AUD_DACDAT /s2p_adaptor_vhd_tst/AUD_DACDAT
add wave -noupdate -color Cyan -height 30 -itemcolor Cyan -label AUD_ADCDAT /s2p_adaptor_vhd_tst/AUD_ADCDAT
add wave -noupdate -color Cyan -height 30 -itemcolor Cyan -label AUD_ADCLRCK /s2p_adaptor_vhd_tst/AUD_ADCLRCK
add wave -noupdate -color Green -height 30 -itemcolor Green -label AUD_DACLRCK /s2p_adaptor_vhd_tst/AUD_DACLRCK
add wave -noupdate -color {Yellow Green} -height 30 -itemcolor {Yellow Green} -label AUD_BCLK /s2p_adaptor_vhd_tst/AUD_BCLK
add wave -noupdate -color {Yellow Green} -height 30 -itemcolor {Yellow Green} -label CLOCK_50 /s2p_adaptor_vhd_tst/CLOCK_50
add wave -noupdate -color {Yellow Green} -height 30 -itemcolor {Yellow Green} -label RST_N /s2p_adaptor_vhd_tst/RST_N
add wave -noupdate -color Cyan -height 30 -itemcolor Cyan -label bit_ADC /s2p_adaptor_vhd_tst/test_s2p_adaptor/main/bit_ADC
add wave -noupdate -color Green -height 30 -itemcolor Green -label bit_DAC /s2p_adaptor_vhd_tst/test_s2p_adaptor/main/bit_DAC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27550000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 123
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
WaveRestoreZoom {0 ps} {96310287 ps}
