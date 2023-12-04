vlib work

vlog \
    src/graphics/*.v \
    src/graphics/*.sv \
    src/utils/*.v \
    src/utils/math/*.v \
    src/utils/math/*.sv \
    src/vga_adapter/*.v \
    ip/block_ram/*.v \
    ip/float/*.v \
    test/*.v
vsim -default_radix unsigned -L lpm_ver -L altera_mf_ver draw_mesh_test -t 1ns

log {/*}
add wave {/*}
add wave {/draw_mesh_test/mp/*}
add wave {/draw_mesh_test/dtp/*}
add wave {/draw_mesh_test/pmc/*}

force {CLOCK_50} 0, 1 5ns -r 10ns
force {KEY} 2'b10, 2'b01 10ns, 2'b11 20ns

run 100000ns
