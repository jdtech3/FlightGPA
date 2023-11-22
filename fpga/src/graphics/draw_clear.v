module draw_clear(
	clock, reset,
	colour,
	draw_en,
	draw_done,

	screen_start,						// to interface
	new_screen_colour,					// to interface
	screen_x_min, screen_y_min,			// to interface
	screen_x_range, screen_y_range,		// to interface
	screen_x, screen_y,					// from interface
	old_screen_colour,					// from interface
	screen_done							// from interface
);

    parameter WIDTH=8;
	parameter COLOUR_WIDTH=3;
    parameter SCREEN_SIZE_X = 160;
    parameter SCREEN_SIZE_Y = 120;

	input wire clock, reset;
	input wire [COLOUR_WIDTH-1:0] colour;
	input wire draw_en;
	output wire draw_done;
	
	output wire screen_start;								// to interface
	output wire [COLOUR_WIDTH-1:0] new_screen_colour;		// to interface
	output wire [WIDTH-1:0] screen_x_min, screen_y_min;		// to interface
	output wire [WIDTH-1:0] screen_x_range, screen_y_range;	// to interface
	input wire [WIDTH-1:0] screen_x, screen_y;				// from interface
	input wire [COLOUR_WIDTH-1:0] old_screen_colour;		// from interface
	input wire screen_done;									// from interface

	reg current_state, next_state;

    localparam
		S_WAIT = 1'd0,
		S_DRAW = 1'b1;
    
	assign screen_start = draw_en;
	assign new_screen_colour = colour;
    assign screen_x_min = 0;
    assign screen_y_min = 0;
    assign screen_x_range = SCREEN_SIZE_X;
	assign screen_y_range = SCREEN_SIZE_Y;
	assign draw_done = screen_done;
    
    always @(*) begin
		case(current_state)
			S_WAIT: next_state <= draw_en ? S_DRAW : S_WAIT;
			S_DRAW: next_state <= draw_done ? S_WAIT : S_DRAW;
		endcase
	end
	
	always @(posedge clock) begin
		if(reset) current_state <= S_WAIT;
		else current_state <= next_state;
	end

endmodule