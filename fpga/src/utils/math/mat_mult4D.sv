
module mat_mult4D(
	input wire clock, reset, start, mult_vec,

	input wire [31:0] m [3:0][3:0],
	input wire [31:0] v [3:0][3:0],
	output reg [31:0] o [3:0][3:0],

	output wire done
);
	wire [6:0] count;
	reg [6:0] c;
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

		feed_m <= m[count[3:2]][count[1:0]];
		feed_v <= v[count[1:0]][mult_vec ? 0 : count[5:4]];
		
		if(count >= 24) begin
			c = count-24;
			if(c % 4 == 0) begin
				o[c[3:2]][mult_vec ? 0 : c[5:4]] <= pipe_res;
			end
		end
		
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
