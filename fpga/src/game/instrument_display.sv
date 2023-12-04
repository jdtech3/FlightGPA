/*

    File: instrument_display.sv
    Author: Joe Dai
    Date: 2023

    This module displays the "instruments" on HEX displays. Namely:
    
    HEX5,4:
        - Always: Throttle (0-100%)
    
    HEX3,2,1,0:
        - SW7 on: Heading (0-360 deg)
        - SW8 on: Altitude (0-9999 m)
        - SW9 on: Speed (0-999 km/h)    NOTE! INPUT IS IN m/s, THIS MODULE DOES CONVERSION

    Notes: 
        - Expects unsigned integer
        - Assumes inputs are in range

*/

module instrument_display #(
    parameter UPDATE_MS = 100,              // miliseconds interval between updates
    parameter CLOCK_FREQUENCY = 166000000
)
(
    input clk,
    input reset,

    input [7:0]     throttle,
    input [15:0]    heading,
    input [15:0]    altitude,
    input [15:0]    speed,      // input in m/s!

    input [9:0]     SW,

    output [6:0]    HEX5,
    output [6:0]    HEX4,
    output [6:0]    HEX3,
    output [6:0]    HEX2,
    output [6:0]    HEX1,
    output [6:0]    HEX0
);

    // --- Signals ---

    logic           update;

    logic [6:0]     hex3, hex2, hex1, hex0;

    logic [7:0]     throttle_digits;
    logic [15:0]    multi_display_value;
    logic [15:0]    multi_display_digits;
    logic [47:0]    speed_kmh;
    
    // --- Logic ---

    always_comb begin
        speed_kmh = {speed, 8'h00} * 24'h00039A;    // 0003.9A is 3.6 in 16.8 bit fixed point

        case (SW[9:7])
            3'b001: multi_display_value = heading;
            3'b010: multi_display_value = altitude;
            3'b100: multi_display_value = speed_kmh[31:16];     // output of mult is 32.16 bit; drop fraction and MSB
            default: multi_display_value = 16'hFFFF;            // "error"
        endcase

        // Display "error" + blank 4th digit if not displaying altitude
        HEX3 = (multi_display_value == 16'hFFFF) ? ~7'b1000000 : ( (SW[9:7] != 3'b010) ? ~7'b0000000 : hex3);
        HEX2 = (multi_display_value == 16'hFFFF) ? ~7'b1000000 : hex2;
        HEX1 = (multi_display_value == 16'hFFFF) ? ~7'b1000000 : hex1;
        HEX0 = (multi_display_value == 16'hFFFF) ? ~7'b1000000 : hex0;
    end

    // --- Modules ---

    pulse #(UPDATE_MS, CLOCK_FREQUENCY) pulse0 ( clk, reset, update );

    binary_to_4digits btd1 (
        .clk(clk),
        .reset(reset | update),
        .binary(throttle),
        .digits(throttle_digits)
    );
    binary_to_4digits btd0 (
        .clk(clk),
        .reset(reset | update),
        .binary(multi_display_value),
        .digits(multi_display_digits)
    );

    hex_decoder decoder5 ( .c(throttle_digits[7:4]), .display(HEX5) );
    hex_decoder decoder4 ( .c(throttle_digits[3:0]), .display(HEX4) );
    hex_decoder decoder3 ( .c(multi_display_digits[15:12]), .display(hex3) );
    hex_decoder decoder2 ( .c(multi_display_digits[11:8]), .display(hex2) );
    hex_decoder decoder1 ( .c(multi_display_digits[7:4]), .display(hex1) );
    hex_decoder decoder0 ( .c(multi_display_digits[3:0]), .display(hex0) );

endmodule
