vlib work

vlog ../src/utils/math.v ../ip/float/float_add.v ../ip/float/float_mult.v ../src/utils/counter.v
vsim -L lpm_ver mat_vec_mult3D -t 1ns

log {/*}
add wave {/*}

force {clock} 0, 1 10ns -r 20ns
force {reset} 1, 0 20ns
force {start} 0, 1 20ns, 0 40ns, 1 780ns, 0 800ns

force {m11} 32'h3f800000, 32'h3f800000 780ns
force {m12} 32'h40800000, 32'h3f800000 780ns
force {m13} 32'h40e00000, 32'h3f800000 780ns
force {m21} 32'h40000000, 32'h3f800000 780ns
force {m22} 32'h40a00000, 32'h3f800000 780ns
force {m23} 32'h41000000, 32'h3f800000 780ns
force {m31} 32'h40400000, 32'h3f800000 780ns
force {m32} 32'h40c00000, 32'h3f800000 780ns
force {m33} 32'h41100000, 32'h3f800000 780ns

force {v1} 32'h41200000, 32'h3f800000 780ns
force {v2} 32'h41300000, 32'h3f800000 780ns
force {v3} 32'h41400000, 32'h3f800000 780ns
run 3000ns