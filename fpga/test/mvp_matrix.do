vlib work

vlog src/graphics/mvp_matrix.sv src/utils/math/mat_mult4D.sv ip/float/float_sin.v ip/float/float_cos.v
vsim -default_radix decimal -L lpm_ver -L altera_mf_ver mvp_matrix -t 1ns

log {/*}
add wave {/*}
add wave {/mvp_matrix/m}
add wave {/mvp_matrix/v}

force {clock} 0, 1 5ns -r 10ns
force {reset} 1, 0 10ns

force {update_mvp} 1
force {speed} 32'h42c80000

# roll: pi/6
# pitch: pi/4
# yaw: pi/6
force {start} 0, 1 10ns, 0 20ns
force {roll} 32'h3f060a92
force {pitch} 32'h3f490fdb
force {yaw} 32'h3f060a92
force {x} 0
force {y} 0
force {z} 0
run 5000ns

# roll: 0
# pitch: 3*pi/2
# yaw: pi
# x: 100
# y: 20
# z: -30
force {start} 1, 0 10ns
force {roll} 0
force {pitch} 32'h4096cbe4
force {yaw} 32'h40490fdb
force {x} 32'h42c80000
force {y} 32'h41a00000
force {z} 32'hc1f00000
run 5000ns

# roll: pi/10
# pitch: pi/20
# yaw: pi/2
force {start} 1, 0 10ns
force {roll} 32'h3ea0d97c
force {pitch} 32'h3e20d97c
force {yaw} 32'h3fc90fdb
force {x} 0
force {y} 0
force {z} 0
run 5000ns

# force {start} 1, 0 10ns
# force {roll} 32'h3f490fdb
# force {pitch} 32'h3f060a92
# force {yaw} 32'h3f860a92
# force {x} 0
# force {y} 0
# force {z} 0
# run 5000ns

force {update_mvp} 0

# x: -100
# y: 100
# z: -500
force {start} 1, 0 10ns
force {x} 32'hC2C80000
force {y} 32'h42C80000
force {z} 32'hc3fa0000
run 1500ns
