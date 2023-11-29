vlib work

vlog ../src/utils/math/mat_mult4D.sv ../src/utils/math/pipe_dot4D.v ../src/utils/math/pipe_add4.v ../ip/float/float_add.v ../ip/float/float_mult.v ../src/utils/counter.v
vsim -L lpm_ver mat_mult4D -t 1ns

log {/*}
add wave {/*}
add wave {/mat_mult4D/o}

force {clock} 0, 1 10ns -r 20ns
force {reset} 1, 0 20ns
force {start} 0, 1 20ns, 0 40ns, 1 1000ns, 0 1020ns, 1 2000ns, 0 2020ns
force {mult_vec} 1, 0 2000ns

force {m[0][0]} 32'h3f800000, 32'h3f800000 1000ns, 32'h40800000 2000ns
force {m[0][1]} 32'h40800000, 32'h3f800000 1000ns, 32'h40a00000 2000ns
force {m[0][2]} 32'h40e00000, 32'h3f800000 1000ns, 32'h41100000 2000ns
force {m[0][3]} 32'h00000000, 32'h3f800000 1000ns, 32'h40000000 2000ns
force {m[1][0]} 32'h40000000, 32'h3f800000 1000ns, 32'h40000000 2000ns
force {m[1][1]} 32'h40a00000, 32'h3f800000 1000ns, 32'h40e00000 2000ns
force {m[1][2]} 32'h41000000, 32'h3f800000 1000ns, 32'h40e00000 2000ns
force {m[1][3]} 32'h00000000, 32'h3f800000 1000ns, 32'h41100000 2000ns
force {m[2][0]} 32'h40400000, 32'h3f800000 1000ns, 32'h40e00000 2000ns
force {m[2][1]} 32'h40c00000, 32'h3f800000 1000ns, 32'h00000000 2000ns
force {m[2][2]} 32'h41100000, 32'h3f800000 1000ns, 32'h3f800000 2000ns
force {m[2][3]} 32'h00000000, 32'h3f800000 1000ns, 32'h41000000 2000ns
force {m[3][0]} 32'h00000000, 32'h3f800000 1000ns, 32'h40800000 2000ns
force {m[3][1]} 32'h00000000, 32'h3f800000 1000ns, 32'h41000000 2000ns
force {m[3][2]} 32'h00000000, 32'h3f800000 1000ns, 32'h40c00000 2000ns
force {m[3][3]} 32'h3f800000, 32'h3f800000 1000ns, 32'h40c00000 2000ns

force {v[0][0]} 32'h41200000, 32'h3f800000 1000ns, 32'h3f800000 2000ns
force {v[1][0]} 32'h41300000, 32'h3f800000 1000ns, 32'h41400000 2000ns
force {v[2][0]} 32'h41400000, 32'h3f800000 1000ns, 32'h3f800000 2000ns
force {v[3][0]} 32'h3f800000, 32'h3f800000 1000ns, 32'h41200000 2000ns

force {v[0][1]} 32'h41200000 2000ns
force {v[1][1]} 32'h41300000 2000ns
force {v[2][1]} 32'h41400000 2000ns
force {v[3][1]} 32'h3f800000 2000ns
force {v[0][2]} 32'h41200000 2000ns
force {v[1][2]} 32'h41300000 2000ns
force {v[2][2]} 32'h41400000 2000ns
force {v[3][2]} 32'h3f800000 2000ns
force {v[0][3]} 32'h41200000 2000ns
force {v[1][3]} 32'h41300000 2000ns
force {v[2][3]} 32'h41400000 2000ns
force {v[3][3]} 32'h3f800000 2000ns
run 4000ns