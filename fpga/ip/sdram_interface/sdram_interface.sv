`timescale 1 ps / 1 ps

/*

    File: sdram_interface.sv
    Author: Joe Dai
    Date: 2023

    This module implements a caching layer for SDRAM.
    Essentially, given a start address and length, it wil read the contiguous block from SDRAM into BRAM,
    expose the BRAM interface, and on a FLUSH signal, write the data from BRAM back into SDRAM.

    Notes: 
        - Does not implement bursting as SDRAM controller IP does not seem to support bursting.
        - Does not check bounds, assumes 0 < x < 640, 0 < y < 480
        - Assumes 32-bit address width
        - 24-bit data width does NOT work due to Avalon adapter issues

        - DOES NOT HAVE CACHING YET!

*/

module sdram_interface #(
    parameter CLEAR_COLOR = 32'hFF000000,

    // The following are all supposed to be private localparams,
    // but Quartus Lite does not support localparams in parameter initialization list :/
    parameter COLOR_WIDTH = 32,
    parameter FIFO_DEPTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter COORD_WIDTH = 16
)
(
    input wire	clk,
    input wire	reset,

    // Control
    input wire                      start,
    output wire                     done,
    input wire                      stall,              // if high, stall memory access
    input wire [ADDR_WIDTH-1:0]     base_addr_offset,   // which buffer to write to

    // Special operations
    input wire  clear,      // clear will write CLEAR_COLOR to entire screen

    // Bounds
    input wire [COORD_WIDTH-1:0]    x_start,
    input wire [COORD_WIDTH-1:0]    x_length,
    input wire [COORD_WIDTH-1:0]    y_start,
    input wire [COORD_WIDTH-1:0]    y_length,
    
    // Current pixel
    output wire [COORD_WIDTH-1:0]   current_x,
    output wire [COORD_WIDTH-1:0]   current_y,
    output reg [COLOR_WIDTH-1:0]    old_color,  // old color read
    input wire [COLOR_WIDTH-1:0]    new_color,  // new color to write


    // Avalon master I/O for writer
    output logic [ADDR_WIDTH-1:0]   wm_address,
    output logic [COLOR_WIDTH-1:0]  wm_writedata,
    output logic                    wm_write,
    output logic [3:0]              wm_byteenable,
    input logic                     wm_waitrequest,

    // Avalon master I/O for reader 
    output logic [ADDR_WIDTH-1:0]   rm_address,
    input logic [COLOR_WIDTH-1:0]   rm_readdata,
    output logic                    rm_read,
    output logic [3:0]              rm_byteenable,
    input logic                     rm_readdatavalid,
    input logic                     rm_waitrequest

    // Note: 
    //  - We want all bytes, so byteenable is omitted here.
    //  - Source: Avalon Interface Specification: "If an interface does not have a byteenable signal, 
    //            the transfer proceeds as if all byteenables are asserted."
);

    // TEMPORARY notes: targetting use of 2 Mbit BRAM max, or 65,536 32-bit values
    
    // given bounding box (start x, length x, start y, length y)
    // if (length x * length y) < 32768 cache all
    // otherwise, split into sections of (length x) columns and (32768 / length x)

    // --- FSM state enums ---

    typedef enum bit [15:0] {
        MODULE_IDLE,
        MODULE_START_CLEAR,
        MODULE_WRITING_CLEAR,
        MODULE_START_DRAW,
        MODULE_PIXEL_START,
        MODULE_PIXEL_FETCHING,
        // MODULE_PIXEL_FETCH_DONE,
        MODULE_PIXEL_WAIT,
        MODULE_PIXEL_FLUSHING,
        // MODULE_PIXEL_FLUSH_DONE,
        MODULE_PIXEL_DONE,
        MODULE_DONE
    } module_state_t;

    typedef enum bit [15:0] {
        SDRAM_WRITER_IDLE,
        SDRAM_WRITER_START,
        SDRAM_WRITER_CHECK_STALL,
        SDRAM_WRITER_WRITING,
        SDRAM_WRITER_POST_WRITE,
        SDRAM_WRITER_DONE
    } sdram_writer_state_t;

    typedef enum bit [15:0] {
        SDRAM_READER_IDLE,
        SDRAM_READER_START,
        SDRAM_READER_PRETRANSFER,
        SDRAM_READER_PRE_READ,
        SDRAM_READER_READING,
        SDRAM_READER_DONE
    } sdram_reader_state_t;
    
    // --- Signals ---

    // Module
    module_state_t module_current_state;
    module_state_t module_next_state;

    // Pixel grid counter
    logic [COORD_WIDTH-1:0] current_dx;
    logic [COORD_WIDTH-1:0] current_dy;
    logic                   pixel_counter_reset;
    logic                   pixel_counter_enable;
    logic                   pixel_counter_done;

    // Memory
    logic [ADDR_WIDTH-1:0] base_address;

    // Reader
    logic reader_go;
    logic reader_done;
    logic reader_read_ack;
    logic reader_data_available;
    logic [COLOR_WIDTH-1:0] reader_data;
    sdram_reader_state_t reader_current_state;
    sdram_reader_state_t reader_next_state;

    // Writer
    logic writer_start;
    logic writer_done;
    logic [ADDR_WIDTH-1:0] writer_length;           // in words (COLOR_WIDTH bits)
    logic [ADDR_WIDTH-1:0] writer_word_number;      // current word number
    sdram_writer_state_t writer_current_state;
    sdram_writer_state_t writer_next_state;

    // --- Logic: module ---

    assign current_x = x_start + current_dx;
    assign current_y = y_start + current_dy;
    assign base_address = (module_current_state == MODULE_WRITING_CLEAR) ? base_addr_offset : ( base_addr_offset + ( (current_y * 640 + current_x) * 4 ) );

    always_comb begin
        case (module_current_state)
            MODULE_IDLE:                module_next_state = ~start ? MODULE_IDLE : 
                                                                     (clear ? MODULE_START_CLEAR : MODULE_START_DRAW);

            // Clear
            MODULE_START_CLEAR:         module_next_state = MODULE_WRITING_CLEAR;
            MODULE_WRITING_CLEAR:       module_next_state = writer_done ? MODULE_DONE : MODULE_WRITING_CLEAR;

            // Draw
            MODULE_START_DRAW:          module_next_state = MODULE_PIXEL_START;
            MODULE_PIXEL_START:         module_next_state = pixel_counter_done ? MODULE_DONE : MODULE_PIXEL_FETCHING;  // delay to ensure address is stable before we try to read
            MODULE_PIXEL_FETCHING:      module_next_state = (reader_current_state == SDRAM_READER_DONE) ? MODULE_PIXEL_WAIT : MODULE_PIXEL_FETCHING;
            MODULE_PIXEL_WAIT:          module_next_state = MODULE_PIXEL_FLUSHING;
            MODULE_PIXEL_FLUSHING:      module_next_state = writer_done ? MODULE_PIXEL_DONE : MODULE_PIXEL_FLUSHING;
            MODULE_PIXEL_DONE:          module_next_state = MODULE_PIXEL_START;
            
            MODULE_DONE:                module_next_state = MODULE_IDLE;
            default:                    module_next_state = MODULE_IDLE;
        endcase
    end

    always_ff @ (posedge clk) begin
        module_current_state <= reset ? MODULE_IDLE : module_next_state;

        if (module_current_state == MODULE_START_CLEAR) writer_length <= 'd307200;
        else if (module_current_state == MODULE_START_DRAW) writer_length <= 'd1;
    end
    
    always_comb begin
        writer_start = (module_current_state == MODULE_WRITING_CLEAR) | (module_current_state == MODULE_PIXEL_FLUSHING);
        pixel_counter_reset = module_current_state == MODULE_START_DRAW;
        pixel_counter_enable = module_current_state == MODULE_PIXEL_DONE;
        done = module_current_state == MODULE_DONE;
    end

    // --- Logic: reader ---

    always_comb begin
        case (reader_current_state)
            SDRAM_READER_IDLE:          reader_next_state = (module_current_state == MODULE_PIXEL_FETCHING) ? SDRAM_READER_START : SDRAM_READER_IDLE;
            SDRAM_READER_START:         reader_next_state = SDRAM_READER_PRETRANSFER;
            SDRAM_READER_PRETRANSFER:   reader_next_state = ~stall ? SDRAM_READER_PRE_READ : SDRAM_READER_PRETRANSFER;
            SDRAM_READER_PRE_READ:      reader_next_state = reader_data_available ? SDRAM_READER_READING : SDRAM_READER_PRE_READ;   // also stuck here if no data to read
            SDRAM_READER_READING:       reader_next_state = reader_done ? SDRAM_READER_DONE : SDRAM_READER_PRE_READ;
            SDRAM_READER_DONE:          reader_next_state = SDRAM_READER_IDLE;
            default:                    reader_next_state = SDRAM_READER_IDLE;
        endcase
    end

    always_ff @ (posedge clk) begin
        reader_current_state <= reset ? SDRAM_READER_IDLE : reader_next_state;
        if (reader_current_state == SDRAM_READER_READING) old_color <= reader_data;
    end
    
    always_comb begin
        reader_go = reader_current_state == SDRAM_READER_START;
        reader_read_ack = reader_current_state == SDRAM_READER_READING;
    end

    // --- Logic: writer ---

    always_comb begin
        case (writer_current_state)
            // SDRAM_WRITER_IDLE:          writer_next_state = writer_start ? (writer_length == 1'b1 ? SDRAM_WRITER_WRITING : SDRAM_WRITER_START) : SDRAM_WRITER_IDLE;
            SDRAM_WRITER_IDLE:          writer_next_state = writer_start ? SDRAM_WRITER_START : SDRAM_WRITER_IDLE;
            SDRAM_WRITER_START:         writer_next_state = SDRAM_WRITER_WRITING;
            // SDRAM_WRITER_CHECK_STALL:   writer_next_state = ~stall ? SDRAM_WRITER_WRITING : SDRAM_WRITER_CHECK_STALL;
            SDRAM_WRITER_WRITING:       writer_next_state = wm_waitrequest ? SDRAM_WRITER_WRITING : SDRAM_WRITER_POST_WRITE;
            // SDRAM_WRITER_POST_WRITE:    writer_next_state = (writer_length == 1'b1 | writer_word_number == writer_length-1) ? SDRAM_WRITER_DONE : SDRAM_WRITER_WRITING;
            SDRAM_WRITER_POST_WRITE:    writer_next_state = (writer_word_number == writer_length-1) ? SDRAM_WRITER_DONE : 
                                                                                                      (~stall ? SDRAM_WRITER_WRITING : SDRAM_WRITER_POST_WRITE);
            SDRAM_WRITER_DONE:          writer_next_state = SDRAM_WRITER_IDLE;
            default:                    writer_next_state = SDRAM_WRITER_IDLE;
        endcase
    end

    always_ff @ (posedge clk) begin
        writer_current_state <= reset ? SDRAM_WRITER_IDLE : writer_next_state;
        
        if (writer_current_state == SDRAM_WRITER_START) writer_word_number <= 'd0;
        else if (writer_current_state == SDRAM_WRITER_POST_WRITE) writer_word_number <= writer_word_number + (stall ? 'd0 : 'd1);
    end
    
    always_comb begin
        writer_done = writer_current_state == SDRAM_WRITER_DONE;

        wm_write = writer_current_state == SDRAM_WRITER_WRITING;
        wm_address = base_address + ( writer_word_number * (COLOR_WIDTH/8) );
        wm_writedata = (module_current_state == MODULE_WRITING_CLEAR) ? CLEAR_COLOR : new_color;     // feed new_color directly as drawing module is combinational anyway
        wm_byteenable = -1;  // enable all
    end
    
    // --- Modules ---

    grid_counter #(
        .WIDTH(COORD_WIDTH)
    ) counter (
        .clock(clk),
        .reset(reset | pixel_counter_reset),
        .enable(pixel_counter_enable),
        .x_max(x_length),
        .y_max(y_length),
        .x(current_dx),
        .y(current_dy),
        .end_of_grid(pixel_counter_done)
    );
    
	latency_aware_read_master #(
        .DATAWIDTH(COLOR_WIDTH),
		.FIFODEPTH(FIFO_DEPTH),
		.FIFODEPTH_LOG2($clog2(FIFO_DEPTH))
	) reader (
		.clk(clk),
		.reset(reset),

        .control_fixed_location(1'b0),
        .control_read_base(base_address),
        .control_read_length(COLOR_WIDTH/8),    // in bytes
        .control_go(reader_go),
        .control_done(reader_done),

        .user_buffer_data(reader_data),
        .user_read_buffer(reader_read_ack),
        .user_data_available(reader_data_available),

		.master_address(rm_address),
		.master_read(rm_read),
        .master_byteenable(rm_byteenable),
		.master_readdata(rm_readdata),
		.master_readdatavalid(rm_readdatavalid),
		.master_waitrequest(rm_waitrequest)
	);

    // write_master #(
    //     .DATAWIDTH(COLOR_WIDTH),
	// 	.FIFODEPTH(FIFO_DEPTH),
	// 	.FIFODEPTH_LOG2($clog2(FIFO_DEPTH))
    // ) writer (
    //     .clk(clk),
    //     .reset(reset),
        
    //     .control_fixed_location(1'b0),
    //     .control_write_base(base_address),
    //     .control_write_length(writer_length),   // in bytes
    //     .control_go(writer_go),
    //     .control_done(writer_done),
        
    //     .user_buffer_data(writer_data),
    //     .user_write_buffer(writer_write),
    //     .user_buffer_full(writer_buffer_full),
        
    //     .master_address(wm_address),
    //     .master_write(wm_write),
    //     .master_byteenable(wm_byteenable),
    //     // .master_writedata(wm_writedata),     // write_master FIFO bypass!!
    //     .master_waitrequest(wm_waitrequest)
    // );

    // assign wm_writedata = writer_data;    // write_master FIFO bypass!!

    // NOTE: write_master FIFO bypass is workaround for issue that somehow data coming out of the writer's Avalon data
    //       data line (master_writedata) don't correspond to our input data (user_write_buffer). Being 0x80 addresses off.
    //       This happens even when FIFO_DEPTH = 1, very odd.
    
endmodule
