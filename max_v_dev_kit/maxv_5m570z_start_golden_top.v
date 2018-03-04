// Development kit top file.

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

reg [1:0] serial_i_buffer = 2'b00;
reg [1:0] reset_i_buffer = 2'b00;

wire clock_i;
wire serial_i_external;
wire serial_i;
wire reset_i;
wire reset_button;
wire serial_o;
wire write_busy_o;

Loopback #(
  .CLOCK_DIVIDER_WIDTH(7)
)
loopback (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .serial_i(serial_i),
  .serial_o(serial_o),
  .write_busy_o(write_busy_o),
  .clock_divider_i(7'd87),
  .two_stop_bits_i(1'b0),
  .parity_bit_i(1'b0),
  .parity_even_i(1'b0)
);

assign clock_i = CLK_SE_AR;
assign serial_i = serial_i_buffer[1];
assign serial_i_external = AGPIO[2];
assign AGPIO[1] = serial_o;
assign reset_i = reset_i_buffer[1];
assign reset_button = ~USER_PB0;
assign USER_LED0 = ~write_busy_o;
assign USER_LED1 = 1'b1;

always @ (posedge clock_i) begin
  reset_i_buffer[0] <= reset_button;
  reset_i_buffer[1] <= reset_i_buffer[0];

  serial_i_buffer[0] <= serial_i_external;
  serial_i_buffer[1] <= serial_i_buffer[0];
end

endmodule
