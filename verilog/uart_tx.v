module UartTx #(
  parameter CLOCK_DIVIDER_WIDTH = 16
)
(
  input reset_i,
  input clock_i,
  input write_i,
  input two_stop_bits_i,
  input parity_bit_i,
  input parity_even_i,
  input [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider_i,
  input [7:0] data_i,
  output reg serial_o = 1'b1,
  output busy_o
);

localparam STATE_POST_RESET = 0;
localparam STATE_IDLE = 1;
localparam STATE_SEND_PACKET = 2;

reg [1:0] state = STATE_POST_RESET;
reg [CLOCK_DIVIDER_WIDTH - 1:0] bit_timer = 0;
reg [5:0] select_packet_bit = 0;
reg [7:0] data = 8'h00;
reg two_stop_bits = 1'b0;
reg parity_bit = 1'b0;
reg parity_even = 1'b0;
reg write_has_triggered = 1'b0;

wire [11:0] packet;
wire [CLOCK_DIVIDER_WIDTH - 1:0] clock_divider;
wire [3:0] total_bits_to_send = 4'd10 + two_stop_bits + parity_bit;
wire even_parity_value =
  1'h01 & (
    packet[8] +
    packet[7] +
    packet[6] +
    packet[5] +
    packet[4] +
    packet[3] +
    packet[2] +
    packet[1]
  );

assign busy_o = (state == STATE_IDLE && !reset_i) ? 1'b0 : 1'b1;
assign clock_divider = (clock_divider_i > 0) ? clock_divider_i - 1'd1 : 1'd0;

assign packet[0] = 1'b0; // Start bit
assign packet[8:1] = data;
assign packet[9] = parity_bit
  ? (parity_even ? even_parity_value : ~even_parity_value) // Parity bit
  : 1'b1; // Stop bit
assign packet[11:10] = 2'b11; // Definitely stop bits

always @ (posedge reset_i, posedge clock_i) begin
  if (reset_i) begin
    state <= STATE_POST_RESET;
    serial_o <= 1'b1;
    bit_timer <= 0;
    select_packet_bit <= 0;
    data <= 8'h00;
    two_stop_bits <= 1'b0;
    parity_bit <= 1'b0;
    parity_even <= 1'b0;
    write_has_triggered <= 1'b0;
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
        // Reusing `select_packet_bit` as an overall bit counter for the packet.
        else if (select_packet_bit < 12) begin
          bit_timer <= 0;
          select_packet_bit <= select_packet_bit + 1'd1;
        end
        else begin
          state <= STATE_IDLE;
        end

      STATE_IDLE:
        begin
          serial_o <= 1'b1;
          bit_timer <= 0;
          select_packet_bit <= 0;

          if (!write_i)
            write_has_triggered <= 1'b0;

          if (write_i && !write_has_triggered) begin
            data <= data_i;
            two_stop_bits <= two_stop_bits_i;
            parity_bit <= parity_bit_i;
            parity_even <= parity_even_i;
            write_has_triggered <= 1'b1;

            state <= STATE_SEND_PACKET;
          end
        end

      STATE_SEND_PACKET:
        if (select_packet_bit < total_bits_to_send) begin
          serial_o <= packet[select_packet_bit];

          if (bit_timer < clock_divider) begin
            bit_timer <= bit_timer + 1'd1;
          end
          else begin
            bit_timer <= 0;
            select_packet_bit <= select_packet_bit + 1'd1;
          end
        end
        else begin
          bit_timer <= 0;
          state <= STATE_IDLE;
        end

      default:
        state <= STATE_IDLE;
    endcase
  end
end

endmodule
