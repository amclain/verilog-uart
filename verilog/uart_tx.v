module UartTx #(
  parameter CLOCK_DIVIDER_WIDTH = 16
)
(
  input reset_i,
  input clock_i,
  input [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider_i,
  input write_i,
  input [7:0] data_i,
  output reg serial_o = 1'b1,
  output busy_o
);

localparam STATE_POST_RESET = 0;
localparam STATE_IDLE = 1;
localparam STATE_SEND_START_BIT = 2;
localparam STATE_SEND_DATA_BIT = 3;
localparam STATE_SEND_STOP_BIT = 4;

reg [2:0] state = STATE_POST_RESET;
reg [CLOCK_DIVIDER_WIDTH - 1:0] bit_timer = 0;
reg [3:0] select_data_bit = 0;
reg [7:0] data = 8'h00;

wire [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider;

assign busy_o = (state == STATE_IDLE && !reset_i) ? 1'b0 : 1'b1;
assign clock_divider = (clock_divider_i > 0) ? clock_divider_i - 1'd1 : 1'd0;

always @ (posedge reset_i, posedge clock_i) begin
  if (reset_i) begin
    state <= STATE_POST_RESET;
    bit_timer <= 0;
    select_data_bit <= 0;
    data <= 8'h00;
    serial_o <= 1'b1;
  end
  else begin
    case (state)
      // This state delays operation for the length of 1 packet so that if the
      // module was reset in the middle of transmission the receiving side
      // will time out.
      STATE_POST_RESET:
        if (bit_timer < clock_divider) begin
          bit_timer <= bit_timer + 1'd1;
        end
        // Reusing `select_data_bit` as an overall bit counter for the packet.
        else if (select_data_bit <= 10) begin
          bit_timer <= 0;
          select_data_bit <= select_data_bit + 1'd1;
        end
        else begin
          state <= STATE_IDLE;
        end

      STATE_IDLE:
        begin
          bit_timer <= 0;
          select_data_bit <= 0;
          serial_o <= 1'b1;

          if (write_i) begin
            data <= data_i;
            state <= STATE_SEND_START_BIT;
          end
        end

      STATE_SEND_START_BIT:
        begin
          serial_o <= 1'b0;

          if (bit_timer < clock_divider) begin
            bit_timer <= bit_timer + 1'd1;
          end
          else begin
            bit_timer <= 0;
            state <= STATE_SEND_DATA_BIT;
          end
        end

      STATE_SEND_DATA_BIT:
        if (select_data_bit <= 4'd7) begin
          serial_o <= data[select_data_bit];

          if (bit_timer < clock_divider) begin
            bit_timer <= bit_timer + 1'd1;
          end
          else begin
            bit_timer <= 0;
            select_data_bit <= select_data_bit + 1'd1;
          end
        end
        else begin
          serial_o <= 1'b1;
          bit_timer <= 0;
          state <= STATE_SEND_STOP_BIT;
        end

      STATE_SEND_STOP_BIT:
        begin
          serial_o <= 1'b1;

          if (bit_timer < clock_divider) begin
            bit_timer <= bit_timer + 1'd1;
          end
          else begin
            bit_timer <= 0;
            state <= STATE_IDLE;
          end
        end

      default:
        state <= STATE_IDLE;
    endcase
  end
end

endmodule
