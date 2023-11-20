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
	
	wire [2:0] colour;
	wire [7:0] x, y;
	wire plot;

	wire gc_resetn;
	wire gc_enable;
	wire [7:0] gc_x_max;
	wire [7:0] gc_y_max;
	wire [7:0] gc_x;
	wire [7:0] gc_y;
	wire gc_eog;
	
	vga_adapter vga(
		.resetn(KEY[0]),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x), .y(y), .plot(plot),
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
	
	draw_triangle #(8,3) draw_tri(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.ax(8'd125), .ay(8'd34),
		.bx(8'd80), .by(8'd60),
		.cx(8'd0), .cy(8'd0),
		.colour(3'b111),
		.draw_en(~KEY[1]),
		.oX(x), .oY(y),
		.oColour(colour),
		.oPlot(plot),

		.gc_resetn(gc_resetn),
		.gc_enable(gc_enable),
		.gc_x_max(gc_x_max),
		.gc_y_max(gc_y_max),
		.gc_x(gc_x),
		.gc_y(gc_y),
		.gc_eog(gc_eog)
	);

	grid_counter #(8) gc(
		.clock			(CLOCK_50),
		.resetn			(gc_resetn),
		.enable			(gc_enable),
		.x_max			(gc_x_max),
		.y_max			(gc_y_max),
		.x				(gc_x),
		.y				(gc_y),
		.end_of_grid	(gc_eog)
	);
	
endmodule

module screen_writer(
	clock,
	resetn,
	screen_start,						// from interface
	new_screen_colour,					// from interface
	screen_x_min, screen_y_min,			// from interface
	screen_x_range, screen_y_range,		// from interface
	screen_x, screen_y,					// to interface
	old_screen_colour,					// to interface
	screen_done,						// to interface
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
	input wire resetn;
	input wire screen_start;								// from interface
	input wire [COLOUR_WIDTH-1:0] new_screen_colour;		// from interface
	input wire [WIDTH-1:0] screen_x_min, screen_y_min;		// from interface
	input wire [WIDTH-1:0] screen_x_range, screen_y_range;	// from interface
	output wire [WIDTH-1:0] screen_x, screen_y;				// to interface
	output wire [COLOUR_WIDTH-1:0] old_screen_colour;		// to interface
	output wire screen_done;								// to interface
	output wire VGA_CLK;   		//	VGA Clock
	output wire VGA_HS;			//	VGA H_SYNC
	output wire VGA_VS;			//	VGA V_SYNC
	output wire VGA_BLANK_N;	//	VGA BLANK
	output wire VGA_SYNC_N;		//	VGA SYNC
	output wire [7:0] VGA_R; 	//	VGA Red[9:0]
	output wire [7:0] VGA_G;	//	VGA Green[9:0]
	output wire [7:0] VGA_B;  	//	VGA Blue[9:0]

	reg current_state, next_state;
	wire [WIDTH-1:0] x_counter,y_counter;

	localparam
		S_WAIT = 1'd0,
		S_DRAW = 1'b1;

	assign screen_x = screen_x_min + x_counter;
	assign screen_y = screen_y_min + y_counter;
	assign old_screen_colour = 0;

	grid_counter #(8) gc(
		.clock			(clock),
		.resetn			(resetn & (current_state == S_DRAW)),
		.enable			(current_state == S_DRAW),
		.x_max			(screen_x_range),
		.y_max			(screen_y_range),
		.x				(x_counter),
		.y				(y_counter),
		.end_of_grid	(screen_done)
	);

	vga_adapter vga(
		.resetn(resetn),
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
		if(!resetn) current_state = S_WAIT;
		else current_state = next_state;
	end

endmodule