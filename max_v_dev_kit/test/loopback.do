onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /loopbackTest/clock_i
add wave -noupdate -color Yellow /loopbackTest/serial_i
add wave -noupdate -color Orange /loopbackTest/serial_o
add wave -noupdate -divider RX
add wave -noupdate /loopbackTest/dut/uart_rx/reset_i
add wave -noupdate -color Yellow /loopbackTest/dut/uart_rx/serial_i
add wave -noupdate /loopbackTest/dut/uart_rx/ready_o
add wave -noupdate /loopbackTest/dut/uart_rx/clear_ready_i
add wave -noupdate -color Cyan -radix hexadecimal /loopbackTest/dut/uart_rx/data_o
add wave -noupdate /loopbackTest/dut/uart_rx/packet_valid
add wave -noupdate -radix unsigned /loopbackTest/dut/uart_rx/state
add wave -noupdate -radix unsigned /loopbackTest/dut/uart_rx/bit_timer
add wave -noupdate -divider TX
add wave -noupdate /loopbackTest/dut/uart_tx/reset_i
add wave -noupdate -color Yellow /loopbackTest/dut/uart_tx/serial_o
add wave -noupdate /loopbackTest/dut/uart_tx/write_i
add wave -noupdate /loopbackTest/dut/uart_tx/busy_o
add wave -noupdate -color Cyan -radix hexadecimal /loopbackTest/dut/uart_tx/data_i
add wave -noupdate -radix hexadecimal /loopbackTest/dut/uart_tx/data
add wave -noupdate -radix unsigned /loopbackTest/dut/uart_tx/state
add wave -noupdate -radix unsigned /loopbackTest/dut/uart_tx/bit_timer
add wave -noupdate -radix unsigned /loopbackTest/dut/uart_tx/select_packet_bit
add wave -noupdate /loopbackTest/dut/uart_tx/write_has_triggered
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 335
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {8400 ps}
