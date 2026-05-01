# Fixed-Point Pipelined CORDIC Accelerator

## Project Overview

This project implements a fixed-point CORDIC accelerator for sine and cosine computation. CORDIC is useful for VLSI digital signal processing because it computes trigonometric functions using shifts, additions, subtractions, registers, and a small lookup table instead of hardware multipliers.

The main architecture is a fully pipelined CORDIC rotation-mode design. The design accepts an input angle and produces fixed-point cosine and sine outputs.

## Design Summary

The current design is a 16-stage fully pipelined fixed-point CORDIC accelerator. It computes sine and cosine for input angles in the range from approximately -pi/2 to +pi/2 radians.

The internal datapath uses 20-bit signed fixed-point arithmetic with 16 fractional bits. The outputs are 16-bit Q1.15 sine and cosine values.

The pipeline has a latency of 16 cycles and a throughput of one sine/cosine output pair per clock cycle after the pipeline is full.

## Current Status

- Project directory created
- Git repository initialized
- Python golden model: complete
- RTL implementation: complete
- Testbench: written
- RTL simulation: pending due to simulator availability on server
- Synopsys Design Compiler synthesis: complete
- Clock-period synthesis sweep: complete
- Final report/results: in progress

## Synthesis Result Summary

The fastest tested clock period that met timing was 10 ns, corresponding to 100 MHz. The 10 ns run met timing with 0.00 ns slack. A slightly faster 9.5 ns clock period violated timing with -0.11 ns slack, so the current design does not reliably meet 105.26 MHz.

At the fastest passing 10 ns clock period, the synthesized design had:

- Total cell area: 34969.000000
- Reported total power: 0.3320 mW
- Latency: 16 cycles
- Steady-state throughput: 100 million sine/cosine output pairs per second

The power value should be interpreted as a synthesis-level switching-power estimate because the target library was not characterized for internal power.

Detailed synthesis results are included in:

results/synthesis_summary.md

## Planned Deliverables

- Python golden model
- SystemVerilog RTL
- Testbench and test vectors
- Design Compiler synthesis scripts
- Timing, area, and power reports
- Final GitHub documentation and report
