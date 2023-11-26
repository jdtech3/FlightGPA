
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

module mat_vec_mult(
	input wire clock, reset, start,
	input wire [31:0] m11, m12, m13,
	input wire [31:0] m21, m22, m23,
	input wire [31:0] m31, m32, m33,
	input wire [31:0] v1, v2, v3,
	output reg [31:0] o1, o2, o3,
	output wire done
);
	wire [7:0] count;
	reg [31:0] feed_v, feed_m;
	wire [31:0] pipe_res;
	wire count_done;
	reg current_state, next_state;
	localparam
		S_WAIT = 1'd0,
		S_COUNT = 1'd1;

	assign count_done = count == 28;
	assign done = current_state == S_WAIT;

	counter #(8) counter_inst(
		.clock(clock),
		.reset(reset || count_done),
		.enable(current_state == S_COUNT),
		.out(count)
	);

	always @(*) begin
		case(current_state)
			S_WAIT: next_state <= start ? S_COUNT : S_WAIT;
			S_COUNT: next_state <= count_done ? S_WAIT : S_COUNT;
		endcase
	end

	always @(posedge clock) begin

		if(reset) current_state <= S_WAIT;
		else current_state <= next_state;

		case(count)
			0: begin
				feed_v <= v1;
				feed_m <= m11;
			end
			1: begin
				feed_v <= v2;
				feed_m <= m12;
			end
			2: begin
				feed_v <= v3;
				feed_m <= m13;
			end
			3: begin
				feed_v <= v1;
				feed_m <= m21;
			end
			4: begin
				feed_v <= v2;
				feed_m <= m22;
			end
			5: begin
				feed_v <= v3;
				feed_m <= m23;
			end
			6: begin
				feed_v <= v1;
				feed_m <= m31;
			end
			7: begin
				feed_v <= v2;
				feed_m <= m32;
			end
			8: begin
				feed_v <= v3;
				feed_m <= m33;
			end
			22: o1 <= pipe_res;
			25: o2 <= pipe_res;
			28: o3 <= pipe_res;
		endcase
	end

	pipe_dot3D pipe_dot3D_inst(
		.aclr(reset),
		.clk_en(1'b1),
		.clock(clock),
		.v1(feed_m),
		.v2(feed_v),
		.result(pipe_res)
	);
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