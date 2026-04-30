# ============================================================
# Quick Design Compiler syntax/elaboration check for CORDIC
# ============================================================

set TOP_MODULE cordic_pipelined

remove_design -all

file mkdir results

analyze -format sverilog {rtl/cordic_pipelined.sv}
elaborate $TOP_MODULE
current_design $TOP_MODULE
link

check_design > results/check_design_quick.rpt

report_design > results/report_design_quick.rpt

quit
