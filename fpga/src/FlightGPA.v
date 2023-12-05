module FlightGPA (
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
    output  [6:0]   HEX5,
    output  [6:0]   HEX4,
    output  [6:0]   HEX3,
    output  [6:0]   HEX2,
    output  [6:0]   HEX1,
    output  [6:0]   HEX0
);

    // --- Localparams ---
    
    parameter COORD_WIDTH = 32;         // x, y, z
    parameter ANGLE_WIDTH = 16;         // pitch, roll, heading

    // --- Signals ---

    wire sys_clk;
    wire sys_reset = ~KEY[0];
    wire vga_reset = ~KEY[0];

    // External inputs
    wire signed [ANGLE_WIDTH-1:0] pitch_change = 'd0;   // deg/sec
    wire signed [ANGLE_WIDTH-1:0] roll_change = 'd0;    // deg/sec
    wire [7:0] throttle = 'd100;                        // 0-100%

    // Plane state module
    wire plane_state_update_enable = SW[0];
    wire plane_state_update_done;
    wire plane_state_request_input;
    wire plane_state_input_ready = 1'b1;
    wire plane_state_request_velocities;
    wire plane_state_velocities_ready = 1'b1;
    wire signed [COORD_WIDTH-1:0] plane_state_v_x = 'd0;
    wire signed [COORD_WIDTH-1:0] plane_state_v_y = -'d10;
    wire signed [COORD_WIDTH-1:0] plane_state_v_z = 'd0;
    wire signed [COORD_WIDTH-1:0] plane_state_x;
    wire signed [COORD_WIDTH-1:0] plane_state_y;
    wire signed [COORD_WIDTH-1:0] plane_state_z;
    wire [COORD_WIDTH-1:0] plane_state_speed;
    wire signed [ANGLE_WIDTH-1:0] plane_state_pitch;
    wire signed [ANGLE_WIDTH-1:0] plane_state_roll;
    wire [ANGLE_WIDTH-1:0] plane_state_heading;
    wire [2:0] plane_state_plane_status_bits;

    // --- Modules ---

    plane_state plane (
        .clk(sys_clk), .reset(sys_reset),

        .update_enable(plane_state_update_enable),
        .update_done(plane_state_update_done),
        .request_input(plane_state_request_input),        
        .input_ready(plane_state_input_ready),
        .request_velocities(plane_state_request_velocities),
        .velocities_ready(plane_state_velocities_ready),
        .pitch_change(pitch_change),
        .roll_change(roll_change),
        .throttle(throttle),
        .v_x(plane_state_v_x),
        .v_y(plane_state_v_y),
        .v_z(plane_state_v_z),
        .x(plane_state_x),
        .y(plane_state_y),
        .z(plane_state_z),
        .speed(plane_state_speed),
        .pitch(plane_state_pitch),
        .roll(plane_state_roll),
        .heading(plane_state_heading),
        .plane_status_bits(plane_state_plane_status_bits)
    );

    instrument_display instruments (
        .clk(sys_clk), .reset(sys_reset),

        .throttle(throttle),
        .heading(plane_state_heading),
        .altitude(plane_state_y),       // technically y is signed, but y < 0 should never happen anyway
        .speed(plane_state_speed),

        .SW(SW),
        .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0)
    );
    
    // --- Instantiating the system ---
    
    FlightGPA_System system (
    
        // Global signals
        .sys_ref_clk_clk        (CLOCK_50),
        .sys_ref_reset_reset    (sys_reset),
        .vga_ref_clk_clk        (CLOCK2_50),
        .vga_ref_reset_reset    (vga_reset),

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
        .vga_B                  (VGA_B)

	);
    
endmodule
