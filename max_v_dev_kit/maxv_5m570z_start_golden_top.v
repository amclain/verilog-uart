module maxv_5m570z_start_golden_top(
  input CLK_SE_AR,

  // GPIO
  input USER_PB0, USER_PB1,
  input CAP_PB_1,
  output USER_LED0,
  output reg USER_LED1,

  // Connector A 
  output [36:1] AGPIO,

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

assign AGPIO[36:3] = 1'b0;
assign AGPIO[2] = write_i; // DEBUG ///////////////////////////////////////
assign AGPIO[1] = serial_o;
assign USER_LED0 = ~busy_o;

reg write_i = 1'b0;
reg [7:0] data_i = 8'h00;

wire busy_o;
wire serial_o;

UartTx #(
  .CLOCK_DIVIDER_WIDTH(7)
)
uart_tx (
  .reset_i(~USER_PB0),
  .clock_i(CLK_SE_AR),
  .write_i(write_i),
  .two_stop_bits_i(1'b0),
  .parity_bit_i(1'b0),
  .parity_even_i(1'b0),
  .clock_divider_i(7'd87),
  .data_i(data_i),
  .serial_o(serial_o),
  .busy_o(busy_o)
);

localparam STATE_WAIT = 0;
localparam STATE_WRITE = 1;
localparam STATE_END_WRITE = 2;

reg [23:0] one_second_counter = 24'd0;
reg [1:0] tx_state = 2'd0;

always @ (posedge CLK_SE_AR) begin
  case (tx_state)
    STATE_WAIT:
      if (one_second_counter < 10000000) begin
        one_second_counter <= one_second_counter + 1'd1;
      end
      else begin
        USER_LED1 <= ~USER_LED1; // Heartbeat LED
        one_second_counter <= 0;
        tx_state <= STATE_WRITE;
      end

    STATE_WRITE:
      begin
        data_i <= 8'h55;
        write_i <= 1'b1;
        tx_state <= STATE_END_WRITE;
      end

    STATE_END_WRITE:
      begin
        write_i <= 1'b0;
        tx_state <= STATE_WAIT;
      end

    default:
      tx_state <= STATE_WAIT;
  endcase
end

endmodule
