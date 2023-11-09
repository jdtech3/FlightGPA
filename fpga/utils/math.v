

module min(input [7:0] a, b, c, output [7:0] out);
	wire [7:0] min_ab;
	assign min_ab = a < b ? a : b;
	assign out = c < min_ab ? c : min_ab;
endmodule

module max(input [7:0] a, b, c, output [7:0] out);
	wire [7:0] max_ab;
	assign max_ab = a > b ? a : b;
	assign out = c > max_ab ? c : max_ab;
endmodule

module cross2D(
	input [15:0] x1, y1, x2, y2,
	output [15:0] out
);
	assign out = x1*y2 - x2*y1;
endmodule