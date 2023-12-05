module mvp_matrix(
    input clock, reset, start, update_mvp,
    input [31:0] roll, pitch, yaw,
    input [31:0] x, y, z,
    input [31:0] speed,
    output reg [31:0] vx, vy, vz,
    output wire [31:0] o [3:0][3:0],
    output reg [31:0] ox, oy, oz,
    output wire done
);

    reg [31:0] angle;
    wire [31:0] cos_out, sin_out;

    reg [31:0] cos_roll, sin_roll;
    reg [31:0] cos_pitch, sin_pitch;
    reg [31:0] cos_yaw, sin_yaw;

    reg [31:0] div_in;
    wire [31:0] div_out, int_out;

    reg [31:0] neg_sin_roll;
    reg [31:0] neg_sin_pitch;
    reg [31:0] neg_sin_yaw;

    reg [31:0] m [3:0][3:0];
    reg [31:0] v [3:0][3:0];

    wire [5:0] count;
    reg mult_vec;
    wire mat_mult_done;
    wire count_done;
    reg [7:0] current_state, next_state;

    reg [31:0] float_to_int_in;

    localparam
		S_WAIT              = 8'd0,
        S_CALC_TRIG         = 8'd1,
        S_MULT_ROTZX_START  = 8'd2,
		S_MULT_ROTZX        = 8'd3,
		S_MULT_ROTZXY_START = 8'd4,
        S_MULT_ROTZXY       = 8'd5,
        S_MULT_PROJ_START   = 8'd6,
        S_MULT_PROJ         = 8'd7,
        S_TRANSFORM_START   = 8'd8,
        S_TRANSFORM         = 8'd9,
        S_DIV_X             = 8'd10,
        S_DIV_Y             = 8'd11,
        S_DIV_Z             = 8'd12,
        S_WAIT_DIV          = 8'd13,
        S_SAMP_X            = 8'd14,
        S_SAMP_Y            = 8'd15,
        S_SAMP_Z            = 8'd16,
        S_FORWARD_START     = 8'd17,
        S_FORWARD           = 8'd18,
        S_FORWARD_TO_INT    = 8'd19,
        S_MULT_TRANS_START  = 8'd20,
        S_MULT_TRANS        = 8'd21;

    assign count_done =
        (current_state == S_CALC_TRIG && count == 39) ||
        (current_state == S_WAIT_DIV && count == 9) ||
        (current_state == S_FORWARD_TO_INT && count == 8);
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

    float_divide float_divide_inst(
        .aclr(reset),
        .clk_en(1'b1),
        .clock(clock),
        .dataa(div_in),
        .datab(o[3][0]),
        .result(div_out)
    );

    float_to_int float_to_int_inst(
        .aclr(reset),
        .clk_en(1'b1),
        .clock(clock),
        .dataa(current_state == S_MULT_PROJ_START || current_state == S_FORWARD_TO_INT ? float_to_int_in : div_out),
        .result(int_out)
    );

    mat_mult4D matrix_mult_inst(
        .clock(clock),
        .reset(reset),
        .start(
            current_state == S_MULT_ROTZX_START ||
            current_state == S_MULT_ROTZXY_START ||
            current_state == S_MULT_PROJ_START ||
            current_state == S_FORWARD_START ||
            current_state == S_MULT_TRANS_START ||
            current_state == S_TRANSFORM_START),
        .mult_vec(mult_vec),
        .m(m),
        .v(v),
        .o(o),
        .done(mat_mult_done)
    );
    
    counter #(6) counter_inst(
		.clock(clock),
		.reset(reset || count_done),
		.enable(current_state == S_CALC_TRIG || current_state == S_WAIT_DIV || current_state == S_FORWARD_TO_INT),
		.out(count)
	);
    
    always @(*) begin
		case(current_state)
			S_WAIT:              next_state <= start ? (update_mvp ? S_CALC_TRIG : S_TRANSFORM_START) : S_WAIT;
			S_CALC_TRIG:         next_state <= count_done ? S_MULT_ROTZX_START : S_CALC_TRIG;
            S_MULT_ROTZX_START:  next_state <= S_MULT_ROTZX;
			S_MULT_ROTZX:        next_state <= mat_mult_done ? S_MULT_ROTZXY_START : S_MULT_ROTZX;
            S_MULT_ROTZXY_START: next_state <= S_MULT_ROTZXY;
            S_MULT_ROTZXY:       next_state <= mat_mult_done ? S_FORWARD_START : S_MULT_ROTZXY;
            S_FORWARD_START:     next_state <= S_FORWARD;
            S_FORWARD:           next_state <= mat_mult_done ? S_MULT_TRANS_START : S_FORWARD; 
            S_MULT_TRANS_START:  next_state <= S_FORWARD_TO_INT;
            S_FORWARD_TO_INT:    next_state <= count_done ? S_MULT_TRANS : S_FORWARD_TO_INT;
            S_MULT_TRANS:        next_state <= mat_mult_done ? S_MULT_PROJ_START : S_MULT_TRANS;
            S_MULT_PROJ_START:   next_state <= S_MULT_PROJ;
            S_MULT_PROJ:         next_state <= mat_mult_done ? S_WAIT : S_MULT_PROJ;
            S_TRANSFORM_START:   next_state <= S_TRANSFORM;
            S_TRANSFORM:         next_state <= mat_mult_done ? S_DIV_X: S_TRANSFORM;
            S_DIV_X:             next_state <= S_DIV_Y;
            S_DIV_Y:             next_state <= S_DIV_Z;
            S_DIV_Z:             next_state <= S_WAIT_DIV;
            S_WAIT_DIV:          next_state <= count_done ? S_SAMP_X : S_WAIT_DIV;
            S_SAMP_X:            next_state <= S_SAMP_Y;
            S_SAMP_Y:            next_state <= S_SAMP_Z;
            S_SAMP_Z:            next_state <= S_WAIT;
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
            S_CALC_TRIG: mult_vec <= 1'b0;
            S_MULT_ROTZX_START: begin
                m[0][0] <= 32'h3f800000;  m[0][1] <= 0;         m[0][2] <= 0;             m[0][3] <= 0;
                m[1][0] <= 0;             m[1][1] <= cos_pitch; m[1][2] <= neg_sin_pitch; m[1][3] <= 0;
                m[2][0] <= 0;             m[2][1] <= sin_pitch; m[2][2] <= cos_pitch;     m[2][3] <= 0;
                m[3][0] <= 0;             m[3][1] <= 0;         m[3][2] <= 0;             m[3][3] <= 32'h3f800000;

                v[0][0] <= cos_roll; v[0][1] <= neg_sin_roll; v[0][2] <= 0;            v[0][3] <= 0;
                v[1][0] <= sin_roll; v[1][1] <= cos_roll;     v[1][2] <= 0;            v[1][3] <= 0;
                v[2][0] <= 0;        v[2][1] <= 0;            v[2][2] <= 32'h3f800000; v[2][3] <= 0;
                v[3][0] <= 0;        v[3][1] <= 0;            v[3][2] <= 0;            v[3][3] <= 32'h3f800000;
            end
            S_MULT_ROTZXY_START: begin
                m[0][0] <= cos_yaw; m[0][1] <= 0;            m[0][2] <= neg_sin_yaw; m[0][3] <= 0;
                m[1][0] <= 0;       m[1][1] <= 32'h3f800000; m[1][2] <= 0;           m[1][3] <= 0;
                m[2][0] <= sin_yaw; m[2][1] <= 0;            m[2][2] <= cos_yaw;     m[2][3] <= 0;
                m[3][0] <= 0;       m[3][1] <= 0;            m[3][2] <= 0;           m[3][3] <= 32'h3f800000;

                v <= o;
            end
            S_FORWARD_START: begin
                mult_vec <= 1'b1;
                m <= o;
                v[0][0] <= 0;
                v[1][0] <= 0;
                v[2][0] <= {~speed[31], speed[30:0]};
                v[3][0] <= 32'h3f800000;
            end
            S_MULT_TRANS_START: begin
                mult_vec <= 1'b0;
                m[0][0] <= 32'h3f800000; m[0][1] <= 0;            m[0][2] <= 0;            m[0][3] <= x;
                m[1][0] <= 0;            m[1][1] <= 32'h3f800000; m[1][2] <= 0;            m[1][3] <= y;
                m[2][0] <= 0;            m[2][1] <= 0;            m[2][2] <= 32'h3f800000; m[2][3] <= z;
                m[3][0] <= 0;            m[3][1] <= 0;            m[3][2] <= 0;            m[3][3] <= 32'h3f800000;
                v <= m;
                float_to_int_in <= o[0][0];
            end
            S_FORWARD_TO_INT: begin
                case(count)
                    0: float_to_int_in <= o[1][0];
                    1: float_to_int_in <= o[2][0];
                    6: vx <= int_out;
                    7: vy <= int_out;
                    8: vz <= int_out;
                endcase
            end
            S_MULT_PROJ_START: begin
                m[0][0] <= 32'h43ab60b4; m[0][1] <= 0;            m[0][2] <= 0;            m[0][3] <= 0;
                m[1][0] <= 0;            m[1][1] <= 32'hc3ab60b5; m[1][2] <= 0;            m[1][3] <= 0;
                m[2][0] <= 0;            m[2][1] <= 0;            m[2][2] <= 32'hc2c86681; m[2][3] <= 32'hc3483340;
                m[3][0] <= 0;            m[3][1] <= 0;            m[3][2] <= 32'hbf800000; m[3][3] <= 0;

                v <= o;
            end
            S_MULT_PROJ: if(mat_mult_done) begin
                m <= o;
                mult_vec <= 1'b1;
            end
            S_TRANSFORM_START: begin
                v[0][0] <= x;
                v[1][0] <= y;
                v[2][0] <= z;
                v[3][0] <= 32'h3f800000;
            end
            S_DIV_X: div_in <= o[0][0];
            S_DIV_Y: div_in <= o[1][0];
            S_DIV_Z: div_in <= o[2][0];
            S_SAMP_X: ox <= int_out + 32'd320;
            S_SAMP_Y: oy <= int_out + 32'd240;
            S_SAMP_Z: oz <= int_out;
        endcase
    end

endmodule