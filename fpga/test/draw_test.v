`timescale 1ps/1ps

module draw_test(
	input CLOCK_50,
	input [1:0] KEY,
	output VGA_CLK,   		//	VGA Clock
	output VGA_HS,			//	VGA H_SYNC
	output VGA_VS,			//	VGA V_SYNC
	output VGA_BLANK_N,		//	VGA BLANK
	output VGA_SYNC_N,		//	VGA SYNC
	output [7:0] VGA_R, 	//	VGA Red[9:0]
	output [7:0] VGA_G,		//	VGA Green[9:0]
	output [7:0] VGA_B  	//	VGA Blue[9:0]
);

    wire clock, reset;
    wire pulse_1s;

    assign clock = CLOCK_50;
    assign reset = ~KEY[0];

	refresh_draw_triangle rdt(
		.clock(clock), .reset(reset),
		.draw_en(pulse_1s),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);

    pulse #(
        .DURATION(100),
        .CLOCK_FREQUENCY(50000000))
    generate_pulse_1s(
        clock,reset,pulse_1s
    );

    // always @(posedge pulse_1s or posedge reset) begin
    //     if(reset) colour<=0;
    //     else colour<=colour+1;
    // end
	
endmodule

module refresh_draw_triangle(
	clock, reset,
	draw_en,
	VGA_CLK,
	VGA_HS,
	VGA_VS,
	VGA_BLANK_N,
	VGA_SYNC_N,
	VGA_R,
	VGA_G,
	VGA_B
);

	input wire clock, reset;
	input wire draw_en;
	output VGA_CLK;   		//	VGA Clock
	output VGA_HS;			//	VGA H_SYNC
	output VGA_VS;			//	VGA V_SYNC
	output VGA_BLANK_N;		//	VGA BLANK
	output VGA_SYNC_N;		//	VGA SYNC
	output [7:0] VGA_R; 	//	VGA Red[9:0]
	output [7:0] VGA_G;		//	VGA Green[9:0]
	output [7:0] VGA_B;  	//	VGA Blue[9:0]

	reg [2:0] current_state, next_state;
	wire drawer_done;
	reg drawer_en;
	reg [3:0] opcode;
	reg [31:0] ax, ay, bx, by, cx, cy;
	reg [2:0]  colour;

	wire screen_start;
	wire [2:0] new_screen_colour;
	wire [31:0] screen_x_min, screen_y_min;
	wire [31:0] screen_x_range, screen_y_range;
	wire [31:0] screen_x, screen_y;
	wire [2:0] old_screen_colour;
	wire screen_done;

	localparam
		S_WAIT = 0,
		S_START_CLEAR = 1,
		S_WAIT_CLEAR = 2,
		S_START_TRIANGLE = 3,
		S_WAIT_TRIANGLE = 4;

	always @(*) begin
		case(current_state)
			S_WAIT: next_state = draw_en ? S_START_CLEAR : S_WAIT;
			S_START_CLEAR: next_state = S_WAIT_CLEAR;
			S_WAIT_CLEAR: next_state = drawer_done ? S_START_TRIANGLE : S_WAIT_CLEAR;
			S_START_TRIANGLE: next_state = S_WAIT_TRIANGLE;
			S_WAIT_TRIANGLE: next_state = drawer_done ? S_WAIT : S_WAIT_TRIANGLE;
		endcase
	end

	always @(posedge clock) begin
		if(reset) current_state = 0;
		else current_state = next_state;
	end

	always @(posedge clock) begin
		drawer_en = 0;
		if(reset) begin
			ax = 32'd160; ay = 32'd10;
			bx = 32'd100; by = 32'd220;
			cx = 32'd220; cy = 32'd200;
			colour = 0;
		end
		else begin
			case(current_state)
				S_START_CLEAR: begin
					opcode = 0;
					colour = 0;
					drawer_en = 1;
				end
				S_START_TRIANGLE: begin
					ax = ax == 319 ? 0 : ax+1;
					bx = bx == 319 ? 0 : bx+1;
					cx = cx == 319 ? 0 : cx+1;
					colour = 3'b111;
					opcode = 1;
					drawer_en = 1;
				end
			endcase
		end
	end

	draw #(32,3,320,240) draw_operation(
		.clock(clock),
		.reset(reset),
		.opcode(opcode),
		.ax(ax), .ay(ay),
		.bx(bx), .by(by),
		.cx(cx), .cy(cy),
		.colour(colour),
		.draw_en(drawer_en),
		.draw_done(drawer_done),

		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min), .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range), .screen_y_range(screen_y_range),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done)
	);

	screen_writer #(32,3) sw(
		.clock(clock),
		.reset(reset),
		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min), .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range), .screen_y_range(screen_y_range),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);

endmodule