module loopbackTest ();

reg clock_i = 1'b0;
reg reset_i = 1'b0;
reg serial_i = 1'b1;

wire [36:1] gpio;
wire serial_o;

maxv_5m570z_start_golden_top dut (
  .CLK_SE_AR(clock_i),
  .AGPIO(gpio),
  .USER_PB0(~reset_i)

  // .USER_LED0(USER_LED0),
  // .USER_LED1(USER_LED1),
  // .USER_PB1(1'b0),
  // .CAP_PB_1(1'b0)
  // .BGPIO(30'b0),
  // .BGPIO_P_1(1'b0),
  // .BGPIO_N_1(1'b0),
  // .BGPIO_P_2(1'b0),
  // .BGPIO_N_2(1'b0),
  // .BGPIO_P_3(1'b0),
  // .BGPIO_N_3(1'b0),
  // .MOTOR_1_FB_A(1'b0),
  // .MOTOR_1_FB_B(1'b0),
  // .MOTOR_1_CTRL(1'b0),
  // .MAX_MOTOR_1(6'b0),
  // .MOTOR_2_FB_A(1'b0),
  // .MOTOR_2_FB_B(1'b0),
  // .MOTOR_2_CTRL(1'b0),
  // .MAX_MOTOR_2(6'b0),
  // .MAX_SPK(8'b0),
  // .I2C_PROM_SCL(1'b0),
  // .I2C_PROM_SDA(1'b0),
  // .SPI_MOSI(1'b0),
  // .SPI_SCK(1'b0),
  // .SPI_CSN(1'b0),
  // .SPI_MISO(1'b0)
);

assign gpio[36:3] = 33'b0;
assign serial_o = gpio[1];
assign gpio[2] = serial_i;

always #1 clock_i <= ~clock_i;

initial begin
  #1
  send_packet(8'h55);
  send_packet(8'hAA);
  send_packet(8'hCC);
  send_packet(8'h33);
end

task send_packet;
  input [7:0] data;

  begin
    #174 serial_i <= 1'b0; // Start bit
    #174 serial_i <= data[0];
    #174 serial_i <= data[1];
    #174 serial_i <= data[2];
    #174 serial_i <= data[3];
    #174 serial_i <= data[4];
    #174 serial_i <= data[5];
    #174 serial_i <= data[6];
    #174 serial_i <= data[7];
    #174 serial_i <= 1'b1; // Stop bit
  end
endtask

endmodule
