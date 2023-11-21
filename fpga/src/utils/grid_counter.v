module grid_counter(clock, reset, enable, x_max, y_max, x, y, end_of_grid);
	parameter WIDTH=8;
	input wire clock, reset, enable;
	input wire [WIDTH-1:0] x_max, y_max;
	output wire [WIDTH-1:0] x, y;
	output end_of_grid;
	
	wire x_max_reached, y_max_reached;
	assign x_max_reached = x == x_max;
	assign y_max_reached = y == y_max;
	assign end_of_grid = x_max_reached & y_max_reached;
	
	counter #(WIDTH) xCounter(clock, reset | x_max_reached, enable, x);
	counter #(WIDTH) yCounter(clock, reset | end_of_grid, x_max_reached, y);
endmodule