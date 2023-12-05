/*

    File: plane_state.sv
    Author: Joe Dai
    Date: 2023

    This module stores and updates the plane's state every refresh period.

    Notes:
        - Relies on external module to convert speed, pitch, roll, heading into X, Y, Z velocities
          (and expects these to be already registered)
        - Most things are signed int, and only uses fixed point when strictly necessary, so not very precise
        - Signed int overflow is NOT yet accounted for

*/

module plane_state #(
    parameter UPDATE_MS = 100,              // uint miliseconds interval between update
    parameter UPDATE_S = 32'h0000199A,      // u fixed-p seconds interval between update (must be same as above!)
    parameter CLOCK_FREQUENCY = 166000000,

    parameter INITIAL_X = 0,
    parameter INITIAL_Y = 100,
    parameter INITIAL_Z = 0,
    parameter INITIAL_SPEED = 50,
    parameter INITIAL_PITCH = 0,
    parameter INITIAL_ROLL = 0,
    parameter INITIAL_HEADING = 0,

    parameter STALL_SPEED = 15,             // [uint] if v < stall speed, pitch = -90 deg, v += 10/sec
    parameter DRAG_COEF = 1,                // [uint] drag = C_d * v^2
    parameter THRUST_COEF = 100,            // [uint] thrust = C_t * throttle%
    parameter MASS_INV = 32'h0000028F,      // [u fixed-p] reciprocal of mass for a = F/m calculation
    parameter ROLL_TO_HEADING_CHANGE = 1,   // heading_change = C_rthc * roll;

    // The following are all supposed to be private localparams,
    // but Quartus Lite does not support localparams in parameter initialization list :/
    parameter COORD_WIDTH = 32,         // x, y, z  (16 bit effective!! due to fixed point width)
    parameter ANGLE_WIDTH = 16,         // pitch, roll, heading
    parameter FIXED_POINT_WIDTH = 48    // fixed point are all 16.16 (16 bit) format
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
    input signed [ANGLE_WIDTH-1:0]  pitch_change,       // deg/sec
    input signed [ANGLE_WIDTH-1:0]  roll_change,        // deg/sec
    input [7:0]                     throttle,           // 0-100%

    input signed [COORD_WIDTH-1:0]  v_x,    // from speed -> xyz velocity converter
    input signed [COORD_WIDTH-1:0]  v_y,
    input signed [COORD_WIDTH-1:0]  v_z,

    // Plane model state/output
    output logic signed [COORD_WIDTH-1:0]   x,          // right
    output logic signed [COORD_WIDTH-1:0]   y,          // up
    output logic signed [COORD_WIDTH-1:0]   z,          // into screen
    output logic [COORD_WIDTH-1:0]          speed,      // scalar, per sec
    output logic signed [ANGLE_WIDTH-1:0]   pitch,      // deg from -z CCW as viewed from +x
    output logic signed [ANGLE_WIDTH-1:0]   roll,       // deg from +y CCW as viewed from +z
    output logic [ANGLE_WIDTH-1:0]          heading,    // deg from -z CW as viewed from +y
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

    // Heading change
    wire signed [ANGLE_WIDTH-1:0]  heading_change = ROLL_TO_HEADING_CHANGE * roll;     // deg/sec

    // Scaled acceleration taking into account update rate and mass
    wire signed [COORD_WIDTH-1:0]  force_raw = (THRUST_COEF * throttle) - (DRAG_COEF * speed * speed);  // may truncate
    wire signed [FIXED_POINT_WIDTH*2-1:0] accel_raw = {force_raw, 16'h0000} * MASS_INV;
    wire signed [FIXED_POINT_WIDTH*2-1:0] accel_scaled_raw = {accel_raw[95], accel_raw[62:32]} * UPDATE_S;
    wire signed [COORD_WIDTH-1:0] accel_scaled = {accel_scaled_raw[95], accel_scaled_raw[62:32]};

    // Scaled angle change rate taking into account update rate
    wire signed [FIXED_POINT_WIDTH*2-1:0] pitch_change_scaled_raw =   {pitch_change, 16'h0000} * UPDATE_S;
    wire signed [FIXED_POINT_WIDTH*2-1:0] roll_change_scaled_raw =    {roll_change, 16'h0000} * UPDATE_S;
    wire signed [FIXED_POINT_WIDTH*2-1:0] heading_change_scaled_raw = {heading_change, 16'h0000} * UPDATE_S;
    wire signed [ANGLE_WIDTH-1:0] pitch_change_scaled =    {pitch_change_scaled_raw[95], pitch_change_scaled_raw[46:32]};      // drop fractional and most significant parts
    wire signed [ANGLE_WIDTH-1:0] roll_change_scaled =     {roll_change_scaled_raw[95], roll_change_scaled_raw[46:32]};        // TODO: round instead of trucate
    wire signed [ANGLE_WIDTH-1:0] heading_change_scaled =  {heading_change_scaled_raw[95], heading_change_scaled_raw[46:32]};

    // Scaled velocity components taking into account update
    wire signed [FIXED_POINT_WIDTH*2-1:0] v_x_scaled_raw = {v_x, 16'h0000} * UPDATE_S;
    wire signed [FIXED_POINT_WIDTH*2-1:0] v_y_scaled_raw = {v_y, 16'h0000} * UPDATE_S;
    wire signed [FIXED_POINT_WIDTH*2-1:0] v_z_scaled_raw = {{32{v_z[15]}}, v_z[15:0], 16'h0000} * UPDATE_S;
    wire signed [COORD_WIDTH-1:0] v_x_scaled = {v_x_scaled_raw[95], v_x_scaled_raw[62:32]};    // drop fractional and most significant parts
    wire signed [COORD_WIDTH-1:0] v_y_scaled = {v_y_scaled_raw[95], v_y_scaled_raw[62:32]};    // TODO: round instead of trucate
    wire signed [COORD_WIDTH-1:0] v_z_scaled = v_z_scaled_raw[63:32];

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
                    speed <= speed + accel_scaled;
                    pitch <= pitch + pitch_change_scaled;
                    roll <= roll + roll_change_scaled;
                    heading <= heading + heading_change_scaled;
                end
                MODULE_WRAP_ANGLES: begin
                    if (pitch > 'sd180) pitch <= pitch - 'sd180;
                    else if (pitch < -'sd180) pitch <= pitch + 'sd180;

                    if (roll > 'sd180) roll <= roll - 'sd180;
                    else if (roll < -'sd180) roll <= roll + 'sd180; 
           
                    if (heading > 'd360) heading <= heading - 'd360;
                end
                MODULE_UPDATE_XYZ: begin
                    x <= x + v_x_scaled;
                    y <= y + v_y_scaled;
                    z <= z + v_z_scaled;
                end
                MODULE_UPDATE_PLANE_STATUS: begin
                    if (y < 'sd2) plane_status <= (speed > 'd25) ? PLANE_CRASHED : PLANE_LANDED;
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
