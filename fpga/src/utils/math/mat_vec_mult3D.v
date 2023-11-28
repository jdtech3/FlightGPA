
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
