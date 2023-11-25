vlib work

vlog ../src/utils/math.v ../ip/float/float_add.v
vsim -L lpm_ver pipe_add3 -t 1ns

log {/*}
add wave {/*}
# add wave {/pipe_add3/cycle_counter/*}

force {clock} 0, 1 10ns -r 20ns
force {clk_en} 1
force {aclr} 1, 0 20ns
run 20ns

force {in} 32'b01000000000000000000000000000000, 32'b01000000001100000000000000000000 20ns -r 40ns
run 2000ns