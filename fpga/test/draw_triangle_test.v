`timescale 1ps/1ps

module draw_triangle_test(
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

	wire screen_start;
	wire [2:0] new_screen_colour;
	wire [7:0] screen_x_min, screen_y_min;
	wire [7:0] screen_x_range, screen_y_range;
	wire [7:0] screen_x, screen_y;
	wire [2:0] old_screen_colour;
	wire screen_done;

	draw_triangle #(16,3) draw_tri(
		.clock(CLOCK_50),
		.reset(~KEY[0]),
		.ax(16'd0), .ay(16'd0),
		.bx(16'd160), .by(16'd100),
		.cx(16'd60), .cy(16'd100),
		.colour(3'b111),
		.draw_en(~KEY[1]),

		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min), .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range), .screen_y_range(screen_y_range),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done)
	);

	screen_writer #(16,3) sw(
		.clock(CLOCK_50),
		.reset(~KEY[0]),
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
	
endmodule

module screen_writer(
	clock,
	reset,
	screen_start,						// from logic
	new_screen_colour,					// from logic
	screen_x_min, screen_y_min,			// from logic
	screen_x_range, screen_y_range,		// from logic
	screen_x, screen_y,					// to logic
	old_screen_colour,					// to logic
	screen_done,						// to logic
	VGA_CLK,   		//	VGA Clock
	VGA_HS,			//	VGA H_SYNC
	VGA_VS,			//	VGA V_SYNC
	VGA_BLANK_N,	//	VGA BLANK
	VGA_SYNC_N,		//	VGA SYNC
	VGA_R, 			//	VGA Red[9:0]
	VGA_G,			//	VGA Green[9:0]
	VGA_B  			//	VGA Blue[9:0]
);

	parameter WIDTH=8;
	parameter COLOUR_WIDTH=3;

	input wire clock;
	input wire reset;
	input wire screen_start;								// from logic
	input wire [COLOUR_WIDTH-1:0] new_screen_colour;		// from logic
	input wire [WIDTH-1:0] screen_x_min, screen_y_min;		// from logic
	input wire [WIDTH-1:0] screen_x_range, screen_y_range;	// from logic
	output wire [WIDTH-1:0] screen_x, screen_y;				// to logic
	output wire [COLOUR_WIDTH-1:0] old_screen_colour;		// to logic
	output wire screen_done;								// to logic
	output wire VGA_CLK;   		//	VGA Clock
	output wire VGA_HS;			//	VGA H_SYNC
	output wire VGA_VS;			//	VGA V_SYNC
	output wire VGA_BLANK_N;	//	VGA BLANK
	output wire VGA_SYNC_N;		//	VGA SYNC
	output wire [7:0] VGA_R; 	//	VGA Red[9:0]
	output wire [7:0] VGA_G;	//	VGA Green[9:0]
	output wire [7:0] VGA_B;  	//	VGA Blue[9:0]

	reg current_state, next_state;
	wire [WIDTH-1:0] x_counter, y_counter;

	localparam
		S_WAIT = 1'd0,
		S_DRAW = 1'b1;

	assign screen_x = screen_x_min + x_counter;
	assign screen_y = screen_y_min + y_counter;
	assign old_screen_colour = 0;

	grid_counter #(WIDTH) gc(
		.clock			(clock),
		.reset			(reset || current_state != S_DRAW),
		.enable			(current_state == S_DRAW),
		.x_max			(screen_x_range),
		.y_max			(screen_y_range),
		.x				(x_counter),
		.y				(y_counter),
		.end_of_grid	(screen_done)
	);

	vga_adapter vga(
		.resetn(~reset),
		.clock(clock),
		.colour(new_screen_colour),
		.x(screen_x), .y(screen_y),
		.plot(current_state == S_DRAW),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK)
	);

	defparam vga.RESOLUTION = "320x240";
	defparam vga.MONOCHROME = "FALSE";
	defparam vga.BITS_PER_COLOUR_CHANNEL = 1;
	defparam vga.BACKGROUND_IMAGE = "vga_adapter/black.mif";

	always @(*) begin
		case(current_state)
			S_WAIT: next_state <= screen_start ? S_DRAW : S_WAIT;
			S_DRAW: next_state <= screen_done ? S_WAIT : S_DRAW;
		endcase
	end
	
	always @(posedge clock) begin
		if(reset) current_state <= S_WAIT;
		else current_state <= next_state;
	end

endmodule