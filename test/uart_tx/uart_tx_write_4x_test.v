// Test writes with a 4x clock divider.

module UartTxWrite4xTest ();

reg reset_i = 1'b0;
reg clock_i = 1'b0;
reg write_i = 1'b0;
reg two_stop_bits_i = 1'b0;
reg parity_bit_i = 1'b0;
reg parity_even_i = 1'b0;
reg [2:0] clock_divider_i = 3'd4;
reg [7:0] data_i = 8'h00;
wire serial_o;
wire busy_o;

UartTx #(
  .CLOCK_DIVIDER_WIDTH(3)
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
  .serial_o(serial_o),
  .busy_o(busy_o)
);

always #1 clock_i <= ~clock_i;

always @ (posedge serial_o, negedge serial_o) begin
  if (!busy_o)
    $display("FAILED - busy_o should be high when serial_o transitions");
end

initial begin
  #1 reset_i = 1'b1;
  #1 reset_i = 1'b0;
  @ (negedge busy_o); // Wait for reset.

  #2 send_byte(8'h55);
  #2 send_byte(8'hAA);
end

task send_byte;
  input [7:0] data;

  begin
    #2
    data_i = data;
    write_i = 1'b1;

    #4 write_i = 1'b0;

    #4 if (serial_o)
      $display("FAILED - start bit incorrect");

    #8 if (serial_o != data[0])
      $display("FAILED - data bit 0 incorrect");

    #8 if (serial_o != data[1])
      $display("FAILED - data bit 1 incorrect");

    #8 if (serial_o != data[2])
      $display("FAILED - data bit 2 incorrect");

    #8 if (serial_o != data[3])
      $display("FAILED - data bit 3 incorrect");

    #8 if (serial_o != data[4])
      $display("FAILED - data bit 4 incorrect");

    #8 if (serial_o != data[5])
      $display("FAILED - data bit 5 incorrect");

    #8 if (serial_o != data[6])
      $display("FAILED - data bit 6 incorrect");

    #8 if (serial_o != data[7])
      $display("FAILED - data bit 7 incorrect");

    #8 if (!serial_o)
      $display("FAILED - stop bit incorrect");

    #4 if (busy_o)
      $display("FAILED - busy_o should be low after sending first packet");
  end
endtask

endmodule
