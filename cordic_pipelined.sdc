# Quartus timing constraints for CORDIC RTL compile

create_clock -name clk -period 10.000 [get_ports clk]

derive_clock_uncertainty

# rst_n is an external asynchronous reset input.
set_false_path -from [get_ports rst_n]