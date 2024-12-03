module lab6_advanced(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    output trig,
    output IN1,
    output IN2,
    output IN3, 
    output IN4,
    output left_pwm,
    output right_pwm,
    output [6:0] led
);
    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    reg [2:0] mode;
    wire [19:0] distance;
    reg [2:0] onesecond;
    wire clk_div;
    
    clock_divider #(25) clk1 (.clk(clk), .clk_div(clk_div));
    
    motor A(
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .pwm({left_pwm, right_pwm}),
        .l_IN({IN1, IN2}),
        .r_IN({IN3, IN4})
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance)
    );

    tracker_sensor C(
        .clk(clk),
        .reset(rst),
        .left_track(left_track),
        .right_track(right_track),
        .mid_track(mid_track),
        .state(state)
    );

    assign led = {obstacle, left_track, mid_track, right_track, mode};
    
    reg obstacle;
    always @(*) begin
        if(distance < 20'd20) begin
            mode = 3'b000; // Stop both motors
            obstacle = 1'b1;
        end else begin
            obstacle = 1'b0;
            //mode = state;
            case ({left_track, mid_track, right_track})
                3'b101: mode = 3'b011; // Move forward if only mid_track is high
                3'b011: mode = 3'b001; // Turn left if left_track is high
                3'b110: mode = 3'b010; // Turn right if right_track is high
                3'b111: begin
                    if(onesecond == 3'b010)mode = 3'b100; // move backward
                    else mode = 3'b011;
                end
                3'b001:mode = 3'b101;
                3'b100:mode = 3'b110;
                default: mode = 3'b011; 
            endcase
        end
    end
    
    always@(posedge clk_div)begin
        if({left_track, mid_track, right_track} == 3'b111)begin
            if(onesecond != 3'b010)begin
                onesecond <= onesecond + 1'b1;
            end
        end
        else onesecond <= 1'b0;
    end
    
endmodule

module clock_divider #(
    parameter n = 27
)(
    input wire  clk,
    output wire clk_div  
);

    reg [n-1:0] num;
    wire [n-1:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

