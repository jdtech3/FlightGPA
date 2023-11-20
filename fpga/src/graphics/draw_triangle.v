module draw_triangle(
	clock, resetn,
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
	screen_done,						// from interface
);

	parameter WIDTH=8;
	parameter COLOUR_WIDTH=3;

	input wire clock, resetn;
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

	reg current_state, next_state;
	wire [WIDTH-1:0] screen_x_max, screen_y_max;
	wire plot_point;
	
	localparam
		S_WAIT = 1'd0,
		S_DRAW = 1'b1;
	
	max #(WIDTH) max_x(ax, bx, cx, screen_x_max);
	max #(WIDTH) max_y(ay, by, cy, screen_y_max);
	min #(WIDTH) min_x(ax, bx, cx, screen_x_min);
	min #(WIDTH) min_y(ay, by, cy, screen_y_min);
	assign screen_x_range = screen_x_max - screen_x_min;
	assign screen_y_range = screen_y_max - screen_y_min;
	assign new_screen_colour = plot_point ? colour : old_screen_colour;
	assign screen_start = draw_en;
	assign draw_done = screen_done;
	
	inside_triangle #(16) in_tri(
		ax, ay,
		bx, by,
		cx, cy,
		screen_x, screen_y,
		plot_point
	);
	
	always @(*) begin
		case(current_state)
			S_WAIT: next_state <= draw_en ? S_DRAW : S_WAIT;
			S_DRAW: next_state <= draw_done ? S_WAIT : S_DRAW;
		endcase
	end
	
	always @(posedge clock) begin
		if(!resetn) current_state <= S_WAIT;
		else current_state <= next_state;
	end
	
endmodule

module inside_triangle(
	ax, ay, bx, by, cx, cy, px, py,
	out
);
	parameter WIDTH=16;
	input [WIDTH-1:0] ax, ay, bx, by, cx, cy, px, py;
	output out;
	wire o1, o2, o3;
	same_side #(WIDTH) s1(ax, ay, bx, by, cx, cy, px, py, o1);
	same_side #(WIDTH) s2(ax, ay, cx, cy, bx, by, px, py, o2);
	same_side #(WIDTH) s3(bx, by, cx, cy, ax, ay, px, py, o3);
	assign out = o1 & o2 & o3;
endmodule

module same_side(
	ax, ay, bx, by, p1x, p1y, p2x, p2y,
	out
);
	parameter WIDTH=16;
	input [WIDTH-1:0] ax, ay, bx, by, p1x, p1y, p2x, p2y;
	output out;

	wire [WIDTH-1:0] v1x, v1y, v2x, v2y, v3x, v3y, c1, c2;

	assign v1x = bx - ax;
	assign v1y = by - ay;
	assign v2x = p1x - ax;
	assign v2y = p1y - ay;
	assign v3x = p2x - ax;
	assign v3y = p2y - ay;
	
	cross2D #(WIDTH) cross1(v1x, v1y, v2x, v2y, c1);
	cross2D #(WIDTH) cross2(v1x, v1y, v3x, v3y, c2);
	
	assign out = c1[WIDTH-1] == c2[WIDTH-1];

endmodule