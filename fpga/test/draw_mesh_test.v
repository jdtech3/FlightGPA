
module draw_mesh_test(
    input wire CLOCK_50,
    input wire [1:0] KEY,
    output VGA_CLK,   		//	VGA Clock
	output VGA_HS,			//	VGA H_SYNC
	output VGA_VS,			//	VGA V_SYNC
	output VGA_BLANK_N,		//	VGA BLANK
	output VGA_SYNC_N,		//	VGA SYNC
	output [7:0] VGA_R, 	//	VGA Red[9:0]
	output [7:0] VGA_G,		//	VGA Green[9:0]
	output [7:0] VGA_B  	//	VGA Blue[9:0]
);

    wire clock, reset, start;

    wire [31:0] mesh_addr;
    wire [31:0] mesh_data;

    wire mvp_pipe_start;
    wire mvp_pipe_update_mvp;
    wire mvp_pipe_done;
    wire [31:0] mvp_pipe_res_addr;
    wire [31:0] mvp_pipe_res_data;

    wire draw_tri_pipe_start;
    wire draw_tri_pipe_done;

    wire [31:0] ax,ay,az,bx,by,bz,cx,cy,cz;
    wire [2:0] colour;
    wire draw_en, draw_done;

    wire screen_start;
    wire [2:0] new_screen_colour;
    wire [31:0] screen_x_min, screen_y_min;
    wire [31:0] screen_x_range, screen_y_range;
    wire [31:0] screen_x, screen_y;
    wire [2:0] old_screen_colour;
    wire screen_done;

    assign clock = CLOCK_50;
    assign reset = ~KEY[0];
    assign start = ~KEY[1];

    airplane_mesh am(
        .address(mesh_addr),
        .clock(clock),
        .q(mesh_data)
    );

    mvp_pipe mp(
        .clock(clock),
        .reset(reset),
        .start(mvp_pipe_start),
        .update_mvp(mvp_pipe_update_mvp),
        .roll(32'd0),
        .pitch(32'd0),
        .yaw(32'd0),
        .x(32'd0),
        .y(32'd0),
        .z(32'd0),
        .count(32'd5),
        .done(mvp_pipe_done),
        .mesh_addr(mesh_addr),
        .mesh_data(mesh_data),
        .result_addr(mvp_pipe_res_addr),
        .result_data(mvp_pipe_res_data));

    draw_triangle_pipe #(
        .WIDTH(32),
        .COLOUR_WIDTH(3))
    dtp(
        .clock(clock),
        .reset(reset),
        .start(draw_tri_pipe_start),
        .strip(1'b1),
        .count(32'd3),
        .done(draw_tri_pipe_done),
        .mem_read_addr(mvp_pipe_res_addr),
        .mem_read_data(mvp_pipe_res_data),
        .mem_col_addr(),
        .mem_col_data(3'b111),
        .opcode(),
        .ax(ax), .ay(ay), .az(az),
        .bx(bx), .by(by), .bz(bz),
        .cx(cx), .cy(cy), .cz(cz),
        .colour(colour),
        .draw_en(draw_en),
        .draw_done(draw_done));

    pipe_mesh_controller pmc(
        .clock(clock),
        .reset(reset),
        .start(start),
        .done(),
        .mvp_pipe_start(mvp_pipe_start),
        .mvp_pipe_update_mvp(mvp_pipe_update_mvp),
        .mvp_pipe_done(mvp_pipe_done),
        .draw_tri_pipe_start(draw_tri_pipe_start),
        .draw_tri_pipe_done(draw_tri_pipe_done));

    draw_triangle #(
        .WIDTH(32),
        .COLOUR_WIDTH(3))
    dt(
        .clock(clock),
        .reset(reset),
        .ax(ax), .ay(ay),
        .bx(bx), .by(by),
        .cx(cx), .cy(cy),
        .colour(colour),
        .draw_en(draw_en),
        .draw_done(draw_done),

        .screen_start(screen_start),
        .new_screen_colour(new_screen_colour),
        .screen_x_min(screen_x_min),
        .screen_y_min(screen_y_min),
        .screen_x_range(screen_x_range),
        .screen_y_range(screen_y_range),
        .screen_x(screen_x),
        .screen_y(screen_y),
        .old_screen_colour(old_screen_colour),
        .screen_done(screen_done));
    
    screen_writer #(
        .WIDTH(32),
        .COLOUR_WIDTH(3))
    sw(
		.clock(clock),
		.reset(reset),
		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min),
        .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range),
        .screen_y_range(screen_y_range),
		.screen_x(screen_x),
        .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B));

endmodule