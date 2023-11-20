module draw_triangle(
	clock, resetn,
	ax, ay, bx, by, cx, cy,
	colour,
	draw_en,
	oX, oY,
	oColour,
	oPlot,
	oDone,

	gc_resetn,
	gc_enable,
	gc_x_max,
	gc_y_max,
	gc_x,
	gc_y,
	gc_eog
);

	parameter WIDTH=8;
	parameter COLOUR_WIDTH=3;

	input wire clock, resetn;
	input wire [WIDTH-1:0] ax, ay, bx, by, cx, cy;
	input wire [COLOUR_WIDTH-1:0] colour;
	input wire draw_en;
	output wire [WIDTH-1:0] oX, oY;
	output wire [COLOUR_WIDTH-1:0] oColour;
	output wire oPlot;
	output wire oDone;

	output wire gc_resetn;
	output wire gc_enable;
	output wire [WIDTH-1:0] gc_x_max;
	output wire [WIDTH-1:0] gc_y_max;
	input wire [WIDTH-1:0] gc_x;
	input wire [WIDTH-1:0] gc_y;
	input wire gc_eog;

	reg current_state, next_state;
	wire [WIDTH-1:0] x_counter,y_counter;
	wire end_of_grid;
	wire [WIDTH-1:0] x_max, x_min, x_range, y_max, y_min, y_range;
	wire plot_point;
	
	localparam
		S_WAIT = 1'd0,
		S_DRAW = 1'b1;
	
	max #(WIDTH) max_x(ax, bx, cx, x_max);
	max #(WIDTH) max_y(ay, by, cy, y_max);
	min #(WIDTH) min_x(ax, bx, cx, x_min);
	min #(WIDTH) min_y(ay, by, cy, y_min);
	assign x_range = x_max - x_min;
	assign y_range = y_max - y_min;
	assign oX = x_min + x_counter;
	assign oY = y_min + y_counter;
	assign oColour = colour;
	assign oPlot = plot_point & current_state == S_DRAW;
	assign oDone = current_state == S_WAIT;

	assign gc_resetn = resetn & (current_state == S_DRAW);
	assign gc_enable = current_state == S_DRAW;
	assign gc_x_max = x_range;
	assign gc_y_max = y_range;
	assign x_counter = gc_x;
	assign y_counter = gc_y;
	assign end_of_grid = gc_eog;
	
	inside_triangle #(16) in_tri(
		ax, ay,
		bx, by,
		cx, cy,
		oX, oY,
		plot_point
	);
	
	always @(*) begin
		case(current_state)
			S_WAIT: next_state <= draw_en ? S_DRAW : S_WAIT;
			S_DRAW: next_state <= end_of_grid ? S_WAIT : S_DRAW;
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