vlib work

vlog ../ip/float/float_cos.v
vsim -L lpm_ver float_cos -t 1ns

log {/*}
add wave {/*}

force {clock} 0, 1 10ns -r 20ns
force {clk_en} 1
force {aclr} 0
run 20ns

force {data} 32'h00000000, 32'h3f060a92 800ns, 32'h3f490fdb 1600ns, 32'h3f860a92 2400ns, 32'h3fc90fdb 3200ns
run 4000ns
