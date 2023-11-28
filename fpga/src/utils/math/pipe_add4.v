module pipe_add4(aclr, clk_en, clock, in, result);
	input aclr, clk_en, clock;
	input wire [31:0] in;
	output wire [31:0] result;
	reg [31:0] reg1,reg2,dreg1,dreg2;
	wire [31:0] result_1;
	always @(posedge (clock & clk_en)) begin
		reg1 <= in;
		reg2 <= reg1;
		dreg1 <= result_1;
		dreg2 <= dreg1;
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
		.datab(dreg2),
		.result(result)
	);
endmodule