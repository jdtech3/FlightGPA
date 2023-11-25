vlib work

vlog ../ip/float/float_mult.v
vsim -L lpm_ver float_mult -t 1ns

log {/*}
add wave {/*}

force {clock} 0, 1 10ns -r 20ns
force {clk_en} 1
force {aclr} 0

force {dataa} 32'b01000000000000000000000000000000, 32'b01000000001100000000000000000000 20ns -r 40ns
force {datab} 32'b01000001001000000000000000000000, 32'b01000010000010000000000000000000 20ns -r 40ns
run 200ns