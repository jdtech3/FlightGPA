`timescale 1ps/1ps

module sdram_draw_clear_test(
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
    output  [9:0]   LEDR
);

    // --- Signals ---

    typedef enum bit [3:0] { 
        IDLE, 
        WAIT_KEY_RELEASE, 
        ASSERT_CLEAR,
        WAIT_CLEAR,
        DONE 
    } state_t;

    wire sys_clk;
    wire sys_reset = ~KEY[0];
    state_t current_state;
    state_t next_state;
    logic screen_start;
    logic screen_clear;
    logic screen_done;

    // --- Logic ---

    always_comb begin
        case (current_state)
            IDLE:               next_state = ~KEY[3] ? WAIT_KEY_RELEASE : IDLE;
            WAIT_KEY_RELEASE:   next_state = KEY[3] ? ASSERT_CLEAR : WAIT_KEY_RELEASE;
            ASSERT_CLEAR:       next_state = WAIT_CLEAR;
            WAIT_CLEAR:         next_state = screen_done ? DONE : WAIT_CLEAR;
            DONE:               next_state = IDLE;
            default:            next_state = IDLE;
        endcase
    end

    always_ff @ (posedge sys_clk) begin
        current_state <= sys_reset ? IDLE : next_state;
    end

    always_comb begin
        screen_start = current_state == ASSERT_CLEAR;
        screen_clear = current_state == ASSERT_CLEAR;
    end

    assign LEDR[9] = current_state == WAIT_CLEAR;   // indicate clear is still being written
    assign LEDR[3:0] = current_state;               // indicate current state

	// --- Instantiating the system ---
    
    FlightGPA_System system (
    
        // Global signals
        .sys_ref_clk_clk        (CLOCK_50),
        .sys_ref_reset_reset    (sys_reset),
        .vga_ref_clk_clk        (CLOCK2_50),
        .vga_ref_reset_reset    (~KEY[1]),

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
		.sdram_interface_ext_interface_start		    (screen_start),
		.sdram_interface_ext_interface_done    			(screen_done),
		.sdram_interface_ext_interface_x_start  		(0),                // clear should override these
		.sdram_interface_ext_interface_x_length 		(1),
		.sdram_interface_ext_interface_y_start   		(0),
		.sdram_interface_ext_interface_y_length  		(1),
		.sdram_interface_ext_interface_new_color        (32'hFFFFFFFF),
		// .sdram_interface_ext_interface_old_color
		// .sdram_interface_ext_interface_current_x
		// .sdram_interface_ext_interface_current_y
		.sdram_interface_ext_interface_base_addr_offset	(SW[0] ? 32'h0012C000 : 32'h00000000),  // select which buf to clear
		.sdram_interface_ext_interface_clear			(screen_clear),

        // Pixel buffer controller signals
        .pixel_buffer_controller_ext_interface_swap_buffer(1'b0)
	);
	
endmodule
