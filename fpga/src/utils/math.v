
module min(a, b, c, out);
	parameter WIDTH=8;
	input wire [WIDTH-1:0] a, b, c;
	output wire [WIDTH-1:0] out;
	wire [WIDTH-1:0] min_ab;
	assign min_ab = a < b ? a : b;
	assign out = c < min_ab ? c : min_ab;
endmodule

module max(a, b, c, out);
	parameter WIDTH=8;
	input wire [WIDTH-1:0] a, b, c;
	output wire [WIDTH-1:0] out;
	wire [WIDTH-1:0] max_ab;
	assign max_ab = a > b ? a : b;
	assign out = c > max_ab ? c : max_ab;
endmodule

module cross2D(x1, y1, x2, y2, out);
	parameter WIDTH=16;
	input wire [WIDTH-1:0] x1, y1, x2, y2;
	output wire [WIDTH-1:0] out;
	assign out = x1*y2 - x2*y1;
endmodule