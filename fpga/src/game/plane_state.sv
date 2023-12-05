/*

    File: plane_state.sv
    Author: Joe Dai
    Date: 2023

    This module stores and updates the plane's state every refresh period.

    Notes:
        - Relies on external module to convert speed, pitch, roll, heading into X, Y, Z velocities
          (and expects these to be already registered)
        - EVERYTHING is Q16.16 fixed point (if possible)
        - Signed overflow is NOT yet accounted for

*/

module plane_state #(
    parameter UPDATE_MS = 100,              // uint miliseconds interval between update
    parameter UPDATE_S = 32'h0000_199A,     // u fixed-p seconds interval between update (must be same as above!)
                                            // 0000_199A = 0.1
    parameter CLOCK_FREQUENCY = 166000000,

    parameter INITIAL_X = 32'sh0000_0000,
    parameter INITIAL_Y = 32'sh0064_0000,       // 0064_0000 = 100
    parameter INITIAL_Z = 32'sh0000_0000,
    parameter INITIAL_SPEED = 32'h0014_0000,    // 0014_0000 = 20
    parameter INITIAL_PITCH = 32'sh0000_0000,
    parameter INITIAL_ROLL = 32'sh0000_0000,
    parameter INITIAL_HEADING = 32'h0000_0000,

    parameter STALL_SPEED = 32'h0005_0000,              // [u fixed-p] if v < stall speed, pitch = -90 deg, v += 10/sec
                                                        // 0005_0000 = 5
    parameter DRAG_COEF = 32'sh0005_0000,               // [u fixed-p] drag = C_d * v^2
                                                        // 0005_0000 = 5
    parameter THRUST_COEF = 32'sh0064_0000,             // [u fixed-p] thrust = C_t * throttle%
                                                        // 0064_0000 = 100
    parameter MASS_INV = 32'sh0000_028F,                // [u fixed-p] reciprocal of mass for a = F/m calculation
                                                        // 0000_028F = 0.01
    parameter ROLL_TO_HEADING_CHANGE = 32'sh0001_0000,  // heading_change = C_rthc * roll;
                                                        // 0001_0000 = 1

    // The following are all supposed to be private localparams,
    // but Quartus Lite does not support localparams in parameter initialization list :/
    parameter DATA_WIDTH = 32,        // 16 bit effective!! due to fixed point
    parameter INPUT_WIDTH = 8
)
(
    input clk,
    input reset,

    // Control
    input update_enable,
    output logic update_done,
    output logic request_input,       // input controller polling
    input input_ready,
    output logic request_velocities,  // speed -> xyz velocity converter polling
    input velocities_ready,

    // Plane model input
    input signed [INPUT_WIDTH-1:0]  pitch_change,       // deg/sec
    input signed [INPUT_WIDTH-1:0]  roll_change,        // deg/sec
    input [INPUT_WIDTH-1:0]         throttle,           // 0-100%

    input signed [DATA_WIDTH-1:0]   v_x,    // from speed -> xyz velocity converter
    input signed [DATA_WIDTH-1:0]   v_y,
    input signed [DATA_WIDTH-1:0]   v_z,

    // Plane model state/output
    output logic signed [DATA_WIDTH-1:0]    x,          // right
    output logic signed [DATA_WIDTH-1:0]    y,          // up
    output logic signed [DATA_WIDTH-1:0]    z,          // into screen
    output logic [DATA_WIDTH-1:0]           speed,      // scalar, per sec
    output logic signed [DATA_WIDTH-1:0]    pitch,      // deg from -z CCW as viewed from +x
    output logic signed [DATA_WIDTH-1:0]    roll,       // deg from +y CCW as viewed from +z
    output logic [DATA_WIDTH-1:0]           heading,    // deg from -z CW as viewed from +y
                                                        // (0,0,0) angle is plane upright, flying towards -z
    output logic [2:0] plane_status_bits    // bitfield: {CRASHED, LANDED, FLYING}, all 0/multiple 1 is illegal
);

    // --- Enums ---

    typedef enum bit[15:0] {
        MODULE_IDLE,
        MODULE_POLL_INPUT,
        MODULE_WAIT_INPUT,
        MODULE_UPDATE_SPRH,
        MODULE_WRAP_ANGLES,
        MODULE_POLL_VELOCITIES,
        MODULE_WAIT_VELOCITIES,
        MODULE_UPDATE_XYZ,
        MODULE_UPDATE_PLANE_STATUS,
        MODULE_DONE
    } module_state_t;

    typedef enum bit[15:0] {
        PLANE_FLYING,
        PLANE_LANDED,
        PLANE_CRASHED
    } plane_status_t;

    // --- Signals ---

    // FSM
    module_state_t module_current_state;
    module_state_t module_next_state;

    // Plane state
    plane_status_t plane_status;

    // Control
    logic update;

    // Intermediates
    // NOTE/TODO: Currently assumes all parameters are positive for simplicity!

    // Heading change
    wire signed [DATA_WIDTH*2-1:0] heading_change_raw = ROLL_TO_HEADING_CHANGE * {{32{roll[31]}}, roll};   // Q32.32 deg/sec

    // Scaled acceleration taking into account update rate and mass
    wire signed [DATA_WIDTH*2-1:0] speed_squared_raw = {{32{speed[31]}}, speed} * {{32{speed[31]}}, speed};
    wire signed [DATA_WIDTH*2-1:0] force_raw = (THRUST_COEF * {throttle, 16'h0000}) - (DRAG_COEF * {{32{speed_squared_raw[47]}}, speed_squared_raw[47:16]});
    wire signed [DATA_WIDTH*2-1:0] accel_raw = {{32{force_raw[47]}}, force_raw[47:16]} * MASS_INV;
    wire signed [DATA_WIDTH*2-1:0] accel_scaled_raw = {{32{accel_raw[47]}}, accel_raw[47:16]} * UPDATE_S;  // Q32.32 m/s^2

    // Scaled angle change rate taking into account update rate
    wire signed [DATA_WIDTH*2-1:0] pitch_change_scaled_raw =   {{40{pitch_change[7]}}, pitch_change, 16'h0000} * UPDATE_S;
    wire signed [DATA_WIDTH*2-1:0] roll_change_scaled_raw =    {{40{roll_change[7]}}, roll_change, 16'h0000} * UPDATE_S;
    wire [DATA_WIDTH*2-1:0] heading_change_scaled_raw = {{32{heading_change_raw[47]}}, heading_change_raw[47:16]} * UPDATE_S;

    // Scaled velocity components taking into account update
    wire signed [DATA_WIDTH*2-1:0] v_x_scaled_raw = {{32{v_x[31]}}, v_x[31:0]} * UPDATE_S;
    wire signed [DATA_WIDTH*2-1:0] v_y_scaled_raw = {{32{v_y[31]}}, v_y[31:0]} * UPDATE_S;
    wire signed [DATA_WIDTH*2-1:0] v_z_scaled_raw = {{32{v_z[31]}}, v_z[31:0]} * UPDATE_S;

    // --- Logic ---

    // Main FSM
    always_comb begin
        case (module_current_state)
            MODULE_IDLE:                module_next_state = (update & update_enable & plane_status == PLANE_FLYING) ? MODULE_POLL_INPUT : MODULE_IDLE;
            MODULE_POLL_INPUT:          module_next_state = MODULE_WAIT_INPUT;
            MODULE_WAIT_INPUT:          module_next_state = input_ready ? MODULE_UPDATE_SPRH : MODULE_WAIT_INPUT;
            MODULE_UPDATE_SPRH:         module_next_state = MODULE_WRAP_ANGLES;
            MODULE_WRAP_ANGLES:         module_next_state = MODULE_POLL_VELOCITIES;
            MODULE_POLL_VELOCITIES:     module_next_state = MODULE_WAIT_VELOCITIES;
            MODULE_WAIT_VELOCITIES:     module_next_state = velocities_ready ? MODULE_UPDATE_XYZ : MODULE_WAIT_VELOCITIES;
            MODULE_UPDATE_XYZ:          module_next_state = MODULE_UPDATE_PLANE_STATUS;
            MODULE_UPDATE_PLANE_STATUS: module_next_state = MODULE_DONE;
            MODULE_DONE:                module_next_state = MODULE_IDLE;
        endcase
    end 

    always_ff @ (posedge clk) begin
        if (reset) begin
            module_current_state <= MODULE_IDLE;
            
            x <= INITIAL_X;
            y <= INITIAL_Y;
            z <= INITIAL_Z;
            speed <= INITIAL_SPEED;
            pitch <= INITIAL_PITCH;
            roll <= INITIAL_ROLL;
            heading <= INITIAL_HEADING;

            plane_status <= PLANE_FLYING;
        end
        else begin
            module_current_state <= module_next_state;
        
            case (module_current_state)
                MODULE_UPDATE_SPRH: begin
                    speed <= speed + accel_scaled_raw[47:16];
                    pitch <= pitch + pitch_change_scaled_raw[47:16];
                    roll <= roll + roll_change_scaled_raw[47:16];
                    heading <= heading + heading_change_scaled_raw[47:16];
                end
                MODULE_WRAP_ANGLES: begin
                    if (pitch > 'sh00B4_0000) pitch <= pitch - 'sh00B4_0000;            // 00B4_0000 = 180
                    else if (pitch < -'sh00B4_0000) pitch <= pitch + 'sh00B4_0000;

                    if (roll > 'sh00B4_0000) roll <= roll - 'sh00B4_0000;
                    else if (roll < -'sh00B4_0000) roll <= roll + 'sh00B4_0000; 
           
                    if (heading > 'hF000_0000) heading <= heading + 'h0168_0000;
                    else if (heading > 'h0168_0000) heading <= heading - 'h0168_0000;   // 0168_0000 = 360
                end
                MODULE_UPDATE_XYZ: begin
                    x <= x + v_x_scaled_raw[47:16];
                    y <= y + v_y_scaled_raw[47:16];
                    z <= z + v_z_scaled_raw[47:16];
                end
                MODULE_UPDATE_PLANE_STATUS: begin
                    // 0002_0000 = 2, 000A_0000 = 10
                    if (y < 'sh0002_0000) plane_status <= (speed > 'sh000A_0000) ? PLANE_CRASHED : PLANE_LANDED;
                end
            endcase
        end
    end

    always_comb begin
        request_input = module_current_state == MODULE_POLL_INPUT;
        request_velocities = module_current_state == MODULE_POLL_VELOCITIES;
        update_done = module_current_state == MODULE_DONE;
    end

    // Plane state to output bitfield conversion 
    always_comb begin
        case (plane_status)
            PLANE_FLYING: plane_status_bits = 3'b001;
            PLANE_LANDED: plane_status_bits = 3'b010;
            PLANE_CRASHED: plane_status_bits = 3'b100;
            default: plane_status_bits = 3'b111;
        endcase
    end

    // --- Modules ---

    pulse #(UPDATE_MS, CLOCK_FREQUENCY) pulse0 ( clk, reset, update );

endmodule
