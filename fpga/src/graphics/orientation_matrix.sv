module orientation_matrix(
    input clock, reset, start,
    input [31:0] roll, pitch, yaw,
    input [31:0] x, y, z,
    output wire [31:0] o [3:0][3:0],
    output wire done
);

    reg [31:0] angle;
    wire [31:0] cos_out, sin_out;

    reg [31:0] cos_roll, sin_roll;
    reg [31:0] cos_pitch, sin_pitch;
    reg [31:0] cos_yaw, sin_yaw;

    reg [31:0] neg_sin_roll;
    reg [31:0] neg_sin_pitch;
    reg [31:0] neg_sin_yaw;

    reg [31:0] m [3:0][3:0];
    reg [31:0] v [3:0][3:0];

    wire [5:0] count;
    wire mat_mult_done;
    wire count_done;
    reg [2:0] current_state, next_state;

    localparam
		S_WAIT          = 3'd0,
        S_CALC_TRIG     = 3'd1,
        S_MULT_1_START  = 3'd2,
		S_MULT_1        = 3'd3,
		S_MULT_2_START  = 3'd4,
        S_MULT_2        = 3'd5;

    assign count_done = count == 39;
    assign done = current_state == S_WAIT;

    assign neg_sin_roll = {~sin_roll[31], sin_roll[30:0]};
    assign neg_sin_pitch = {~sin_pitch[31], sin_pitch[30:0]};
    assign neg_sin_yaw = {~sin_yaw[31], sin_yaw[30:0]};

    float_cos float_cos_inst(
        .aclr(reset),
        .clk_en(1'b1),
        .clock(clock),
        .data(angle),
        .result(cos_out)
    );

    float_sin float_sin_inst(
        .aclr(reset),
        .clk_en(1'b1),
        .clock(clock),
        .data(angle),
        .result(sin_out)
    );

    mat_mult4D matrix_mult_inst(
        .clock(clock),
        .reset(reset),
        .start(current_state == S_MULT_1_START || current_state == S_MULT_2_START),
        .mult_vec(1'b0),
        .m(m),
        .v(v),
        .o(o),
        .done(mat_mult_done)
    );
    
    counter #(6) counter_inst(
		.clock(clock),
		.reset(reset || count_done),
		.enable(current_state == S_CALC_TRIG),
		.out(count)
	);
    
    always @(*) begin
		case(current_state)
			S_WAIT: next_state <= start ? S_CALC_TRIG : S_WAIT;
			S_CALC_TRIG: next_state <= count_done ? S_MULT_1_START : S_CALC_TRIG;
            S_MULT_1_START: next_state <= S_MULT_1;
			S_MULT_1: next_state <= mat_mult_done ? S_MULT_2_START : S_MULT_1;
            S_MULT_2_START: next_state <= S_MULT_2;
            S_MULT_2: next_state <= mat_mult_done ? S_WAIT: S_MULT_2;
		endcase
	end

    always @(posedge clock) begin

		if(reset) current_state <= S_WAIT;
		else current_state <= next_state;
        case(count)
            0: angle <= roll;
            1: angle <= pitch;
            2: angle <= yaw;
            36: cos_roll <= cos_out;
            37: begin
                sin_roll <= sin_out;
                cos_pitch <= cos_out;
            end
            38: begin
                sin_pitch <= sin_out;
                cos_yaw <= cos_out;
            end
            39: sin_yaw <= sin_out;
        endcase
        case(current_state)
            S_MULT_1_START: begin
                m[0][0] <= cos_pitch;     m[0][1] <= 0;            m[0][2] <= sin_pitch; m[0][3] <= 0;
                m[1][0] <= 0;             m[1][1] <= 32'h3f800000; m[1][2] <= 0;         m[1][3] <= 0;
                m[2][0] <= neg_sin_pitch; m[2][1] <= 0;            m[2][2] <= cos_pitch; m[2][3] <= 0;
                m[3][0] <= 0;             m[3][1] <= 0;            m[3][2] <= 0;         m[3][3] <= 32'h3f800000;

                v[0][0] <= 32'h3f800000; v[0][1] <= 0;        v[0][2] <= 0;            v[0][3] <= 0;
                v[1][0] <= 0;            v[1][1] <= cos_roll; v[1][2] <= neg_sin_roll; v[1][3] <= 0;
                v[2][0] <= 0;            v[2][1] <= sin_roll; v[2][2] <= cos_roll;     v[2][3] <= 0;
                v[3][0] <= 0;            v[3][1] <= 0;        v[3][2] <= 0;            v[3][3] <= 32'h3f800000;
            end
            S_MULT_2_START: begin
                m[0][0] <= cos_yaw; m[0][1] <= neg_sin_yaw; m[0][2] <= 0;            m[0][3] <= x;
                m[1][0] <= sin_yaw; m[1][1] <= cos_yaw;     m[1][2] <= 0;            m[1][3] <= y;
                m[2][0] <= 0;       m[2][1] <= 0;           m[2][2] <= 32'h3f800000; m[2][3] <= z;
                m[3][0] <= 0;       m[3][1] <= 0;           m[3][2] <= 0;            m[3][3] <= 32'h3f800000;

                v <= o;
            end
        endcase
    end

endmodule