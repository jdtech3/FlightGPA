vlib work

vlog ../src/utils/binary_to_4digits.sv
vsim binary_to_4digits -t 1ns

log {/*}
add wave {/*}

#    input           clk,
#    input           reset,
#    input [15:0]    binary,
#    output [15:0]   digits,
#    output          done

force {clk} 0, 1 5ns -r 10ns

force {reset} 1
force {binary} 'd0
run 10ns
force {reset} 0
run 10ns

force {reset} 1
force {binary} 'd100
run 10ns
force {reset} 0
run 1500ns

force {reset} 1
force {binary} 'd360
run 10ns
force {reset} 0
run 4000ns

force {reset} 1
force {binary} 'd999
run 10ns
force {reset} 0
run 10000ns
