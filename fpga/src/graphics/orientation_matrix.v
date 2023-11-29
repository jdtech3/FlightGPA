module orientation_matrix(
    input clock, reset, start,
    input [31:0] roll, pitch, yaw,
    input [31:0] x, y, z,

	output wire [31:0] o11, o12, o13, o14,
	output wire [31:0] o21, o22, o23, o24,
	output wire [31:0] o31, o32, o33, o34,
	output wire [31:0] o41, o42, o43, o44,

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

    reg [31:0] m11, m12, m13, m14;
    reg [31:0] m21, m22, m23, m24;
    reg [31:0] m31, m32, m33, m34;
    reg [31:0] m41, m42, m43, m44;

    reg [31:0] v11, v12, v13, v14;
    reg [31:0] v21, v22, v23, v24;
    reg [31:0] v31, v32, v33, v34;
    reg [31:0] v41, v42, v43, v44;

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
        .m11(m11), .m12(m12), .m13(m13), .m14(m14),
        .m21(m21), .m22(m22), .m23(m23), .m24(m24),
        .m31(m31), .m32(m32), .m33(m33), .m34(m34),
        .m41(m41), .m42(m42), .m43(m43), .m44(m44),

        .v11(v11), .v12(v12), .v13(v13), .v14(v14),
        .v21(v21), .v22(v22), .v23(v23), .v24(v24),
        .v31(v31), .v32(v32), .v33(v33), .v34(v34),
        .v41(v41), .v42(v42), .v43(v43), .v44(v44),

        .o11(o11), .o12(o12), .o13(o13), .o14(o14),
        .o21(o21), .o22(o22), .o23(o23), .o24(o24),
        .o31(o31), .o32(o32), .o33(o33), .o34(o34),
        .o41(o41), .o42(o42), .o43(o43), .o44(o44),

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
                m11 <= cos_pitch;     m12 <= 0;            m13 <= sin_pitch; m14 <= 0;
                m21 <= 0;             m22 <= 32'h3f800000; m23 <= 0;         m24 <= 0;
                m31 <= neg_sin_pitch; m32 <= 0;            m33 <= cos_pitch; m34 <= 0;
                m41 <= 0;             m42 <= 0;            m43 <= 0;         m44 <= 32'h3f800000;

                v11 <= 32'h3f800000; v12 <= 0;        v13 <= 0;            v14 <= 0;
                v21 <= 0;            v22 <= cos_roll; v23 <= neg_sin_roll; v24 <= 0;
                v31 <= 0;            v32 <= sin_roll; v33 <= cos_roll;     v34 <= 0;
                v41 <= 0;            v42 <= 0;        v43 <= 0;            v44 <= 32'h3f800000;
            end
            S_MULT_2_START: begin
                m11 <= cos_yaw; m12 <= neg_sin_yaw; m13 <= 0;            m14 <= x;
                m21 <= sin_yaw; m22 <= cos_yaw;     m23 <= 0;            m24 <= y;
                m31 <= 0;       m32 <= 0;           m33 <= 32'h3f800000; m34 <= z;
                m41 <= 0;       m42 <= 0;           m43 <= 0;            m44 <= 32'h3f800000;

                v11 <= o11; v12 <= o12; v13 <= o13; v14 <= o14;
                v21 <= o21; v22 <= o22; v23 <= o23; v24 <= o24;
                v31 <= o31; v32 <= o32; v33 <= o33; v34 <= o34;
                v41 <= o41; v42 <= o42; v43 <= o43; v44 <= o44;
            end
        endcase
    end

endmodule