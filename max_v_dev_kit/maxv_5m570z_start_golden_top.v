// A loopback UART transceiver.

module maxv_5m570z_start_golden_top(
  input CLK_SE_AR,

  // GPIO
  input USER_PB0, USER_PB1,
  input CAP_PB_1,
  output USER_LED0,
  output USER_LED1,

  // Connector A 
  inout [36:1] AGPIO,

  // Connector B
  input [36:7] BGPIO,
  input BGPIO_P_1, BGPIO_N_1,
  input BGPIO_P_2, BGPIO_N_2,
  input BGPIO_P_3, BGPIO_N_3,

  // Motor 1
  input MOTOR_1_FB_A, MOTOR_1_FB_B, MOTOR_1_CTRL,
  input [5:0] MAX_MOTOR_1, 

  // Motor 2
  input MOTOR_2_FB_A, MOTOR_2_FB_B, MOTOR_2_CTRL,
  input [5:0] MAX_MOTOR_2, 

  // Speaker
  input [7:0] MAX_SPK, 

  // I2C EEPROM
  input I2C_PROM_SCL, I2C_PROM_SDA, 
   
  // SPI EEPROM
  input SPI_MOSI, SPI_SCK, SPI_CSN, SPI_MISO
);

reg [6:0] clock_divider_i = 7'd87;
reg two_stop_bits_i = 1'b0;
reg parity_bit_i = 1'b0;
reg parity_even_i = 1'b0;

wire [7:0] data;
wire serial_i;
wire serial_o;
wire reset_i;
wire write_i;
wire busy_o;
wire ready_o;
wire clear_ready_i;

UartTx #(
  .CLOCK_DIVIDER_WIDTH(7)
)
uart_tx (
  .reset_i(reset_i),
  .clock_i(CLK_SE_AR),
  .write_i(write_i),
  .two_stop_bits_i(two_stop_bits_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .clock_divider_i(clock_divider_i),
  .data_i(data),
  .serial_o(serial_o),
  .busy_o(busy_o)
);

UartRx #(
  .CLOCK_DIVIDER_WIDTH(7)
)
uart_rx (
  .reset_i(~USER_PB0),
  .clock_i(CLK_SE_AR),
  .clear_ready_i(clear_ready_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .serial_i(serial_i),
  .clock_divider_i(clock_divider_i),
  .data_o(data),
  .ready_o(ready_o)
);

assign serial_i = AGPIO[2];
assign AGPIO[1] = serial_o;
assign USER_LED0 = ~busy_o;
assign USER_LED1 = ~ready_o;
assign reset_i = ~USER_PB0;

assign write_i = ready_o & !busy_o;
assign clear_ready_i = busy_o;

endmodule
