module pipe_mesh_controller(
    input clock, reset, start,
    // input wire [31:0] roll, pitch, yaw,
    // input wire [31:0] x, y, z,
    output wire done,

    // output wire [31:0] mesh_addr,
    // input wire [31:0] mesh_data,

    output wire mvp_pipe_start,
    output wire mvp_pipe_update_mvp,
    input wire mvp_pipe_done,
    // input reg [31:0] mvp_pipe_mesh_addr,
    // output wire [31:0] mvp_pipe_mesh_data,

    output wire draw_tri_pipe_start,
    input wire draw_tri_pipe_done
);

    localparam
        S_WAIT              = 8'd0,
        S_START_UPDATE_MVP  = 8'd1,
        S_WAIT_UPDATE_MVP   = 8'd2,
        S_START_MVP_PIPE    = 8'd3,
        S_WAIT_MVP_PIPE     = 8'd4,
        S_START_DRAW_PIPE   = 8'd5,
        S_WAIT_DRAW_PIPE    = 8'd5;

    reg [7:0] current_state, next_state;

    // wire draw_pipe_done;

    // wire [31:0] mvp_pipe_res_addr;
    // wire [31:0] mvp_pipe_res_data;

    assign done = current_state == S_WAIT;

    // airplane_mesh airplane_mesh_isnt(
    //     .clock(clock),
    //     .address(mvp_pipe_mesh_addr[4:0]),
    //     .q(mvp_pipe_mesh_data)
    // );

    // mvp_pipe mvp_pipe_inst(
    //     .clock(clock),
    //     .reset(reset),
    //     .start(current_state == S_START_UPDATE_MVP || current_state == S_START_MVP_PIPE),
    //     .update_mvp(current_state == S_WAIT || current_state == S_START_UPDATE_MVP || current_state == S_WAIT_UPDATE_MVP),
    //     .roll(roll),
    //     .pitch(pitch),
    //     .yaw(yaw),
    //     .x(x),
    //     .y(y),
    //     .z(z),
    //     .count(32'd2),
    //     .done(mvp_pipe_done),

    //     .mesh_addr(mesh_addr),
    //     .mesh_data(mesh_data),

    //     .result_addr(mvp_pipe_res_addr),
    //     .result_data(mvp_pipe_res_data),
    // );
    assign mvp_pipe_start = current_state == S_START_UPDATE_MVP || current_state == S_START_MVP_PIPE;
    assign mvp_pipe_update_mvp = current_state == S_WAIT || current_state == S_START_UPDATE_MVP || current_state == S_WAIT_UPDATE_MVP;

    assign draw_tri_pipe_start = current_state == S_START_DRAW_PIPE;

    // wire GND;
    // assign GND = 1'b0;

    // draw_triangle_pipe #(
    //     .COLOUR_WIDTH(3),
    //     .WIDTH(32))
    // draw_tri_pipe_inst(
    //     .clock(clock),
    //     .reset(reset),
    //     .start(current_state == S_START_DRAW),
    //     .strip(1'b1),
    //     .count(32'd2),
    //     .done(draw_pipe_done),
    //     .mem_read_addr(mvp_pipe_res_addr),
    //     .mem_read_data(mvp_pipe_res_data),
    //     .mem_col_addr(GND),
    //     .mem_col_data(1'b111),

    //     .ax(ax), .ay(ay), .az(GND),
    //     .bx(bx), .by(by), .bz(GND),
    //     .cx(cx), .cy(cy), .cz(GND),
    //     .draw_en(),
    //     .draw_done());

    // draw_triangle #(
    //     .COLOUR_WIDTH(3),
    //     .WIDTH(32))
    // dr_tri_inst(
        
    // );

    always @(*) begin
        case(current_state)
            S_WAIT:             next_state <= start ? S_START_UPDATE_MVP : S_WAIT;
            S_START_UPDATE_MVP: next_state <= S_WAIT_UPDATE_MVP;
            S_WAIT_UPDATE_MVP:  next_state <= mvp_pipe_done ? S_START_MVP_PIPE : S_WAIT_UPDATE_MVP;
            S_START_MVP_PIPE:   next_state <= S_WAIT_MVP_PIPE;
            S_WAIT_MVP_PIPE:    next_state <= mvp_pipe_done ? S_START_DRAW_PIPE : S_WAIT_MVP_PIPE;
            S_START_DRAW_PIPE:  next_state <= S_WAIT_DRAW_PIPE;
            S_WAIT_DRAW_PIPE:   next_state <= draw_tri_pipe_done ? S_WAIT : S_WAIT_DRAW_PIPE;
        endcase
    end

    always @(posedge clock) begin
        if(reset) current_state <= S_WAIT;
        else current_state <= next_state;
    end



endmodule