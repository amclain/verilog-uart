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
reg serial_i_buffer_1 = 1'b0;
reg serial_i_buffer_2 = 1'b0;
reg [1:0] reset_i_buffer = 2'b00;

wire clock_i;
wire [7:0] data;
wire serial_i;
wire serial_o;
wire reset_i;
wire reset_button;
wire write_busy_o;
wire read_ready_o;
wire write_i;
wire ack_i;

Uart #(
  .CLOCK_DIVIDER_WIDTH(7)
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
  .serial_i(serial_i_buffer_2),
  .serial_o(serial_o),
  .write_busy_o(write_busy_o),
  .read_ready_o(read_ready_o)
);

assign clock_i = CLK_SE_AR;
assign serial_i = AGPIO[2];
assign AGPIO[1] = serial_o;
assign USER_LED0 = ~write_busy_o;
assign USER_LED1 = 1'b1;
assign reset_button = ~USER_PB0;
assign reset_i = reset_i_buffer[1];

assign write_i = read_ready_o & !write_busy_o;
assign ack_i = write_busy_o;

always @ (posedge clock_i) begin
  reset_i_buffer[0] <= reset_button;
  reset_i_buffer[1] <= reset_i_buffer[0];

  serial_i_buffer_1 <= serial_i;
  serial_i_buffer_2 <= serial_i_buffer_1;
end

endmodule
