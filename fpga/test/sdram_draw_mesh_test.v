`timescale 1ps/1ps


// module sdram_draw_mesh_test(
// 	// Clock pins
//     input           CLOCK_50,
//     input           CLOCK2_50,

//     // SDRAM
//     output  [12:0]  DRAM_ADDR,
//     output  [1:0]   DRAM_BA,
//     output          DRAM_CAS_N,
//     output          DRAM_CKE,
//     output          DRAM_CLK,
//     output          DRAM_CS_N,
//     inout   [15:0]  DRAM_DQ,
//     output          DRAM_LDQM,
//     output          DRAM_RAS_N,
//     output          DRAM_UDQM,
//     output          DRAM_WE_N,

//     // VGA
//     output  [7:0]   VGA_B,
//     output          VGA_BLANK_N,
//     output          VGA_CLK,
//     output  [7:0]   VGA_G,
//     output          VGA_HS,
//     output  [7:0]   VGA_R,
//     output          VGA_SYNC_N,
//     output          VGA_VS,
    
//     // I/O
//     input   [3:0]   KEY,
//     input   [9:0]   SW,
//     output  [9:0]   LEDR,
// 	output 	[6:0]	HEX0,
// 	output 	[6:0]	HEX1,
// 	output 	[6:0]	HEX2,
// 	output 	[6:0]	HEX3,
// 	output 	[6:0]	HEX4,
// 	output 	[6:0]	HEX5
// );

// 	wire sys_clk;

//     wire reset;
//     wire pulse_1s;

//     wire draw_mesh_start, draw_mesh_done;

//     wire screen_start;
//     wire [31:0] new_screen_colour;
//     wire [31:0] screen_x_min, screen_y_min;
//     wire [31:0] screen_x_range, screen_y_range;
//     wire [31:0] screen_x, screen_y;
//     wire [31:0] old_screen_colour;
//     wire screen_done;

//     assign reset = ~KEY[0];

//     pulse #(
//         .DURATION(40),
//         .CLOCK_FREQUENCY(166000000))
//     generate_pulse_1s(
//         sys_clk,reset,pulse_1s
//     );

// 	draw_mesh_test dmt(
//         .clock              (sys_clk),
//         .reset              (reset),
//         .start              (draw_mesh_start),
//         .done               (draw_mesh_done),
//         .screen_start       (screen_start),
//         .screen_done        (screen_done),
//         .screen_x_min       (screen_x_min),
//         .screen_x_range     (screen_x_range),
//         .screen_y_min       (screen_y_min),
//         .screen_y_range     (screen_y_range),
//         .screen_x           (screen_x),
//         .screen_y           (screen_y),
//         .old_screen_colour  (old_screen_colour),
//         .new_screen_colour  (new_screen_colour)
//     );

//     // --- Instantiating the system ---
    
//     FlightGPA_System system (
    
//         // Global signals
//         .sys_ref_clk_clk        (CLOCK_50),
//         .sys_ref_reset_reset    (reset),
//         .vga_ref_clk_clk        (CLOCK2_50),
//         .vga_ref_reset_reset    (reset),

// 		.sys_clk_bridge_out_clk_clk (sys_clk),
         
//         // SDRAM signals
//         .sdram_clk_clk          (DRAM_CLK),
//         .sdram_addr             (DRAM_ADDR),
//         .sdram_ba               (DRAM_BA),
//         .sdram_cas_n            (DRAM_CAS_N),
//         .sdram_cke              (DRAM_CKE),
//         .sdram_cs_n             (DRAM_CS_N),
//         .sdram_dq               (DRAM_DQ),
//         .sdram_dqm              ({DRAM_UDQM, DRAM_LDQM}),
//         .sdram_ras_n            (DRAM_RAS_N),
//         .sdram_we_n             (DRAM_WE_N),
        
//         // VGA signals
//         .vga_CLK                (VGA_CLK),
//         .vga_BLANK              (VGA_BLANK_N),
//         .vga_SYNC               (VGA_SYNC_N),
//         .vga_HS                 (VGA_HS),
//         .vga_VS                 (VGA_VS),
//         .vga_R                  (VGA_R),
//         .vga_G                  (VGA_G),
//         .vga_B                  (VGA_B),

// 		// SDRAM interface signals
// 		.sdram_interface_ext_interface_start			(screen_start),
// 		.sdram_interface_ext_interface_done    			(screen_done),
// 		.sdram_interface_ext_interface_x_start  		(screen_x_min),
// 		.sdram_interface_ext_interface_x_length 		(screen_x_range),
// 		.sdram_interface_ext_interface_y_start   		(screen_y_min),
// 		.sdram_interface_ext_interface_y_length  		(screen_y_range),
// 		.sdram_interface_ext_interface_current_x 		(screen_x),
// 		.sdram_interface_ext_interface_current_y 		(screen_y),
// 		.sdram_interface_ext_interface_old_color 		(old_screen_colour),
// 		.sdram_interface_ext_interface_new_color 		(new_screen_colour),
// 		.sdram_interface_ext_interface_base_addr_offset	(32'h00000000),
// 		.sdram_interface_ext_interface_clear			(1'b0),
// 		.sdram_interface_ext_interface_stall			(VGA_BLANK_N)

// 		// Pixel buffer controller signals
//         // .pixel_buffer_controller_ext_interface_swap_buffer(swap_buffer)
// 	);


// 	hex_decoder hex5 ( .c(colour[23:20]), .display(HEX5) );
// 	hex_decoder hex4 ( .c(colour[19:16]), .display(HEX4) );
// 	hex_decoder hex3 ( .c(colour[15:12]), .display(HEX3) );
// 	hex_decoder hex2 ( .c(colour[11:8]), .display(HEX2) );
// 	hex_decoder hex1 ( .c(colour[7:4]), .display(HEX1) );
// 	hex_decoder hex0 ( .c(colour[3:0]), .display(HEX0) );

// endmodule


module sdram_draw_mesh_test(
	// Clock pins
    input           CLOCK_50,
    input           CLOCK2_50,

    // SDRAM
    output  [12:0]  DRAM_ADDR,
    output  [1:0]   DRAM_BA,
    output          DRAM_CAS_N,
    output          DRAM_CKE,
    output          DRAM_CLK,
    output          DRAM_CS_N,
    inout   [15:0]  DRAM_DQ,
    output          DRAM_LDQM,
    output          DRAM_RAS_N,
    output          DRAM_UDQM,
    output          DRAM_WE_N,

    // VGA
    output  [7:0]   VGA_B,
    output          VGA_BLANK_N,
    output          VGA_CLK,
    output  [7:0]   VGA_G,
    output          VGA_HS,
    output  [7:0]   VGA_R,
    output          VGA_SYNC_N,
    output          VGA_VS,
    
    // I/O
    input   [3:0]   KEY,
    input   [9:0]   SW,
    output  [9:0]   LEDR,
	output 	[6:0]	HEX0,
	output 	[6:0]	HEX1,
	output 	[6:0]	HEX2,
	output 	[6:0]	HEX3,
	output 	[6:0]	HEX4,
	output 	[6:0]	HEX5
);

	wire sys_clk;

    wire reset;
    wire pulse_1s;

    assign reset = ~KEY[0];

    pulse #(
        .DURATION(1000),
        .CLOCK_FREQUENCY(166000000))
    generate_pulse_1s(
        sys_clk,reset,pulse_1s
    );

    // always @(posedge pulse_1s or posedge reset) begin
    //     if(reset) colour<=0;
    //     else colour<=colour+1;
    // end

	// --- Originally in module refresh_draw_triangle ---

	assign draw_en = pulse_1s;

	reg [2:0] current_state, next_state;
	wire drawer_done;
	reg drawer_en;
	reg [3:0] opcode;
	reg [15:0] ax, ay, bx, by, cx, cy;
	reg [23:0] colour;

	reg [31:0] current_buffer_addr;
	wire swap_buffer;

	wire screen_clear;
	wire screen_start;
	wire [31:0] old_screen_colour; 
	wire [31:0] new_screen_colour;
	wire [15:0] screen_x_min, screen_y_min;
	wire [15:0] screen_x_range, screen_y_range;
	wire [15:0] screen_x, screen_y;
	wire screen_done;

	localparam
		S_WAIT = 0,
		S_START_CLEAR = 1,
		S_WAIT_CLEAR = 2,
		S_START_TRIANGLE = 3,
		S_WAIT_TRIANGLE = 4,
		S_SWAP_BUFFER = 5;

	always @(*) begin
		case(current_state)
			S_WAIT: next_state = draw_en ? S_START_CLEAR : S_WAIT;
			S_START_CLEAR: next_state = S_WAIT_CLEAR;
			S_WAIT_CLEAR: next_state = screen_done ? S_START_TRIANGLE : S_WAIT_CLEAR;
			S_START_TRIANGLE: next_state = S_WAIT_TRIANGLE;
			S_WAIT_TRIANGLE: next_state = drawer_done ? S_SWAP_BUFFER : S_WAIT_TRIANGLE;
			S_SWAP_BUFFER: next_state = S_WAIT;
		endcase
	end

	always @(posedge sys_clk) begin
		if(reset) current_state <= 0;
		else current_state <= next_state;
	end

	always @(posedge sys_clk) begin
		drawer_en <= 0;
		if(reset) begin
			ax <= 16'd0; ay <= 16'd0;
			bx <= 16'd300; by <= 16'd100;
			cx <= 16'd100; cy <= 16'd300;
			colour <= 0;
			current_buffer_addr <= 32'h0012C000;
		end
		else begin
			case(current_state)
				S_START_TRIANGLE: begin
					ax <= ax == 639 ? 0 : ax+1;
					bx <= bx == 639 ? 0 : bx+1;
					cx <= cx == 639 ? 0 : cx+1;
					colour <= colour + 'd1000;
					opcode <= 1;
					drawer_en <= 1;
				end
				S_SWAP_BUFFER: current_buffer_addr <= (current_buffer_addr == 32'h00000000) ? 32'h0012C000 : 32'h00000000;
			endcase
		end
	end

	assign swap_buffer = current_state == S_SWAP_BUFFER;
	assign screen_clear = current_state == S_START_CLEAR;

	assign LEDR[9] = (current_state == S_WAIT_CLEAR) | (current_state == S_WAIT_TRIANGLE);	// LED to gauge when SDRAM is being accessed by us
	assign LEDR[8] = VGA_BLANK_N;

	draw_mesh_test dmt(
		.clock(sys_clk),
		.reset(reset),
		.start(drawer_en),
		.done(drawer_done),

		.screen_start(screen_start),
		.new_screen_colour(new_screen_colour),
		.screen_x_min(screen_x_min), .screen_y_min(screen_y_min),
		.screen_x_range(screen_x_range), .screen_y_range(screen_y_range),
		.screen_x(screen_x), .screen_y(screen_y),
		.old_screen_colour(old_screen_colour),
		.screen_done(screen_done)
	);

    // --- Instantiating the system ---
    
    FlightGPA_System system (
    
        // Global signals
        .sys_ref_clk_clk        (CLOCK_50),
        .sys_ref_reset_reset    (reset),
        .vga_ref_clk_clk        (CLOCK2_50),
        .vga_ref_reset_reset    (reset),

		.sys_clk_bridge_out_clk_clk (sys_clk),
         
        // SDRAM signals
        .sdram_clk_clk          (DRAM_CLK),
        .sdram_addr             (DRAM_ADDR),
        .sdram_ba               (DRAM_BA),
        .sdram_cas_n            (DRAM_CAS_N),
        .sdram_cke              (DRAM_CKE),
        .sdram_cs_n             (DRAM_CS_N),
        .sdram_dq               (DRAM_DQ),
        .sdram_dqm              ({DRAM_UDQM, DRAM_LDQM}),
        .sdram_ras_n            (DRAM_RAS_N),
        .sdram_we_n             (DRAM_WE_N),
        
        // VGA signals
        .vga_CLK                (VGA_CLK),
        .vga_BLANK              (VGA_BLANK_N),
        .vga_SYNC               (VGA_SYNC_N),
        .vga_HS                 (VGA_HS),
        .vga_VS                 (VGA_VS),
        .vga_R                  (VGA_R),
        .vga_G                  (VGA_G),
        .vga_B                  (VGA_B),

		// SDRAM interface signals
		.sdram_interface_ext_interface_start			(screen_start | (current_state == S_START_CLEAR)),
		.sdram_interface_ext_interface_done    			(screen_done),
		.sdram_interface_ext_interface_x_start  		(screen_x_min),
		.sdram_interface_ext_interface_x_length 		(screen_x_range),
		.sdram_interface_ext_interface_y_start   		(screen_y_min),
		.sdram_interface_ext_interface_y_length  		(screen_y_range),
		.sdram_interface_ext_interface_current_x 		(screen_x),
		.sdram_interface_ext_interface_current_y 		(screen_y),
		.sdram_interface_ext_interface_old_color 		(old_screen_colour),
		.sdram_interface_ext_interface_new_color 		(new_screen_colour),
		.sdram_interface_ext_interface_base_addr_offset	(current_buffer_addr),
		.sdram_interface_ext_interface_clear			(screen_clear),
		.sdram_interface_ext_interface_stall			(VGA_BLANK_N | SW[9]),

		// Pixel buffer controller signals
        .pixel_buffer_controller_ext_interface_swap_buffer(swap_buffer)
	);

	// --- Hex decoders ---

	hex_decoder hex5 ( .c(colour[23:20]), .display(HEX5) );
	hex_decoder hex4 ( .c(colour[19:16]), .display(HEX4) );
	hex_decoder hex3 ( .c(colour[15:12]), .display(HEX3) );
	hex_decoder hex2 ( .c(colour[11:8]), .display(HEX2) );
	hex_decoder hex1 ( .c(colour[7:4]), .display(HEX1) );
	hex_decoder hex0 ( .c(colour[3:0]), .display(HEX0) );
	
endmodule

module draw_mesh_test(
    input wire clock,
    input wire reset,
    input wire start,
    output wire done,

    output wire screen_start,
    output wire [31:0] new_screen_colour,
    output wire [31:0] screen_x_min, screen_y_min,
    output wire [31:0] screen_x_range, screen_y_range,
    input wire [31:0] screen_x, screen_y,
    input wire [31:0] old_screen_colour,
    input wire screen_done

    // input wire CLOCK_50,
    // input wire [1:0] KEY,


    // output VGA_CLK,   		//	VGA Clock
	// output VGA_HS,			//	VGA H_SYNC
	// output VGA_VS,			//	VGA V_SYNC
	// output VGA_BLANK_N,		//	VGA BLANK
	// output VGA_SYNC_N,		//	VGA SYNC
	// output [7:0] VGA_R, 	//	VGA Red[9:0]
	// output [7:0] VGA_G,		//	VGA Green[9:0]
	// output [7:0] VGA_B  	//	VGA Blue[9:0]
);
    // wire clock;
    // wire reset;
    // wire start;

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
    wire [31:0] colour;
    wire draw_en, draw_done;

    // wire screen_start;
    // wire [31:0] new_screen_colour;
    // wire [31:0] screen_x_min, screen_y_min;
    // wire [31:0] screen_x_range, screen_y_range;
    // wire [31:0] screen_x, screen_y;
    // wire [31:0] old_screen_colour;
    // wire screen_done;

    // assign clock = CLOCK_50;
    // assign reset = ~KEY[0];
    // assign start = ~KEY[1];

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
        .pitch(32'd10),
        .yaw(32'd100),
        .x(32'd0),
        .y(32'd0),
        .z(32'hFFFFFE0C),
        .count(32'd9),
        .done(mvp_pipe_done),
        .mesh_addr(mesh_addr),
        .mesh_data(mesh_data),
        .result_addr(mvp_pipe_res_addr),
        .result_data(mvp_pipe_res_data));

    draw_triangle_pipe #(
        .WIDTH(32),
        .COLOUR_WIDTH(32))
    dtp(
        .clock(clock),
        .reset(reset),
        .start(draw_tri_pipe_start),
        .strip(1'b0),
        .count(32'd3),
        .done(draw_tri_pipe_done),
        .mem_read_addr(mvp_pipe_res_addr),
        .mem_read_data(mvp_pipe_res_data),
        .mem_col_addr(),
        .mem_col_data(32'hFF00FF00),
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
        .done(done),
        .mvp_pipe_start(mvp_pipe_start),
        .mvp_pipe_update_mvp(mvp_pipe_update_mvp),
        .mvp_pipe_done(mvp_pipe_done),
        .draw_tri_pipe_start(draw_tri_pipe_start),
        .draw_tri_pipe_done(draw_tri_pipe_done));

    draw_triangle #(
        .WIDTH(32),
        .COLOUR_WIDTH(32))
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
    
    // screen_writer #(
    //     .WIDTH(32),
    //     .COLOUR_WIDTH(3))
    // sw(
	// 	.clock(clock),
	// 	.reset(reset),
	// 	.screen_start(screen_start),
	// 	.new_screen_colour(new_screen_colour),
	// 	.screen_x_min(screen_x_min),
    //     .screen_y_min(screen_y_min),
	// 	.screen_x_range(screen_x_range),
    //     .screen_y_range(screen_y_range),
	// 	.screen_x(screen_x),
    //     .screen_y(screen_y),
	// 	.old_screen_colour(old_screen_colour),
	// 	.screen_done(screen_done),
	// 	.VGA_CLK(VGA_CLK),
	// 	.VGA_HS(VGA_HS),
	// 	.VGA_VS(VGA_VS),
	// 	.VGA_BLANK_N(VGA_BLANK_N),
	// 	.VGA_SYNC_N(VGA_SYNC_N),
	// 	.VGA_R(VGA_R),
	// 	.VGA_G(VGA_G),
	// 	.VGA_B(VGA_B));

endmodule