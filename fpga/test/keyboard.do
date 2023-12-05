vlib work

vlog src/control/keyboard.v
vsim keyboard -t 1ns

log {/*}
add wave {/*}

force {ps2_clock} 1
force {ps2_data} 1
force {areset} 0, 1 10ns, 0 20ns
run 40ns



force {ps2_clock} 0, 1 5ns -repeat 10ns -cancel 100ns
force {ps2_data} 0, 1 10ns, 1 20ns, 0 30ns, 1 40ns, 0 50ns, 1 60ns, 1 70ns, 1 80ns, 0 90ns, 1 100ns
run 100ns
force {ps2_clock} 1
run 50ns

# W
force {ps2_clock} 0, 1 5ns -repeat 10ns -cancel 100ns
force {ps2_data} 0, 1 10ns, 0 20ns, 1 30ns, 1 40ns, 1 50ns, 0 60ns, 0 70ns, 0 80ns, 0 90ns, 1 100ns
run 100ns
force {ps2_clock} 1
run 50ns

# break
force {ps2_clock} 0, 1 5ns -repeat 10ns -cancel 100ns
force {ps2_data} 0, 0 10ns, 0 20ns, 0 30ns, 0 40ns, 1 50ns, 1 60ns, 1 70ns, 1 80ns, 0 90ns, 1 100ns
run 100ns
force {ps2_clock} 1
run 50ns

force {ps2_clock} 0, 1 5ns -repeat 10ns -cancel 100ns
force {ps2_data} 0, 1 10ns, 0 20ns, 1 30ns, 1 40ns, 1 50ns, 0 60ns, 0 70ns, 0 80ns, 0 90ns, 1 100ns
run 100ns
force {ps2_clock} 1
run 50ns