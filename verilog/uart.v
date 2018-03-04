module Uart #(
  parameter CLOCK_DIVIDER_WIDTH = 16
) (
  input reset_i,
  input clock_i,
  input [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider_i,
  input serial_i,
  input write_i,
  input ack_i,
  input two_stop_bits_i,
  input parity_bit_i,
  input parity_even_i,
  input [7:0] data_i,
  output [7:0] data_o,
  output write_busy_o,
  output read_ready_o,
  output serial_o
);

UartTx #(
  .CLOCK_DIVIDER_WIDTH(CLOCK_DIVIDER_WIDTH)
)
uart_tx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .write_i(write_i),
  .two_stop_bits_i(two_stop_bits_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .clock_divider_i(clock_divider_i),
  .data_i(data_i),
  .busy_o(write_busy_o),
  .serial_o(serial_o)
);

UartRx #(
  .CLOCK_DIVIDER_WIDTH(CLOCK_DIVIDER_WIDTH)
)
uart_rx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .ack_i(ack_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .serial_i(serial_i),
  .clock_divider_i(clock_divider_i),
  .data_o(data_o),
  .ready_o(read_ready_o)
);

endmodule
