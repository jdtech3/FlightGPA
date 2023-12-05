vlib work

vlog ../src/utils/counter.v
vlog ../src/utils/pulse.v
vlog ../src/game/plane_state.sv
vsim plane_state -GCLOCK_FREQUENCY=1000 -t 100us

log {/*}
add wave {/*}

#        .clk(sys_clk), .reset(sys_reset),
#
#        .update_enable(plane_state_update_enable),
#        .update_done(plane_state_update_done),
#        .request_input(plane_state_request_input),        
#        .input_ready(plane_state_input_ready),
#        .request_velocities(plane_state_request_velocities),
#        .velocities_ready(plane_state_velocities_ready),
#        .pitch_change(pitch_change),
#        .roll_change(roll_change),
#        .throttle(throttle),
#        .v_x(plane_state_v_x),
#        .v_y(plane_state_v_y),
#        .v_z(plane_state_v_z),
#        .x(plane_state_x),
#        .y(plane_state_y),
#        .z(plane_state_z),
#        .speed(plane_state_speed),
#        .pitch(plane_state_pitch),
#        .roll(plane_state_roll),
#        .heading(plane_state_heading),
#        .plane_status_bits(plane_state_plane_status_bits)

force {clk} 0, 1 0.5ms -r 1ms

force {reset} 1
run 1ms
force {reset} 0
run 1ms

force {update_enable} 1
force {input_ready} 1
force {velocities_ready} 1

force {pitch_change} 'd0
force {roll_change} 'd0
force {throttle} 'd50
force {v_x} 'd0
force {v_y} 'd0
#force {v_z} {'h14}
force {v_z} {'hFFFFFFEC}
# v_z = -20

run 2000ms
