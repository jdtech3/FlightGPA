vlib work

vlog ../src/graphics/orientation_matrix.v ../src/utils/math/mat_mult4D.v ../ip/float/float_sin.v ../ip/float/float_cos.v
vsim -L lpm_ver orientation_matrix -t 1ns

log {/*}
add wave {/*}

force {clock} 0, 1 10ns -r 20ns
force {reset} 1, 0 20ns

force {start} 0, 1 20ns, 0 40ns, 1 4500ns, 0 4520ns
force {roll} 32'h3f060a92, 32'h3ea0d97c 4500ns
force {pitch} 32'h3f490fdb, 32'h3e20d97c 4500ns
force {yaw} 32'h3f060a92, 32'h3fc90fdb 4500ns
force {x} 0
force {y} 0
force {z} 0
run 10000ns

# force {start} 0, 1 20ns, 0 40ns, 1 1000ns, 0 1020ns, 1 2000ns, 0 2020ns, 1 3000ns, 0 3020ns, 1 4000ns, 0 4020ns
# force {angle} 32'h00000000, 32'h3f060a92 1000ns, 32'h3f490fdb 2000ns, 32'h3f860a92 3000ns, 32'h3fc90fdb 4000ns
