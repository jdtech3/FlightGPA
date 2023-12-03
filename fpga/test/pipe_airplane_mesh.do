vlib work

vlog \
    ../src/graphics/*.v \
    ../src/graphics/*.sv \
    ../src/utils/*.v \
    ../src/utils/math/*.v \
    ../src/utils/math/*.sv \
    ../ip/block_ram/*.v \
    ../ip/float/*.v
vsim -default_radix unsigned -L altera_mf_ver -L lpm_ver pipe_airplane_mesh -t 1ns

log {/*}
add wave {/*}
add wave {/pipe_airplane_mesh/mvp_pipe_inst/*}
add wave {/pipe_airplane_mesh/airplane_mesh_isnt/*}
add wave {/pipe_airplane_mesh/mvp_output_inst/*}

force {clock} 0, 1 5ns -r 10ns
force {reset} 1, 0 10ns

force {update_mvp} 1

force {start} 0, 1 10ns, 0 20ns
force {roll} 0
force {pitch} 0
force {yaw} 0
force {x} 0
force {y} 0
force {z} 0
run 3200ns

force {update_mvp} 0

force {start} 0, 1 10ns, 0 20ns
run 10000ns
