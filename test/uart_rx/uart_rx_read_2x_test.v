// Test reads with 2x clock divider.

module UartRxRead2xTest ();

reg reset_i = 1'b0;
reg clock_i = 1'b0;
reg clear_ready_i = 1'b0;
reg parity_bit_i = 1'b0;
reg parity_even_i = 1'b0;
reg serial_i = 1'b1;
reg [15:0] clock_divider_i = 2;
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
  #1 send_packet(8'h55);
  #6 assert_data_received(8'h55);
  #2 clear_ready_flag();
  
  #2 send_packet(8'hAA);
  #6 assert_data_received(8'hAA);
  #2 clear_ready_flag();
end

task send_packet;
  input [7:0] data;

  begin
    #4 serial_i <= 1'b0; // Start bit
    #4 serial_i <= data[0];
    #4 serial_i <= data[1];
    #4 serial_i <= data[2];
    #4 serial_i <= data[3];
    #4 serial_i <= data[4];
    #4 serial_i <= data[5];
    #4 serial_i <= data[6];
    #4 serial_i <= data[7];
    #4 serial_i <= 1'b1; // Stop bit
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
