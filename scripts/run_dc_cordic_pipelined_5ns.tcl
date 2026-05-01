# ============================================================
# Synopsys Design Compiler synthesis script
# Fully Pipelined Fixed-Point CORDIC Accelerator
# ============================================================

set TOP_MODULE cordic_pipelined

remove_design -all

file mkdir results

# ------------------------------------------------------------
# Read and elaborate RTL
# ------------------------------------------------------------
analyze -format sverilog {rtl/cordic_pipelined.sv}

elaborate $TOP_MODULE

current_design $TOP_MODULE

link

check_design > results/check_design_before_compile.rpt

# ------------------------------------------------------------
# Timing constraints
#
# Clock period for this synthesis sweep point.
# The exact period is set in the create_clock command below.
# ------------------------------------------------------------
create_clock -name clk -period 5.0 [get_ports clk]

set_clock_latency 0.3 [get_clocks clk]

# Apply input delay to all inputs except clock and reset.
set input_ports_no_clk_rst [remove_from_collection [all_inputs] [get_ports {clk rst_n}]]

set_input_delay 1.0 -clock clk $input_ports_no_clk_rst
set_output_delay 1.0 -clock clk [all_outputs]

# Basic load/fanout assumptions
set_load 0.1 [all_outputs]
set_max_fanout 8 [all_inputs]

# ------------------------------------------------------------
# Compile
# ------------------------------------------------------------
compile_ultra

check_design > results/check_design_after_compile.rpt

# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------
report_timing -max_paths 10 > results/timing_pipelined_5ns.rpt
report_area -hierarchy > results/area_pipelined_5ns.rpt
report_power -hierarchy > results/power_pipelined_5ns.rpt
report_constraint -all_violators > results/constraints_pipelined_5ns.rpt
report_qor > results/qor_pipelined_5ns.rpt
report_resources > results/resources_pipelined_5ns.rpt

# ------------------------------------------------------------
# Save outputs
# ------------------------------------------------------------
write -format verilog -hierarchy -output results/cordic_pipelined_netlist_5ns.v
write -format ddc -hierarchy -output results/cordic_pipelined_5ns.ddc

quit
