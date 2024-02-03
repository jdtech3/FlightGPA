
module pipe_add3(aclr, clk_en, clock, in, result);
	input aclr, clk_en, clock;
	input wire [31:0] in;
	output wire [31:0] result;
	reg [31:0] reg1, reg2, reg3, dreg1,dreg2,dreg3,dreg4;
	wire [31:0] result_1;
	always @(posedge (clock & clk_en)) begin
		reg1 <= in;
		reg2 <= reg1;
		reg3 <= reg2;
		dreg1 <= reg3;
		dreg2 <= dreg1;
		dreg3 <= dreg2;
		dreg4 <= dreg3;
	end
	float_add float_add_inst_1(
		.aclr(aclr),
		.clk_en(clk_en),
		.clock(clock),
		.dataa(reg1),
		.datab(reg2),
		.result(result_1)
	);
	float_add float_add_inst_2(
		.aclr(aclr),
		.clk_en(clk_en),
		.clock(clock),
		.dataa(result_1),
		.datab(dreg4),
		.result(result)
	);
endmodule
