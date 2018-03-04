// Test reads with parity bit.

module UartRxParityTest ();

reg reset_i = 1'b0;
reg clock_i = 1'b0;
reg ack_i = 1'b0;
reg parity_bit_i = 1'b1;
reg parity_even_i = 1'b1;
reg serial_i = 1'b1;
reg [15:0] clock_divider_i = 2;
wire [7:0] data_o;
wire ready_o;

UartRx uart_rx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .ack_i(ack_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .serial_i(serial_i),
  .clock_divider_i(clock_divider_i),
  .data_o(data_o),
  .ready_o(ready_o)
);

always #1 clock_i <= ~clock_i;

initial begin
  #1 send_packet(8'h55, 1'b0);
  #6 assert_data_received(8'h55);
  #2 clear_ready_flag();
  
  parity_even_i = 1'b0;

  #2 send_packet(8'hAA, 1'b1);
  #6 assert_data_received(8'hAA);
  #2 clear_ready_flag();
end

task send_packet;
  input [7:0] data;
  input parity;

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
    #4 serial_i <= parity;
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
    ack_i = 1'b1;

    if (!ready_o)
      $display("FAILED - ready_o should stay high after receiving packet");

    #2 ack_i = 1'b0;

    if (ready_o)
      $display("FAILED - ready_o should be low after ack_i goes high");
  end
endtask

endmodule
