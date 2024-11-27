// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0]mode,
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
            2'b00: begin
                left_motor = 10'd0; // Stop both motors
                right_motor = 10'd0;
                r_IN = 2'b00; // No direction
                l_IN = 2'b00;
            end
            2'b01: begin
                left_motor = 10'd614; // Left motor at ~60% duty cycle
                right_motor = 10'd717; // Right motor at ~80% duty cycle
                r_IN = 2'b01; // Forward
                l_IN = 2'b01; // Forward
            end
            2'b10: begin
                left_motor = 10'd717; // Left motor at ~80% duty cycle
                right_motor = 10'd614; // Right motor at ~60% duty cycle
                r_IN = 2'b01; // Both motors forward
                l_IN = 2'b01; // Both motors forward
            end
            2'b11: begin
                left_motor = 10'd717; // Forward at ~80% duty cycle
                right_motor = 10'd717;
                r_IN = 2'b01; // Both motors forward
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

