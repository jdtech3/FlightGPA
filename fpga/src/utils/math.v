
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

module pipe_dot3D(aclr, clk_en, clock, v1, v2, result);
	input aclr, clk_en, clock;
	input wire [31:0] v1, v2;
	output wire [31:0] result;
	wire [31:0] mult_res;
	float_mult float_mult_inst(
		.aclr(aclr),
		.clk_en(clk_en),
		.clock(clock),
		.dataa(v1),
		.datab(v2),
		.result(mult_res));
	pipe_add3 pipe_add3_inst(
		.aclr(aclr),
		.clk_en(clk_en),
		.clock(clock),
		.in(mult_res),
		.result(result));
endmodule

module pipe_add3(aclr, clk_en, clock, in, result);
	input aclr, clk_en, clock;
	input wire [31:0] in;
	output wire [31:0] result;
	reg [31:0] reg1, reg2, reg3, dreg1,dreg2,dreg3,dreg4,dreg5,dreg6,dreg7;
	wire [31:0] result_1;
	always @(posedge (clock & clk_en)) begin
		reg1 <= in;
		reg2 <= reg1;
		reg3 <= reg2;
		dreg1 <= reg3;
		dreg2 <= dreg1;
		dreg3 <= dreg2;
		dreg4 <= dreg3;
		dreg5 <= dreg4;
		dreg6 <= dreg5;
		dreg7 <= dreg6;
	end
	float_add float_add_inst_1(
		.aclr(aclr),
		.clk_en(clk_en),
		.clock(clock),
		.dataa(reg2),
		.datab(reg3),
		.result(result_1)
	);
	float_add float_add_inst_2(
		.aclr(aclr),
		.clk_en(clk_en),
		.clock(clock),
		.dataa(result_1),
		.datab(dreg7),
		.result(result)
	);
endmodule