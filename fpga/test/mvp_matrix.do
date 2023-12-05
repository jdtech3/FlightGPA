vlib work

vlog src/graphics/mvp_matrix.sv src/utils/math/mat_mult4D.sv ip/float/float_sin.v ip/float/float_cos.v ip/float/int_to_float.v
vsim -default_radix decimal -L lpm_ver -L altera_mf_ver mvp_matrix -t 1ns

log {/*}
add wave {/*}
add wave {/mvp_matrix/m}
add wave {/mvp_matrix/v}

force {clock} 0, 1 5ns -r 10ns
force {reset} 1, 0 10ns

force {update_mvp} 1
force {speed} 100

force {start} 0, 1 10ns, 0 20ns
force {roll} 30
force {pitch} 45
force {yaw} 30
force {x} 0
force {y} 0
force {z} 0
run 5000ns

force {start} 1, 0 10ns
force {roll} 0
force {pitch} 270
force {yaw} 180
force {x} 100
force {y} 20
force {z} -30
run 5000ns

force {start} 1, 0 10ns
force {roll} 18
force {pitch} 9
force {yaw} 90
force {x} 0
force {y} 0
force {z} 0
run 5000ns

force {update_mvp} 0

# x: -100
# y: 100
# z: -500
force {start} 1, 0 10ns
force {x} 32'hC2C80000
force {y} 32'h42C80000
force {z} 32'hc3fa0000
run 1500ns
