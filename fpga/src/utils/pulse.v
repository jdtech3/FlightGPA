module pulse(clock,reset,out);
    parameter DURATION=1000;
    parameter CLOCK_FREQUENCY=50000000;
    input wire clock, reset;
    output wire out;

    localparam COUNT_MAX = CLOCK_FREQUENCY/(1000/DURATION);
    localparam WIDTH=$clog2(COUNT_MAX);
    
    wire [WIDTH-1:0] counter_val;
    assign out = counter_val == COUNT_MAX;

    counter #(WIDTH) count(
        clock,reset|out,1'b1,counter_val
    );
endmodule