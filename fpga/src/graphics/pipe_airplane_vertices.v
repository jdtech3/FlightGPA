module pipe_airplane_vertices(
    input clock, reset, start, update_mvp,
    input wire [31:0] roll, pitch, yaw,
    input wire [31:0] x, y, z,
    output wire done
);
    wire [31:0] mesh_addr;
    wire [31:0] mesh_data;

    wire [31:0] mvp_data;
    // wire [31:0] mvp_q;
    wire [31:0] mvp_write_addr;
    // wire [31:0] mvp_read_addr;
    wire mvp_wren;

    airplane_mesh airplane_mesh_isnt(
        .clock(clock),
        .address(mesh_addr[4:0]),
        .q(mesh_data)
    );

    mvp_output mvp_output_inst(
        .clock(clock),
        .data(mvp_data),
        // .rdaddress(mvp_read_addr[6:0]),
        // .q(mvp_q),
        .wraddress(mvp_write_addr[6:0]),
        .wren(mvp_wren)
    );

    pipe_vertices pipe_vertices_inst(
        .clock(clock),
        .reset(reset),
        .start(start),
        .update_mvp(update_mvp),
        .roll(roll),
        .pitch(pitch),
        .yaw(yaw),
        .x(x), 
        .y(y),
        .z(z),
        .count(32'd2),
        .done(done),

        .mem_read_addr(mesh_addr),
        .mem_read_data(mesh_data),

        .mem_write_addr(mvp_write_addr),
        .mem_write_data(mvp_data),
        .mem_wren(mvp_wren)
    );

endmodule