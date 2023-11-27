
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

module mat_vec_mult3D(
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

module mat_vec_mult4D(
	input wire clock, reset, start, mult_vec,

	input wire [31:0] m11, m12, m13, m14,
	input wire [31:0] m21, m22, m23, m24,
	input wire [31:0] m31, m32, m33, m34,
	input wire [31:0] m41, m42, m43, m44,

	input wire [31:0] v11, v12, v13, v14,
	input wire [31:0] v21, v22, v23, v24,
	input wire [31:0] v31, v32, v33, v34,
	input wire [31:0] v41, v42, v43, v44,

	output reg [31:0] o11, o12, o13, o14,
	output reg [31:0] o21, o22, o23, o24,
	output reg [31:0] o31, o32, o33, o34,
	output reg [31:0] o41, o42, o43, o44,

	output wire done
);
	wire [6:0] count;
	reg [31:0] feed_v, feed_m;
	wire [31:0] pipe_res;
	wire count_done;
	reg current_state, next_state;
	localparam
		S_WAIT = 1'd0,
		S_COUNT = 1'd1;

	assign count_done = mult_vec ? (count == 36) : (count == 84);
	assign done = current_state == S_WAIT;

	counter #(7) counter_inst(
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
				feed_v <= v11;
				feed_m <= m11;
			end
			1: begin
				feed_v <= v21;
				feed_m <= m12;
			end
			2: begin
				feed_v <= v31;
				feed_m <= m13;
			end
			3: begin
				feed_v <= v41;
				feed_m <= m14;
			end
			4: begin
				feed_v <= v11;
				feed_m <= m21;
			end
			5: begin
				feed_v <= v21;
				feed_m <= m22;
			end
			6: begin
				feed_v <= v31;
				feed_m <= m23;
			end
			7: begin
				feed_v <= v41;
				feed_m <= m24;
			end
			8: begin
				feed_v <= v11;
				feed_m <= m31;
			end
			9: begin
				feed_v <= v21;
				feed_m <= m32;
			end
			10: begin
				feed_v <= v31;
				feed_m <= m33;
			end
			11: begin
				feed_v <= v41;
				feed_m <= m34;
			end
			12: begin
				feed_v <= v11;
				feed_m <= m41;
			end
			13: begin
				feed_v <= v21;
				feed_m <= m42;
			end
			14: begin
				feed_v <= v31;
				feed_m <= m43;
			end
			15: begin
				feed_v <= v41;
				feed_m <= m44;
			end
			16: begin
				feed_v <= v12;
				feed_m <= m11;
			end
			17: begin
				feed_v <= v22;
				feed_m <= m12;
			end
			18: begin
				feed_v <= v32;
				feed_m <= m13;
			end
			19: begin
				feed_v <= v42;
				feed_m <= m14;
			end
			20: begin
				feed_v <= v12;
				feed_m <= m21;
			end
			21: begin
				feed_v <= v22;
				feed_m <= m22;
			end
			22: begin
				feed_v <= v32;
				feed_m <= m23;
			end
			23: begin
				feed_v <= v42;
				feed_m <= m24;
			end
			24: begin
				o11 <= pipe_res;
				feed_v <= v12;
				feed_m <= m31;
			end
			25: begin
				feed_v <= v22;
				feed_m <= m32;
			end
			26: begin
				feed_v <= v32;
				feed_m <= m33;
			end
			27: begin
				feed_v <= v42;
				feed_m <= m34;
			end
			28: begin
				o21 <= pipe_res;
				feed_v <= v12;
				feed_m <= m41;
			end
			29: begin
				feed_v <= v22;
				feed_m <= m42;
			end
			30: begin
				feed_v <= v32;
				feed_m <= m43;
			end
			31: begin
				feed_v <= v42;
				feed_m <= m44;
			end
			32: begin
				o31 <= pipe_res;
				feed_v <= v13;
				feed_m <= m11;
			end
			33: begin
				feed_v <= v23;
				feed_m <= m12;
			end
			34: begin
				feed_v <= v33;
				feed_m <= m13;
			end
			35: begin
				feed_v <= v43;
				feed_m <= m14;
			end
			36: begin
				o41 <= pipe_res;
				feed_v <= v13;
				feed_m <= m21;
			end
			37: begin
				feed_v <= v23;
				feed_m <= m22;
			end
			38: begin
				feed_v <= v33;
				feed_m <= m23;
			end
			39: begin
				feed_v <= v43;
				feed_m <= m24;
			end
			40: begin
				o12 <= pipe_res;
				feed_v <= v13;
				feed_m <= m31;
			end
			41: begin
				feed_v <= v23;
				feed_m <= m32;
			end
			42: begin
				feed_v <= v33;
				feed_m <= m33;
			end
			43: begin
				feed_v <= v43;
				feed_m <= m34;
			end
			44: begin
				o22 <= pipe_res;
				feed_v <= v13;
				feed_m <= m41;
			end
			45: begin
				feed_v <= v23;
				feed_m <= m42;
			end
			46: begin
				feed_v <= v33;
				feed_m <= m43;
			end
			47: begin
				feed_v <= v43;
				feed_m <= m44;
			end
			48: begin
				o32 <= pipe_res;
				feed_v <= v14;
				feed_m <= m11;
			end
			49: begin
				feed_v <= v24;
				feed_m <= m12;
			end
			50: begin
				feed_v <= v34;
				feed_m <= m13;
			end
			51: begin
				feed_v <= v44;
				feed_m <= m14;
			end
			52: begin
				o42 <= pipe_res;
				feed_v <= v14;
				feed_m <= m21;
			end
			53: begin
				feed_v <= v24;
				feed_m <= m22;
			end
			54: begin
				feed_v <= v34;
				feed_m <= m23;
			end
			55: begin
				feed_v <= v44;
				feed_m <= m24;
			end
			56: begin
				o13 <= pipe_res;
				feed_v <= v14;
				feed_m <= m31;
			end
			57: begin
				feed_v <= v24;
				feed_m <= m32;
			end
			58: begin
				feed_v <= v34;
				feed_m <= m33;
			end
			59: begin
				feed_v <= v44;
				feed_m <= m34;
			end
			60: begin
				o23 <= pipe_res;
				feed_v <= v14;
				feed_m <= m41;
			end
			61: begin
				feed_v <= v24;
				feed_m <= m42;
			end
			62: begin
				feed_v <= v34;
				feed_m <= m43;
			end
			63: begin
				feed_v <= v44;
				feed_m <= m44;
			end
			64: o33 <= pipe_res;
			68: o43 <= pipe_res;
			72: o14 <= pipe_res;
			76: o24 <= pipe_res;
			80: o34 <= pipe_res;
			84: o44 <= pipe_res;
		endcase
	end

	pipe_dot4D pipe_dot4D_inst(
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

module pipe_dot4D(aclr, clk_en, clock, v1, v2, result);
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
	pipe_add4 pipe_add4_inst(
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