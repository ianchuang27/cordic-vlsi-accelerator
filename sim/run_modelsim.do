# ModelSim RTL simulation script for CORDIC project

transcript file results/modelsim_rtl_sim.log

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv rtl/cordic_pipelined.sv
vlog -sv tb/tb_cordic_pipelined.sv

vsim work.tb_cordic_pipelined

run -all

quit -f