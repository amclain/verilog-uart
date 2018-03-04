// Loopback UART RX to TX.

module Loopback #(
  parameter CLOCK_DIVIDER_WIDTH = 16
) (
  input reset_i,
  input clock_i,
  input [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider_i,
  input serial_i,
  input two_stop_bits_i,
  input parity_bit_i,
  input parity_even_i,
  output serial_o,
  output write_busy_o
);

wire [7:0] data;
wire read_ready_o;
wire write_i;
wire ack_i;

Uart #(
  .CLOCK_DIVIDER_WIDTH(CLOCK_DIVIDER_WIDTH)
)
uart (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .clock_divider_i(clock_divider_i),
  .write_i(write_i),
  .ack_i(ack_i),
  .two_stop_bits_i(two_stop_bits_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .data_i(data),
  .data_o(data),
  .serial_i(serial_i),
  .serial_o(serial_o),
  .write_busy_o(write_busy_o),
  .read_ready_o(read_ready_o)
);

assign write_i = read_ready_o & !write_busy_o;
assign ack_i = write_busy_o;

endmodule
