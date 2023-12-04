// Helper: converts binary number up to 9999 into 4 digits (concatenated and output as single signal)
//         uses counter method for ease of implementation + speed doesn't matter here
module binary_to_4digits (
    input           clk,
    input           reset,
    input [15:0]    binary,
    
    output logic [15:0]   digits,
    output logic          done
);

    // --- Signals ---

    logic [15:0] counter;
    logic [15:0] tmp_digits;


    // --- Logic ---

    always_ff @ (posedge clk) begin
        if (reset) begin
            counter <= binary;
            tmp_digits <= 0;
            done <= 0;
        end
        else if (~done) begin
            if (counter == 0) begin
                done <= 1'b1;
                digits <= tmp_digits;
            end
            else begin
                counter <= counter - 1;

                if (tmp_digits[11:8] == 'd9 & tmp_digits[7:4] == 'd9 & tmp_digits[3:0] == 'd9) 
                    tmp_digits[15:12] <= (tmp_digits[15:12] == 'd9) ? 0 : tmp_digits[15:12] + 1;

                if (tmp_digits[7:4] == 'd9 & tmp_digits[3:0] == 'd9) 
                    tmp_digits[11:8] <= (tmp_digits[11:8] == 'd9) ? 0 : tmp_digits[11:8] + 1;

                if (tmp_digits[3:0] == 'd9) 
                    tmp_digits[7:4] <= (tmp_digits[7:4] == 'd9) ? 0 : tmp_digits[7:4] + 1;
                    
                tmp_digits[3:0] <= (tmp_digits[3:0] == 'd9) ? 0 : tmp_digits[3:0] + 1;
            end
        end
    end

endmodule
