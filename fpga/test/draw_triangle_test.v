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
	wire [7:0] gc_eog;
	
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
	
	draw_triangle draw_tri(
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
