`timescale 1ps/1ps

// Helper: kinda debounces button by waiting for assert then deassert

module button_debouncer (
    input clk,
    input reset,
    
    input btn,
    output pulse
);

    // --- Signals ---

    typedef enum bit [3:0] { 
        IDLE, 
        WAIT_KEY_RELEASE,
        ASSERT_PULSE
    } state_t;

    state_t current_state;
    state_t next_state;

    // --- Logic ---

    always_comb begin
        case (current_state)
            IDLE:               next_state = btn ? WAIT_KEY_RELEASE : IDLE;
            WAIT_KEY_RELEASE:   next_state = ~btn ? ASSERT_PULSE : WAIT_KEY_RELEASE;
            ASSERT_PULSE:       next_state = IDLE;
            default:            next_state = IDLE;
        endcase
    end

    always_ff @ (posedge clk) current_state <= reset ? IDLE : next_state;

    assign pulse = current_state == ASSERT_PULSE;

endmodule
