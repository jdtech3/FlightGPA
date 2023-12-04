module draw_triangle_pipe(
    clock,reset,start,strip,
    count,
    done,

    mem_read_addr,
    mem_read_data,
    
    mem_col_addr,
    mem_col_data,
    
    opcode,
    ax, ay, az,
    bx, by, bz,
    cx, cy, cz,
    colour,
    draw_en,
    draw_done
);
    parameter WIDTH=32;
    parameter COLOUR_WIDTH=3;

    input wire clock, reset, start, strip;
    input wire [WIDTH-1:0] count;
    output wire done;

    output reg [WIDTH-1:0] mem_read_addr;
    input wire [WIDTH-1:0] mem_read_data;

    output wire [WIDTH-1:0] mem_col_addr;
    input wire [COLOUR_WIDTH-1:0] mem_col_data;

    output wire [2:0] opcode;
    output reg [WIDTH-1:0] ax, ay, az, bx, by, bz, cx, cy, cz;
    output reg [COLOUR_WIDTH-1:0] colour;
    output draw_en;
    input draw_done;

    localparam
        S_WAIT              = 8'd0,
        S_START_PIPE        = 8'd1,
        S_START_PIPE_DELAY  = 8'd2,
        S_FETCH_AX          = 8'd3,
        S_FETCH_AY          = 8'd4,
        S_FETCH_AZ          = 8'd5,
        S_FETCH_BX          = 8'd6,
        S_FETCH_BY          = 8'd7,
        S_FETCH_BZ          = 8'd8,
        S_FETCH_CX          = 8'd9,
        S_FETCH_CY          = 8'd10,
        S_FETCH_CZ          = 8'd11,
        S_START_DRAW        = 8'd12,
        S_WAIT_DRAW         = 8'd13,
        S_RESUME_FETCH      = 8'd14;

    reg [7:0] current_state, next_state;
    reg [31:0] in_count;

    assign opcode = 3'b1;
    assign mem_col_addr = in_count;
    assign draw_en = current_state == S_START_DRAW;

    always @(*) begin
        case(current_state)
            S_WAIT:             next_state <= start ? S_START_PIPE : S_WAIT;
            S_START_PIPE:       next_state <= S_START_PIPE_DELAY;
            S_START_PIPE_DELAY: next_state <= S_FETCH_AX;
            S_FETCH_AX:         next_state <= S_FETCH_AY;
            S_FETCH_AY:         next_state <= S_FETCH_AZ;
            S_FETCH_AZ:         next_state <= S_FETCH_BX;
            S_FETCH_BX:         next_state <= S_FETCH_BY;
            S_FETCH_BY:         next_state <= S_FETCH_BZ;
            S_FETCH_BZ:         next_state <= S_FETCH_CX;
            S_FETCH_CX:         next_state <= S_FETCH_CY;
            S_FETCH_CY:         next_state <= S_FETCH_CZ;
            S_FETCH_CZ:         next_state <= S_START_DRAW;
            S_START_DRAW:       next_state <= S_WAIT_DRAW;
            S_WAIT_DRAW:        next_state <= draw_done ? ( in_count == count ? S_WAIT : (strip ? S_RESUME_FETCH : S_START_PIPE_DELAY) ) : S_WAIT_DRAW;
            S_RESUME_FETCH:     next_state <= S_FETCH_CX;
        endcase
    end
    
    always @(posedge clock) begin
        if(reset) current_state <= S_WAIT;
        else current_state <= next_state;

        case(current_state)
            S_START_PIPE: begin
                mem_read_addr <= 0;
                in_count <= 0;
            end
            S_START_PIPE_DELAY:
                mem_read_addr <= mem_read_addr+1;
            S_FETCH_AX: begin
                ax <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_AY: begin
                ay <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_AZ: begin
                az <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_BX: begin
                bx <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_BY: begin
                by <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_BZ: begin
                bz <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_CX: begin
                cx <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_CY: begin
                cy <= mem_read_data;
                mem_read_addr <= mem_read_addr+1;
            end
            S_FETCH_CZ: begin
                cz <= mem_read_data;
                colour <= mem_col_data;
                in_count <= in_count+1;
            end
            S_RESUME_FETCH: begin
                mem_read_addr <= mem_read_addr+1;
                ax <= bx;
                ay <= by;
                az <= bz;
                bx <= cx;
                by <= cy;
                bz <= cz;
            end
        endcase
    end

endmodule