# Fixed-Point Pipelined CORDIC Accelerator

## 1. Introduction

This project implements a fixed-point CORDIC accelerator for sine and cosine computation. CORDIC is useful in digital signal processing hardware because it can compute trigonometric functions using shifts, additions, subtractions, registers, and a small angle lookup table instead of hardware multipliers.

The goal of this project was to develop a high-throughput VLSI-style RTL architecture, verify the fixed-point behavior with a software model, and synthesize the RTL using Synopsys Design Compiler. The final implementation is a 16-stage fully pipelined CORDIC rotation-mode accelerator that accepts an input angle and outputs fixed-point cosine and sine values.

The project was developed using a Python golden model, SystemVerilog RTL, a SystemVerilog testbench, and Synopsys Design Compiler NXT on the RPI ECSE `ts3` server.

---

## 2. CORDIC Algorithm

The design uses CORDIC rotation mode. The input is an angle θ, and the outputs are cos(θ) and sin(θ). The algorithm begins with:

x0 = K  
y0 = 0  
z0 = θ  

where K is the CORDIC gain correction constant.

The x datapath eventually converges toward cos(θ), the y datapath converges toward sin(θ), and the z datapath tracks the remaining angle error. At each iteration, the algorithm checks the sign of z and rotates the vector in the direction that reduces the remaining angle error.

For each iteration i, the design uses the following update equations.

If z_i >= 0:

x_{i+1} = x_i - (y_i >>> i)  
y_{i+1} = y_i + (x_i >>> i)  
z_{i+1} = z_i - atan(2^-i)  

If z_i < 0:

x_{i+1} = x_i + (y_i >>> i)  
y_{i+1} = y_i - (x_i >>> i)  
z_{i+1} = z_i + atan(2^-i)  

The shift operations implement multiplication by powers of two. This is why CORDIC is attractive for hardware: each stage only needs shifters, add/subtract logic, registers, and a stored arctangent constant.

---

## 3. Fixed-Point Design

The internal datapath uses 20-bit signed fixed-point values with 16 fractional bits. The output uses 16-bit Q1.15 format. The Python golden model uses the same fixed-point scaling as the RTL and generates the expected test vectors used by the testbench.

The CORDIC gain correction value for 16 iterations is approximately:

K ≈ 0.607252935

With 16 fractional bits, the fixed-point value is calculated as:

K_fixed = round(0.607252935 × 2^16)

K_fixed = round(0.607252935 × 65536)

K_fixed = 39797

The RTL therefore initializes the x datapath using:

x0 = 39797

The y datapath starts at 0, and the z datapath starts at the input angle. The arctangent lookup table is also stored in fixed-point format using 16 fractional bits.

The final sine and cosine outputs are saturated into 16-bit Q1.15 format. This prevents values close to +1.0 or -1.0 from wrapping around due to signed fixed-point overflow.

---

## 4. Pipelined RTL Architecture

The RTL implements a fully pipelined 16-stage CORDIC architecture. Each stage performs one CORDIC micro-rotation and stores the intermediate x, y, z, and valid signals in pipeline registers.

The main architecture includes:

- 16 CORDIC stages
- 20-bit internal x/y/z datapaths
- 16-bit Q1.15 sine and cosine outputs
- valid_in and valid_out control signals
- one output pair per clock cycle after the pipeline is full

The latency is 16 cycles because each input angle must pass through all 16 pipeline stages. However, the throughput is much higher than an iterative design because a new input angle can be accepted every clock cycle.

At the fastest passing synthesis point, the clock period was 10 ns. The clock frequency is:

frequency = 1000 / clock_period_ns

frequency = 1000 / 10

frequency = 100 MHz

Since the pipeline can produce one output pair per cycle after filling, the steady-state throughput at 100 MHz is:

100 million sine/cosine output pairs per second.

This is the main performance advantage of the pipelined architecture.

---

## 5. Verification

A Python golden model was written first to verify the fixed-point CORDIC algorithm before synthesis. The model computes sine and cosine using the same 16-iteration fixed-point CORDIC method as the RTL. It also compares the CORDIC outputs against Python's floating-point math library.

The Python model generated test vectors for angles from -π/2 to +π/2 radians. The maximum absolute error over the selected test set was approximately:

6.346e-05

This small error is expected because the design uses finite word-length fixed-point arithmetic and a finite number of CORDIC iterations.

A SystemVerilog testbench was also written to read the generated test vectors and compare RTL outputs against the Python golden model outputs. The testbench applies one new angle per clock cycle and checks the corresponding sine and cosine outputs when valid_out is asserted.

One limitation was that the available server environment did not include Icarus Verilog, VCS, Questa, or ModelSim in the current PATH. Because of this, RTL simulation was not completed on the server. However, the RTL was successfully analyzed, elaborated, checked, and synthesized using Synopsys Design Compiler. The included testbench and test vectors are ready to use in a SystemVerilog simulator if one is available.

---

## 6. Synthesis Method

The design was synthesized using Synopsys Design Compiler NXT on the RPI ECSE `ts3` server. The synthesis flow included:

1. Reading the SystemVerilog RTL
2. Elaborating the top-level module
3. Linking the design with the target library
4. Applying clock and I/O constraints
5. Running `compile_ultra`
6. Generating timing, area, power, QoR, resource, and constraint reports

The target library used was:

lsi_10k

The main implementation point was the 10 ns clock period because it was the fastest tested clock period that met timing.

---

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

---

## 8. Timing Analysis

The fastest tested clock period that met timing was 10 ns, corresponding to 100 MHz. The 10 ns run had 0.00 ns slack, meaning the design barely met the timing constraint.

The next faster test point was 9.5 ns. That run failed timing with -0.11 ns slack. This means the design did not reliably meet 105.26 MHz with the current RTL, target library, and synthesis setup.

More aggressive clock periods also failed:

- 9 ns failed with -0.65 ns slack
- 8 ns failed with -1.60 ns slack
- 5 ns failed with -4.41 ns slack
- 3 ns failed with -6.38 ns slack
- 2 ns failed with -7.34 ns slack

Therefore, the maximum verified clock frequency from the tested synthesis runs is 100 MHz.

The result also shows that the design is close to its timing limit around 100 MHz. A future version could attempt to improve timing by adding more pipeline registers inside each CORDIC stage, reducing datapath width, or restructuring the add/subtract logic.

---

## 9. Area Analysis

The area increased as the clock constraint became more aggressive. At 20 ns, the synthesized design had a total cell area of:

17031.000000

At 10 ns, the fastest passing clock period, the total cell area increased to:

34969.000000

This increase is expected because Design Compiler may choose faster or larger logic cells to try to meet tighter timing constraints. For clock periods faster than 10 ns, the design still failed timing even though the area continued to increase. This shows that pushing the clock period below 10 ns increased hardware cost without producing a valid timing result.

The most important area result is therefore the 10 ns result:

Total cell area at 10 ns = 34969.000000

This corresponds to the fastest synthesis point that successfully met timing.

---

## 10. Power Analysis

The 10 ns synthesis run reported a total power value of:

3.32e+03 power units

The Design Compiler report states that the dynamic power unit is:

100 nW

Therefore:

Power in mW = reported power units × 0.0001 mW

For the 10 ns run:

Power = 3.32e+03 × 0.0001 mW

Power = 0.3320 mW

The reported total power increased as the clock period became smaller. This makes sense because a faster clock increases switching activity per unit time, and tighter timing constraints can also cause Design Compiler to choose larger or faster logic cells.

However, the power report also included this warning:

"The cells in your design are not characterized for internal power. (PWR-229)"

Because of this target-library limitation, the reported power should be interpreted as a synthesis-level switching-power estimate. Internal power and leakage power were reported as 0.000 because the target library did not characterize those components. This does not mean the final physical chip would have zero internal or leakage power.

---

## 11. Development Notes

The project was built in stages. I first created the Python golden model to make sure the fixed-point CORDIC algorithm worked numerically. After that, I generated fixed-point test vectors and wrote the SystemVerilog RTL for the fully pipelined architecture. I then added a SystemVerilog testbench that reads the Python-generated test vectors.

After writing the RTL, I used Synopsys Design Compiler to check, elaborate, synthesize, and report the hardware results. I started with a 10 ns synthesis run, then swept the clock period to see how far the design could be pushed. The 10 ns run met timing, while 9.5 ns and faster runs failed. This gave a clear final performance point of 100 MHz.

The main limitation was that I could not run RTL simulation on the server because common simulators were not available in the current PATH. If more time or tool access were available, the next step would be to run the included testbench in a SystemVerilog simulator and add the simulation log to the repository.

---

## 12. Conclusion

This project successfully implemented a fixed-point pipelined CORDIC accelerator for sine and cosine computation. The design uses shift-add arithmetic instead of hardware multipliers, making it suitable for VLSI DSP applications where trigonometric values are needed repeatedly.

A Python golden model was created to verify the fixed-point algorithm and generate test vectors. A SystemVerilog RTL implementation and testbench were written. The RTL was synthesized using Synopsys Design Compiler NXT.

The fastest tested clock period that met timing was 10 ns, corresponding to 100 MHz. At this clock period, the synthesized design had a total cell area of 34969.000000 and a reported total power of 0.3320 mW. The design has a 16-cycle latency and can produce one sine/cosine output pair per clock cycle after the pipeline is filled, giving a steady-state throughput of 100 million output pairs per second at 100 MHz.

Overall, the final design demonstrates the main VLSI tradeoff of the project: the fully pipelined CORDIC architecture uses more hardware than an iterative design, but it provides much higher throughput by accepting a new input every clock cycle.
