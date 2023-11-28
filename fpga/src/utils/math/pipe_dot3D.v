
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

