`timescale 1ps/1ps

module draw_test(
	input CLOCK_50,
	input [1:0] KEY,
	output VGA_CLK,   		//	VGA Clock
	output VGA_HS,			//	VGA H_SYNC
	output VGA_VS,			//	VGA V_SYNC
	output VGA_BLANK_N,		//	VGA BLANK
	output VGA_SYNC_N,		//	VGA SYNC
	output [7:0] VGA_R, 	//	VGA Red[9:0]
	output [7:0] VGA_G,		//	VGA Green[9:0]
	output [7:0] VGA_B  	//	VGA Blue[9:0]
);

    wire clock, reset;
	wire screen_start;
	wire [2:0] new_screen_colour;
	wire [15:0] screen_x_min, screen_y_min;
	wire [15:0] screen_x_range, screen_y_range;
	wire [15:0] screen_x, screen_y;
	wire [2:0] old_screen_colour;
	wire screen_done;
    wire pulse_1s;
    reg [2:0] colour;

    assign clock = CLOCK_50;
    assign reset = ~KEY[0];

	draw_clear #(16,3,320,240) draw_clr(
		.clock(clock),
		.reset(reset),
		.colour(colour),
		.draw_en(pulse_1s),

		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min), .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range), .screen_y_range(screen_y_range),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done)
	);

	screen_writer #(16,3) sw(
		.clock(clock),
		.reset(reset),
		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min), .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range), .screen_y_range(screen_y_range),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);

    pulse #(
        .DURATION(1000),
        .CLOCK_FREQUENCY(50000000))
    generate_pulse_1s(
        clock,reset,pulse_1s
    );

    always @(posedge pulse_1s or posedge reset) begin
        if(reset) colour<=0;
        else colour<=colour+1;
    end
	
endmodule
