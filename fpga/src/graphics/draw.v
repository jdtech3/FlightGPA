module draw(
    clock, reset,
    opcode,
	ax, ay, bx, by, cx, cy,
	colour,
	draw_en,
	draw_done,

	screen_start,						// to interface
	new_screen_colour,					// to interface
	screen_x_min, screen_y_min,			// to interface
	screen_x_range, screen_y_range,		// to interface
	screen_x, screen_y,					// from interface
	old_screen_colour,					// from interface
	screen_done							// from interface
);

	parameter WIDTH=8;
	parameter COLOUR_WIDTH=3;
    parameter SCREEN_SIZE_X = 160;
    parameter SCREEN_SIZE_Y = 120;
    localparam OPCODE_WIDTH = 3;

	input wire clock, reset;
    input wire [OPCODE_WIDTH-1:0] opcode;
	input wire [WIDTH-1:0] ax, ay, bx, by, cx, cy;
	input wire [COLOUR_WIDTH-1:0] colour;
	input wire draw_en;
	output wire draw_done;
	
	output wire screen_start;								// to interface
	output wire [COLOUR_WIDTH-1:0] new_screen_colour;		// to interface
	output wire [WIDTH-1:0] screen_x_min, screen_y_min;		// to interface
	output wire [WIDTH-1:0] screen_x_range, screen_y_range;	// to interface
	input wire [WIDTH-1:0] screen_x, screen_y;				// from interface
	input wire [COLOUR_WIDTH-1:0] old_screen_colour;		// from interface
	input wire screen_done;									// from interface

    localparam
        OP_CLEAR = 0,
        OP_TRIANGLE = 1;
    
    wire op_triangle, op_clear;

	wire draw_done_by_opcode [OPCODE_WIDTH-1:0];
	wire screen_start_by_opcode [OPCODE_WIDTH-1:0];
	wire [COLOUR_WIDTH-1:0] new_screen_colour_by_opcode [OPCODE_WIDTH-1:0];
	wire [WIDTH-1:0] screen_x_min_by_opcode [OPCODE_WIDTH-1:0];
	wire [WIDTH-1:0] screen_y_min_by_opcode [OPCODE_WIDTH-1:0];
	wire [WIDTH-1:0] screen_x_range_by_opcode [OPCODE_WIDTH-1:0];
	wire [WIDTH-1:0] screen_y_range_by_opcode [OPCODE_WIDTH-1:0];

    assign op_clear = opcode == OP_CLEAR;
    assign op_triangle = opcode == OP_TRIANGLE;

    assign draw_done = draw_done_by_opcode[opcode];
    assign screen_start = screen_start_by_opcode[opcode];
	assign new_screen_colour = new_screen_colour_by_opcode[opcode];
	assign screen_x_min = screen_x_min_by_opcode[opcode];
	assign screen_y_min = screen_y_min_by_opcode[opcode];
	assign screen_x_range = screen_x_range_by_opcode[opcode];
	assign screen_y_range = screen_y_range_by_opcode[opcode];
	
	draw_clear #(
        .WIDTH(WIDTH),
        .COLOUR_WIDTH(COLOUR_WIDTH),
		.SCREEN_SIZE_X(SCREEN_SIZE_X),
		.SCREEN_SIZE_Y(SCREEN_SIZE_Y))
    d_clear(
		.clock(clock),
		.reset(reset),
		.colour(colour),
		.draw_en(draw_en & op_clear),
        .draw_done(draw_done_by_opcode[OP_CLEAR]),

		.screen_start(screen_start_by_opcode[OP_CLEAR]),
		.new_screen_colour(new_screen_colour_by_opcode[OP_CLEAR]),
		.screen_x_min(screen_x_min_by_opcode[OP_CLEAR]),
		.screen_y_min(screen_y_min_by_opcode[OP_CLEAR]),
		.screen_x_range(screen_x_range_by_opcode[OP_CLEAR]),
		.screen_y_range(screen_y_range_by_opcode[OP_CLEAR]),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done));

    draw_triangle #(
        .WIDTH(WIDTH),
        .COLOUR_WIDTH(COLOUR_WIDTH))
    d_triangle(
		.clock(clock),
		.reset(reset),
		.ax(ax), .ay(ay),
		.bx(bx), .by(by),
		.cx(cx), .cy(cy),
		.colour(colour),
		.draw_en(draw_en & op_triangle),
        .draw_done(draw_done_by_opcode[OP_TRIANGLE]),

		.screen_start(screen_start_by_opcode[OP_TRIANGLE]),
		.new_screen_colour(new_screen_colour_by_opcode[OP_TRIANGLE]),
		.screen_x_min(screen_x_min_by_opcode[OP_TRIANGLE]),
		.screen_y_min(screen_y_min_by_opcode[OP_TRIANGLE]),
		.screen_x_range(screen_x_range_by_opcode[OP_TRIANGLE]),
		.screen_y_range(screen_y_range_by_opcode[OP_TRIANGLE]),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done));


endmodule