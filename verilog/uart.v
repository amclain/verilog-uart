module Uart (
  input reset_i,
  input clock_i,
  input write_i,
  input [7:0] data_i,
  output busy_o,
  output serial_o
);

reg [7:0] clock_divider_i = 8'd217;

UartTx uart_tx
(
  .reset_i(reset_i),
  .clock_i(clock_i),
  .clock_divider_i(clock_divider_i),
  .write_i(write_i),
  .data_i(data_i),
  .busy_o(busy_o),
  .serial_o(serial_o)
);

endmodule