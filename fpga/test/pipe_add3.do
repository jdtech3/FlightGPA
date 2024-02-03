vlib work

vlog ../src/utils/math/pipe_add3.v ../ip/float/float_add.v
vsim -L lpm_ver pipe_add3 -t 1ns

log {/*}
add wave {/*}

force {clock} 0, 1 10ns -r 20ns
force {clk_en} 1
force {aclr} 1, 0 20ns
run 20ns

force {in} 32'h3f800000, 32'h40000000 20ns, 32'h40400000 40ns, 32'h40800000 60ns, 32'h40a00000 80ns -r 100ns
run 2000ns