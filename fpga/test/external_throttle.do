vlib work

vlog ../src/utils/counter.v
vlog ../src/utils/pulse.v
vlog ../src/io/external_throttle.sv
vsim external_throttle -GCLOCK_FREQUENCY=1000 -t 100us

log {/*}
add wave {/*}

#    input clk,
#    input reset,
#    input [3:0]         gpio,
#    output logic [7:0]  throttle

force {clk} 0, 1 0.5ms -r 1ms

force {reset} 1
run 1ms
force {reset} 0
run 1ms

force {gpio} 'd2
run 125ms

force {gpio} 'd8
run 125ms

force {gpio} 'hF
run 125ms
