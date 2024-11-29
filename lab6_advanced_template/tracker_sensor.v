module tracker_sensor(clk, reset, left_track, right_track, mid_track, state);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] state; // 00: Stop, 01: Turn left, 10: Turn right, 11: Move forward

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.
    /*always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 2'b00; // Stop state on reset
        end else begin
            case ({left_track, mid_track, right_track})
                3'b101: state <= 2'b11; // Move forward if only mid_track is high
                3'b011: state <= 2'b01; // Turn left if left_track is high
                3'b110: state <= 2'b10; // Turn right if right_track is high
                default: state <= 2'b00; // Stop if no track is detected or multiple tracks
            endcase
        end
    end*/
endmodule
