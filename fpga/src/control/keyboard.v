module keyboard(
    input wire ps2_clock, ps2_data,
    input wire areset,

    output reg W, A, S, D, Q, E
);

    reg [10:0] in_shift_reg;
    reg [7:0] key;
    reg [3:0] in_count;
    wire key_in;
    reg break;
    wire key_set_value;

    assign key_in = in_count == 4'd11;
    assign key_set_value = ~break;

    always @(negedge ps2_clock or posedge areset) begin
        if(areset) begin
            in_shift_reg <= 11'd0;
            key <= 8'd0;
            in_count <= 4'd0;
        end
        else begin
            in_shift_reg <= (in_shift_reg >> 1) | {ps2_data, 10'd0};
            if(key_in) in_count <= 4'd1;
            else in_count <= in_count+1;
        end
    end

    always @(posedge key_in or posedge areset) begin
        if(areset) begin
            key = 8'd0;
            W <= 1'b0;
            A <= 1'b0;
            S <= 1'b0;
            D <= 1'b0;
            Q <= 1'b0;
            E <= 1'b0;
        end
        else begin
            key = in_shift_reg[8:1];
            if(key == 8'hF0) break <= 1;
            else begin
                case(key)
                    8'h1D: W <= key_set_value;
                    8'h1C: A <= key_set_value;
                    8'h1B: S <= key_set_value;
                    8'h23: D <= key_set_value;
                    8'h15: Q <= key_set_value;
                    8'h24: E <= key_set_value;
                endcase
                break <= 0;
            end
        end
    end

endmodule