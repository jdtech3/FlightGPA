module mvp_pipe(
    input wire clock, reset, start, update_mvp,
    input wire [31:0] roll, pitch, yaw,
    input wire [31:0] x, y, z,
    input wire [31:0] count,
    output wire done,

    output reg [31:0] mesh_addr,
    input wire [31:0] mesh_data,

    input wire [31:0] result_addr,
    output wire [31:0] result_data

);

    localparam
        S_WAIT = 0,
        S_START_UPDATE_MVP = 1,
        S_UPDATE_MVP = 2,
        S_START_PIPE = 3,
        S_FETCH_X = 4,
        S_FETCH_Y = 5,
        S_FETCH_Z = 6,
        S_START_MVP_MULT = 7,
        S_MVP_MULT = 8,
        S_WRITE_X = 9,
        S_WRITE_Y = 10,
        S_WRITE_Z = 11,
        S_DELAY_UPDATE_MVP = 12,
        S_DELAY_MVP_MULT = 13,
        S_START_PIPE_DELAY = 14;

    reg [7:0] current_state, next_state;
    reg [31:0] mem_x, mem_y, mem_z;
    reg [31:0] in_count;
    wire [31:0] mvp_out [3:0][3:0];
    wire [31:0] mvp_ox, mvp_oy, mvp_oz;
    wire mvp_done;
    reg mvp_start;

    reg [31:0] mem_write_addr;
    reg [31:0] mem_write_data;
    reg mem_wren;

    assign done = current_state == S_WAIT;

    mvp_output mvp_output_inst(
        .clock(clock),
        .rdaddress(result_addr[6:0]),
        .q(result_data),
        .wraddress(mem_write_addr[6:0]),
        .data(mem_write_data),
        .wren(mem_wren)
    );

    mvp_matrix mvp_mat_inst(
        .clock(clock),
        .reset(reset),
        .start(mvp_start),
        .update_mvp(update_mvp),
        .roll(roll),
        .pitch(pitch),
        .yaw(yaw),
        .x(mem_x), 
        .y(mem_y),
        .z(mem_z),
        .o(mvp_out),
        .ox(mvp_ox),
        .oy(mvp_oy),
        .oz(mvp_oz),
        .done(mvp_done)
    );

    always @(*) begin
        case(current_state)
            S_WAIT:             next_state <= start ? (update_mvp ? S_START_UPDATE_MVP : S_START_PIPE) : S_WAIT;
            S_START_UPDATE_MVP: next_state <= S_DELAY_UPDATE_MVP;
            S_DELAY_UPDATE_MVP: next_state <= S_UPDATE_MVP;
            S_UPDATE_MVP:       next_state <= mvp_done ? S_WAIT: S_UPDATE_MVP;
            S_START_PIPE:       next_state <= S_START_PIPE_DELAY;
            S_START_PIPE_DELAY: next_state <= S_FETCH_X;
            S_FETCH_X:          next_state <= S_FETCH_Y;
            S_FETCH_Y:          next_state <= S_FETCH_Z;
            S_FETCH_Z:          next_state <= S_START_MVP_MULT;
            S_START_MVP_MULT:   next_state <= S_DELAY_MVP_MULT;
            S_DELAY_MVP_MULT:   next_state <= S_MVP_MULT;
            S_MVP_MULT:         next_state <= mvp_done ? S_WRITE_X : S_MVP_MULT;
            S_WRITE_X:          next_state <= S_WRITE_Y;
            S_WRITE_Y:          next_state <= S_WRITE_Z;
            S_WRITE_Z:          next_state <= in_count == count ? S_WAIT : S_START_PIPE_DELAY;
        endcase
    end

    always @(posedge clock) begin

		if(reset) current_state <= S_WAIT;
		else current_state <= next_state;

        mvp_start <= 1'b0;
        mem_wren <= 1'b0;
        case(current_state)
            S_START_UPDATE_MVP: begin
                mem_x <= x;
                mem_y <= y;
                mem_z <= z;
                mvp_start <= 1'b1;
            end
            S_START_PIPE: begin
                mesh_addr <= 0;
                mem_write_addr <= -1;
                in_count <= 0;
            end
            S_START_PIPE_DELAY:
                mesh_addr <= mesh_addr+1;
            S_FETCH_X: begin
                mem_x <= mesh_data;
                mesh_addr <= mesh_addr+1;
            end
            S_FETCH_Y: begin
                mem_y <= mesh_data;
                mesh_addr <= mesh_addr+1;
            end
            S_FETCH_Z: begin
                mem_z <= mesh_data;
            end
            S_START_MVP_MULT: begin
                in_count <= in_count + 1;
                mvp_start <= 1;
            end
            S_WRITE_X: begin
                mem_wren <= 1'b1;
                mem_write_addr <= mem_write_addr+1;
                mem_write_data <= mvp_ox; // mvp_out[0][0];
            end
            S_WRITE_Y: begin
                mem_wren <= 1'b1;
                mem_write_addr <= mem_write_addr+1;
                mem_write_data <= mvp_oy; // mvp_out[1][0];
            end
            S_WRITE_Z: begin
                mem_wren <= 1'b1;
                mem_write_addr <= mem_write_addr+1;
                mem_write_data <= mvp_oz; // mvp_out[2][0];
            end
        endcase

    end

endmodule