module draw_triangle(
	input wire clock, resetn,
	input wire [7:0] ax, ay, bx, by, cx, cy,
	input wire [2:0] colour,
	input wire draw_en,
	output wire [7:0] oX, oY,
	output wire [2:0] oColour,
	output wire oPlot,
	output wire oDone
);

	reg current_state, next_state;
	wire [7:0] x_counter,y_counter;
	wire end_of_grid;
	wire [7:0] x_max, x_min, x_range, y_max, y_min, y_range;
	wire plot_point;
	
	localparam
		S_WAIT = 1'd0,
		S_DRAW = 1'b1;
	
	max max_x(ax, bx, cx, x_max);
	max max_y(ay, by, cy, y_max);
	min min_x(ax, bx, cx, x_min);
	min min_y(ay, by, cy, y_min);
	assign x_range = x_max - x_min;
	assign y_range = y_max - y_min;
	assign oX = x_min + x_counter;
	assign oY = y_min + y_counter;
	assign oColour = colour;
	assign oPlot = plot_point & current_state == S_DRAW;
	assign oDone = current_state == S_WAIT;
	
	grid_counter #(8) gc(
		.clock			(clock),
		.resetn			(resetn & (current_state == S_DRAW)),
		.enable			(current_state == S_DRAW),
		.x_max			(x_range),
		.y_max			(y_range),
		.x				(x_counter),
		.y				(y_counter),
		.end_of_grid	(end_of_grid)
	);
	
	inside_triangle in_tri(
		{8'd0,ax}, {8'd0,ay},
		{8'd0,bx}, {8'd0,by},
		{8'd0,cx}, {8'd0,cy},
		{8'd0,oX}, {8'd0,oY},
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
	input [15:0] ax, ay, bx, by, cx, cy, px, py,
	output out
);
	wire o1, o2, o3;
	same_side s1(ax, ay, bx, by, cx, cy, px, py, o1);
	same_side s2(ax, ay, cx, cy, bx, by, px, py, o2);
	same_side s3(bx, by, cx, cy, ax, ay, px, py, o3);
	assign out = o1 & o2 & o3;
endmodule

module same_side(
	input [15:0] ax, ay, bx, by, p1x, p1y, p2x, p2y,
	output out
);

	wire [15:0] v1x, v1y, v2x, v2y, v3x, v3y, c1, c2;

	assign v1x = bx - ax;
	assign v1y = by - ay;
	assign v2x = p1x - ax;
	assign v2y = p1y - ay;
	assign v3x = p2x - ax;
	assign v3y = p2y - ay;
	
	cross2D cross1(v1x, v1y, v2x, v2y, c1);
	cross2D cross2(v1x, v1y, v3x, v3y, c2);
	
	assign out = c1[15] == c2[15];

endmodule