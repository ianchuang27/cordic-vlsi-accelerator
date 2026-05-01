# Fixed-Point Pipelined CORDIC Accelerator

## 1. Introduction

This project implements a fixed-point CORDIC accelerator for sine and cosine computation. CORDIC is useful in VLSI digital signal processing because it computes trigonometric functions using shifts, additions, subtractions, registers, and a small lookup table instead of hardware multipliers.

The goal of this project is to develop a high-performance RTL architecture and synthesize it using Synopsys Design Compiler. The main design is a 16-stage fully pipelined CORDIC accelerator.

## 2. CORDIC Algorithm

The design uses CORDIC rotation mode. The input is an angle θ, and the outputs are cos(θ) and sin(θ). The algorithm begins with:

x0 = K  
y0 = 0  
z0 = θ  

where K is the CORDIC gain correction constant.

At each iteration, the algorithm checks the sign of z. If z is positive, the vector rotates in one direction. If z is negative, the vector rotates in the opposite direction. Each stage uses only shift and add/subtract operations.

The CORDIC update equations are:

If z_i >= 0:

x_{i+1} = x_i - (y_i >>> i)  
y_{i+1} = y_i + (x_i >>> i)  
z_{i+1} = z_i - atan(2^-i)  

If z_i < 0:

x_{i+1} = x_i + (y_i >>> i)  
y_{i+1} = y_i - (x_i >>> i)  
z_{i+1} = z_i + atan(2^-i)  

After enough iterations, x converges to cos(θ) and y converges to sin(θ).

## 3. Fixed-Point Design

The internal datapath uses 20-bit signed fixed-point values with 16 fractional bits. The output uses 16-bit Q1.15 format. The Python golden model uses the same fixed-point scaling as the RTL and generates the expected test vectors.

The CORDIC gain correction value is:

K ≈ 0.607252935

With 16 fractional bits:

K_fixed = round(0.607252935 × 2^16)

K_fixed = round(0.607252935 × 65536)

K_fixed = 39797

The RTL therefore initializes the x datapath using K_FIXED = 39797. The y datapath starts at 0, and the z datapath starts at the input angle.

The output saturation logic prevents overflow when the cosine or sine value is close to +1.0 or -1.0.

## 4. Pipelined RTL Architecture

The RTL implements a fully pipelined 16-stage architecture. Each stage stores x, y, z, and valid signals in pipeline registers. Each stage performs one CORDIC micro-rotation.

The design has:

- 16 CORDIC stages
- 20-bit internal x/y/z datapaths
- 16-bit Q1.15 sine/cosine outputs
- valid_in and valid_out control signals
- one output per clock cycle after pipeline fill

The latency is 16 cycles. The throughput is one sine/cosine output pair per clock cycle after the pipeline is full.

At a 10 ns clock period, the clock frequency is:

frequency = 1000 / 10 ns

frequency = 100 MHz

Since the pipeline produces one output pair per cycle after filling, the steady-state throughput at 100 MHz is:

100 million sine/cosine output pairs per second.

## 5. Verification

The Python golden model computes the expected fixed-point sine and cosine values. It generated test vectors for angles from -π/2 to +π/2 radians. The maximum absolute error over the selected test set was approximately:

6.346e-05

This small error is expected because the design uses finite word-length fixed-point arithmetic and 16 CORDIC iterations.

A SystemVerilog testbench was written to read the generated test vectors and compare the RTL outputs against the golden model. However, the available server environment did not include iverilog, VCS, Questa, or ModelSim in the current PATH, so RTL simulation was not completed on this server. The RTL was still analyzed, elaborated, and synthesized successfully using Design Compiler.

## 6. Synthesis Method

The design was synthesized using Synopsys Design Compiler NXT. The synthesis flow included:

1. Reading the SystemVerilog RTL
2. Elaborating the top-level module
3. Linking the design
4. Applying clock and I/O constraints
5. Running compile_ultra
6. Generating timing, area, power, QoR, and constraint reports

The target library used was lsi_10k.

## 7. Synthesis Results

The design was synthesized at multiple clock periods to evaluate timing closure, area, and reported power.

| Clock Period | Frequency | Worst Slack | Timing Status | Total Cell Area | Reported Total Power |
|---:|---:|---:|:---:|---:|---:|
| 20 ns | 50 MHz | +0.03 ns | MET | 17031.000000 | 0.0937 mW |
| 10 ns | 100 MHz | +0.00 ns | MET | 34969.000000 | 0.3320 mW |
| 9.5 ns | 105.26 MHz | -0.11 ns | VIOLATED | 35716.000000 | 0.3580 mW |
| 9 ns | 111.11 MHz | -0.65 ns | VIOLATED | 35721.000000 | 0.3860 mW |
| 8 ns | 125 MHz | -1.60 ns | VIOLATED | 36317.000000 | 0.4320 mW |
| 5 ns | 200 MHz | -4.41 ns | VIOLATED | 38489.000000 | 0.7310 mW |
| 3 ns | 333.33 MHz | -6.38 ns | VIOLATED | 39108.000000 | 1.2200 mW |
| 2 ns | 500 MHz | -7.34 ns | VIOLATED | 39464.000000 | 1.7900 mW |

## 8. Timing Analysis

The fastest tested clock period that met timing was 10 ns, corresponding to 100 MHz. The 10 ns run met timing with 0.00 ns slack, meaning the design barely satisfies the 100 MHz timing constraint.

The 9.5 ns run violated timing with -0.11 ns slack. This means the current design did not reliably meet 105.26 MHz. More aggressive constraints such as 9 ns, 8 ns, 5 ns, 3 ns, and 2 ns also failed timing.

Therefore, the maximum verified clock frequency from the tested synthesis runs is 100 MHz.

## 9. Area Analysis

The area increased as the clock constraint became more aggressive. At 20 ns, the design had a total cell area of 17031.000000. At 10 ns, the fastest passing clock period, the design had a total cell area of 34969.000000.

The area increase is expected because Design Compiler must use faster or larger logic structures to try to meet tighter timing constraints. For clock periods faster than 10 ns, the design still failed timing even though the area increased. This shows that the current architecture is close to its timing limit around 100 MHz under this synthesis setup.

## 10. Power Analysis

The 10 ns synthesis run reported total power of 3.32e+03 power units. The report states that dynamic power units are 100 nW.

Power in mW = reported units × 0.0001 mW

Power = 3.32e+03 × 0.0001 mW

Power = 0.3320 mW

The reported total power increased as the clock period became smaller. This makes sense because a faster clock increases switching activity per unit time and because Design Compiler may use larger or faster cells to try to satisfy tighter timing constraints.

However, the power report also included the warning:

"The cells in your design are not characterized for internal power. (PWR-229)"

Because of this target-library limitation, the reported power should be interpreted as a synthesis-level switching-power estimate. Internal power and leakage power were reported as 0.000 because the target library did not characterize those components. This does not mean the final physical chip would have zero internal or leakage power.

## 11. Conclusion

This project successfully implemented a fixed-point pipelined CORDIC accelerator for sine and cosine computation. The design uses shift-add arithmetic instead of hardware multipliers, making it suitable for VLSI DSP applications.

A Python golden model was created to verify the fixed-point algorithm and generate test vectors. A SystemVerilog RTL implementation and testbench were written. The RTL was synthesized using Synopsys Design Compiler NXT.

The fastest tested clock period that met timing was 10 ns, corresponding to 100 MHz. At this clock period, the synthesized design had a total cell area of 34969.000000 and a reported total power of 0.3320 mW. The design has a 16-cycle latency and can produce one sine/cosine output pair per cycle after the pipeline is filled, giving a steady-state throughput of 100 million output pairs per second at 100 MHz.
