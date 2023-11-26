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
        - Does not check bounds
        - Assumes 32-bit address width

*/

module sdram_interface #(
    parameter int DATA_WIDTH = 32
)
(
    input wire	clk,
    input wire	reset,

    // Avalon master I/O for writer
    output logic [31:0]             wm_address,
    output logic [DATA_WIDTH-1:0]   wm_writedata,
    output logic                    wm_write,
    input logic                     wm_waitrequest,

    // Avalon master I/O for reader
    output logic [31:0]             rm_address,
    input logic [DATA_WIDTH-1:0]    rm_readdata,
    output logic                    rm_read,
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

    // --- Parameters ---

    localparam int FIFO_DEPTH = 32;

    // --- FSM state enums ---

    typedef enum bit [3:0] {
        MODULE_IDLE,
        MODULE_START,
        MODULE_FETCH,
        MODULE_WAIT,
        MODULE_FLUSH,
        MODULE_DONE
    } module_state_t;

    typedef enum bit [3:0] { 
        SDRAM_WRITER_IDLE,
        SDRAM_WRITER_START,
        SDRAM_WRITER_PRETRANSFER,
        SDRAM_WRITER_WRITING,
        SDRAM_WRITER_POST_WRITE,
        SDRAM_WRITER_DONE
    } sdram_writer_state_t;

    typedef enum bit [3:0] { 
        SDRAM_READER_IDLE,
        SDRAM_READER_START,
        SDRAM_READER_PRETRANSFER,
        SDRAM_READER_READING,
        SDRAM_READER_POST_READ,
        SDRAM_READER_DONE
    } sdram_reader_state_t;
    
    // --- Signals ---

    reg write_go;
    wire write_done;
    reg write_write;
    wire write_buffer_full;
    sdram_writer_state_t write_current_state;
    sdram_writer_state_t write_next_state;
    
    reg [23:0] color_counter;

    write_master #(
        .DATAWIDTH(DATA_WIDTH),
		.FIFODEPTH(FIFO_DEPTH),
		.FIFODEPTH_LOG2($clog2(FIFO_DEPTH))
    ) writer (
        .clk(clk),
        .reset(reset),
        
        .control_fixed_location(1'b0),
        .control_write_base(32'h00000000),
        .control_write_length(32'd1228800),
        .control_go(write_go),
        .control_done(write_done),
        
//		.user_buffer_data(color),
        .user_buffer_data({8'hFF, color_counter[23:0]}),
        .user_write_buffer(write_write),
        .user_buffer_full(write_buffer_full),
        
        .master_address(wm_address),
        .master_write(wm_write),
        .master_writedata(wm_writedata),
        .master_waitrequest(wm_waitrequest)
    );
    
	burst_read_master #(
        .DATAWIDTH(DATA_WIDTH),
		.FIFODEPTH(FIFO_DEPTH),
		.FIFODEPTH_LOG2($clog2(FIFO_DEPTH)),
        .MAXBURSTCOUNT(1),      // we don't use bursting
        .BURSTCOUNTWIDTH(1)
	) reader (
		// Connections
		.clk(clk),
		.reset(reset),
		.master_address(avm_m0_address),
		.master_read(avm_m0_read),
		.master_byteenable(avm_m0_byteenable),
		.master_readdata(avm_m0_readdata),
		.master_readdatavalid(avm_m0_readdatavalid),
		.master_burstcount(avm_m0_burstcount),
		.master_waitrequest(avm_m0_waitrequest)
	);
    
    always_comb begin
        case (write_current_state)
            SDRAM_WRITER_IDLE:          write_next_state = SDRAM_WRITER_START;
            SDRAM_WRITER_START:         write_next_state = SDRAM_WRITER_PRETRANSFER;
            SDRAM_WRITER_PRETRANSFER:   write_next_state = SDRAM_WRITER_WRITING;
            SDRAM_WRITER_WRITING:       write_next_state = SDRAM_WRITER_POST_WRITE;
            SDRAM_WRITER_POST_WRITE:    write_next_state = write_buffer_full ? SDRAM_WRITER_POST_WRITE :   	// also stuck here if FIFO full
                                                                               (write_done ? SDRAM_WRITER_DONE : SDRAM_WRITER_WRITING);
            SDRAM_WRITER_DONE:          write_next_state = SDRAM_WRITER_DONE;
            default:                    write_next_state = SDRAM_WRITER_IDLE;
        endcase
    end
    
    always_ff @ (posedge clk) begin
        if (reset) begin
            write_current_state <= SDRAM_WRITER_IDLE;
            color_counter <= 0;
        end
        else write_current_state <= write_next_state;
        
        if (write_current_state == SDRAM_WRITER_WRITING) color_counter <= color_counter + 54;
    end
    
    always_comb begin
        write_go = write_current_state == SDRAM_WRITER_START;
        write_write = write_current_state == SDRAM_WRITER_WRITING;
    end
endmodule
