module motor(
    input clk,
    input rst,
    input [2:0]mode,
    output [1:0]pwm,
    output reg [1:0]r_IN,
    output reg [1:0]l_IN
);

    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);

    assign pwm = {left_pwm,right_pwm};

    // Control the speed and direction of the two motors based on the mode input
    always @(*) begin
        case (mode)
            3'b000: begin
                left_motor = 10'd0; // Stop both motors
                right_motor = 10'd0;
                r_IN = 2'b00; // No direction
                l_IN = 2'b00;
            end
            3'b001: begin // kiri
                left_motor = 10'd817; // Left motor at ~60% duty cycle, left motor control right wheel
                right_motor = 10'd690; // Right motor at ~80% duty cycle
                r_IN = 2'b01; // Forward
                l_IN = 2'b10; // Forward
            end
            3'b010: begin // kanan
                left_motor = 10'd690; // Left motor at ~80% duty cycle
                right_motor = 10'd817; // Right motor at ~60% duty cycle
                r_IN = 2'b01; // Both motors forward
                l_IN = 2'b10; // Both motors forward
            end
            3'b011: begin
                left_motor = 10'd750; // Forward at ~80% duty cycle
                right_motor = 10'd750;
                r_IN = 2'b01; // Both motors forward
                l_IN = 2'b10; // Both motors forward
            end
            3'b100: begin //move backward
                left_motor = 10'd750; // Forward at ~80% duty cycle
                right_motor = 10'd750;
                r_IN = 2'b10; // Both motors forward
                l_IN = 2'b01; // Both motors forward
            end
            default: begin
                left_motor = 10'd0;
                right_motor = 10'd0;
                r_IN = 2'b00;
                l_IN = 2'b00;
            end
        endcase
    end

    
endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
 output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
 input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            PWM <= (count < count_duty) ? 1 : 0; // Set PWM high for the duty cycle duration
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule