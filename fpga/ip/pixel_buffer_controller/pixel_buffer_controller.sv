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
    parameter BASE_ADDR_OFFSET = 16'h0000,
    parameter ADDR_WIDTH = 16
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

endmodule
