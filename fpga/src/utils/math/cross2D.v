
module cross2D(x1, y1, x2, y2, out);
	parameter WIDTH=16;
	input wire [WIDTH-1:0] x1, y1, x2, y2;
	output wire [WIDTH-1:0] out;
	assign out = x1*y2 - x2*y1;
endmodule