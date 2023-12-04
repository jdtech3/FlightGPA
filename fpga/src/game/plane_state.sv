/*

    File: plane_state.sv
    Author: Joe Dai
    Date: 2023

    This module stores and updates the plane's state every refresh period.

    Notes:
        - Fixed point are all 32.16 (48 bit) format
*/

module plane_state #(
    parameter UPDATE_MS = 100,              // uint miliseconds interval between update
    parameter UPDATE_S = 48'h000000199A,    // fixed-p seconds interval between update (must be same as above!)
    parameter CLOCK_FREQUENCY = 166000000,

    parameter COORD_WIDTH = 32,     // x, y, z
    parameter ANGLE_WIDTH = 16,     // pitch, roll, heading

    parameter INITIAL_PITCH = 0,
    parameter INITIAL_ROLL = 0,
    parameter INITIAL_HEADING = 0,
    parameter INITIAL_X = 0,
    parameter INITIAL_Y = 0,
    parameter INITIAL_Z = 0,

    parameter STALL_SPEED = 20,             // [uint] if v < stall speed, pitch = -90 deg, v += 10/sec
    parameter DRAG_COEF = 5,                // [uint] drag = C_d * v^2
    parameter THRUST_COEF = 100,            // [uint] thrust = C_t * throttle%
    paraemter MASS_INV = 48'h000000028F     // [u fixed-p] reciprocal of mass for a = F/m calculation
)
(
    input clk,
    input reset,

    // Control
    input update_enable,
    output update_done,

    // Plane model input
    input [ANGLE_WIDTH-1:0]     pitch_change,       // deg/sec
    input [ANGLE_WIDTH-1:0]     roll_change,        // deg/sec
    input [ANGLE_WIDTH-1:0]     heading_change,     // deg/sec
    input [7:0]                 throttle,           // 0-100%

    // Plane model state/output
    output logic [COORD_WIDTH-1:0]  x,          // right
    output logic [COORD_WIDTH-1:0]  y,          // up
    output logic [COORD_WIDTH-1:0]  z,          // into screen
    output logic [COORD_WIDTH-1:0]  speed,      // scalar
    output logic [ANGLE_WIDTH-1:0]  pitch,      // deg from -z CCW as viewed from +x
    output logic [ANGLE_WIDTH-1:0]  roll,       // deg from +y CCW as viewed from +z
    output logic [ANGLE_WIDTH-1:0]  heading,    // deg from -z CW as viewed from +y
                                                // (0,0,0) angle is plane upright, flying towards -z
    output [2:0] plane_state_bits               // bitfield: {CRASHED, LANDED, FLYING}, all 0/multiple 1 is illegal
);

    // --- Enums ---

    typedef enum bit[15:0] {
        MODULE_IDLE,
        MODULE_START,
        MODULE_WAIT_INPUT,
        MODULE_WAIT_VELOCITIES,
        MODULE_DONE
    } module_state_t;

    typedef enum bit[15:0] {
        PLANE_FLYING,
        PLANE_LANDED,
        PLANE_CRASHED
    } plane_state_t;

    // --- Signals ---

    // FSM
    module_state_t module_current_state;
    module_state_t module_next_state;

    // Plane state
    plane_state_t plane_state;

    // Control
    logic update;

    // Intermediates
    logic [COORD_WIDTH-1:0] v_x,
    logic [COORD_WIDTH-1:0] v_y,
    logic [COORD_WIDTH-1:0] v_z,

    // --- Logic ---

    // Main FSM
    always_comb begin
        case (module_current_state)
            MODULE_IDLE:    module_next_state = (start & update_enable) ? MODULE_START : MODULE_IDLE;
        endcase
    end 

    always_ff @ (posedge clk) begin
        module_current_state <= reset ? MODULE_IDLE : module_next_state;
    end

    always_comb begin
        update_done = module_current_state == MODULE_DONE;
    end

    // Plane state to output bitfield conversion 
    always_comb begin
        case (plane_state)
            PLANE_FLYING: plane_state_bits = 3'b001;
            PLANE_LANDED: plane_state_bits = 3'b010;
            PLANE_CRASHED: plane_state_bits = 3'b100;
            default: plane_state_bits = 3'b111;
        endcase
    end

endmodule
