// Test abort read if start bit is invalid.
// For example, noise on the line.

module UartRxInvalidStartBitTest ();

reg reset_i = 1'b0;
reg clock_i = 1'b0;
reg clear_ready_i = 1'b0;
reg parity_bit_i = 1'b0;
reg parity_even_i = 1'b0;
reg serial_i = 1'b1;
reg [15:0] clock_divider_i = 4;
wire [7:0] data_o;
wire ready_o;

UartRx uart_rx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .clear_ready_i(clear_ready_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .serial_i(serial_i),
  .clock_divider_i(clock_divider_i),
  .data_o(data_o),
  .ready_o(ready_o)
);

always #1 clock_i <= ~clock_i;

initial begin
  #5 serial_i = 1'b0;
  #2 serial_i = 1'b1;
  send_packet(8'h55);
  #8 assert_data_received(8'h55);
  clear_ready_flag();
end

task send_packet;
  input [7:0] data;

  begin
    #8 serial_i <= 1'b0; // Start bit
    #8 serial_i <= data[0];
    #8 serial_i <= data[1];
    #8 serial_i <= data[2];
    #8 serial_i <= data[3];
    #8 serial_i <= data[4];
    #8 serial_i <= data[5];
    #8 serial_i <= data[6];
    #8 serial_i <= data[7];
    #8 serial_i <= 1'b1; // Stop bit
  end
endtask

task assert_data_received;
  input [7:0] data;

  begin
    if (!ready_o)
    $display("FAILED - ready_o should be high after receiving packet");

    if (data_o != data)
      $display("FAILED - data_o value should be h%x", data);
  end
endtask

task clear_ready_flag;
  begin
    clear_ready_i = 1'b1;

    if (!ready_o)
      $display("FAILED - ready_o should stay high after receiving packet");

    #2 clear_ready_i = 1'b0;

    if (ready_o)
      $display("FAILED - ready_o should be low after clear_ready_i goes high");
  end
endtask

endmodule
