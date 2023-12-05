vlib work

vlog ../src/utils/button_debouncer.sv
vsim button_debouncer -t 1ns

log {/*}
add wave {/*}

#    input clk,
#    input reset,
#    input btn,
#    output pulse

force {clk} 0, 1 5ns -r 10ns

force {reset} 1
run 10ns
force {reset} 0
run 10ns

force {btn} 1
run 153ns
force {btn} 0
run 10ns

force {btn} 1
run 43ns
force {btn} 0
run 10ns

force {btn} 1
run 39ns
force {btn} 0
run 10ns
