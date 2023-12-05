/*

    File: external_throttle.sv
    Author: Joe Dai
    Date: 2023

    This module grabs throttle inputs from parallel GPIO.

*/

module external_throttle #(
    parameter UPDATE_MS = 100,              // miliseconds interval between updates
    parameter CLOCK_FREQUENCY = 166000000
)
(
    input clk,
    input reset,

    input [3:0]         gpio,
    output logic [7:0]  throttle
);

    // --- Signals ---

    logic       update;
    logic [3:0] gpio_reg;
    
    // --- Logic ---

    always_ff @ (posedge clk) begin
        if (reset) throttle <= 0;
        else begin
            gpio_reg <= gpio;
            if (update) throttle <= (gpio_reg < 'd10) ? gpio_reg * 'd10 : 'd100;
        end
    end

    // --- Modules ---

    pulse #(UPDATE_MS, CLOCK_FREQUENCY) pulse0 ( clk, reset, update );

endmodule
