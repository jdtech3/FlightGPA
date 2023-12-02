`timescale 1 ps / 1 ps

/*

    File: pixel_buffer_controller.sv
    Author: Joe Dai
    Date: 2023

    This module implements an interface to the Avalon MM slave of the Pixel Buffer DMA.
    Currently implements front/back buffer swapping.

    Notes: 
        - swap_buffer should be 1 cycle pulse
        - Pixel Buffer DMA's registers are all 32 bit

*/

module pixel_buffer_controller #(
    parameter BASE_ADDR_OFFSET = 4'h0,
    parameter ADDR_WIDTH = 4
)
(
    input wire clk,
    input wire reset,

    // Control
    input wire swap_buffer,

    // Avalon master I/O
    output logic [ADDR_WIDTH-1:0]   avm_address,
    output logic [31:0]             avm_writedata,
    output logic                    avm_write,
    input logic                     avm_waitrequest
);

    // --- FSM state enums ---

    typedef enum bit [3:0] { 
        MODULE_IDLE,
        MODULE_WAIT,
        MODULE_WRITE,
        MODULE_DONE
    } module_state_t;

    // --- Signals ---

    module_state_t module_current_state;
    module_state_t module_next_state;

    // --- Logic ---

    always_comb begin
        case (module_current_state)
            MODULE_IDLE:    module_next_state = swap_buffer ? (avm_waitrequest ? MODULE_WAIT : MODULE_WRITE) : MODULE_IDLE;
            MODULE_WAIT:    module_next_state = avm_waitrequest ? MODULE_WAIT : MODULE_WRITE;
            MODULE_WRITE:   module_next_state = MODULE_DONE;
            MODULE_DONE:    module_next_state = MODULE_IDLE;
            default:        module_next_state = MODULE_IDLE;
        endcase
    end

    always_ff @ (posedge clk) begin
        module_current_state <= reset ? MODULE_IDLE : module_next_state;
    end

    always_comb begin
        avm_address = BASE_ADDR_OFFSET;     // buffer register is at offset 0
        avm_writedata = 0;                  // dummy data, doesn't matter
        
        avm_write = module_current_state == MODULE_WRITE;
    end
endmodule
