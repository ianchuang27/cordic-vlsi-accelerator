# CORDIC Synthesis Summary

## Clock Sweep Results

|Clock Period|Frequency|Worst Slack|Timing Status|Total Cell Area|Reported Total Power|
|-:|-:|-:|:-:|-:|-:|
|20 ns|50 MHz|+0.03 ns|MET|17031.000000|0.0937 mW|
|10 ns|100 MHz|+0.00 ns|MET|34969.000000|0.3320 mW|
|9.5 ns|105.26 MHz|-0.11 ns|VIOLATED|35716.000000|0.3580 mW|
|9 ns|111.11 MHz|-0.65 ns|VIOLATED|35721.000000|0.3860 mW|
|8 ns|125 MHz|-1.60 ns|VIOLATED|36317.000000|0.4320 mW|
|5 ns|200 MHz|-4.41 ns|VIOLATED|38489.000000|0.7310 mW|
|3 ns|333.33 MHz|-6.38 ns|VIOLATED|39108.000000|1.2200 mW|
|2 ns|500 MHz|-7.34 ns|VIOLATED|39464.000000|1.7900 mW|

## Frequency Calculation

Frequency in MHz was calculated as:

frequency = 1000 / clock\_period\_ns

For example, the 10 ns run corresponds to, and for other values:

1000 / 10 = 100 MHz

1000 / 20 ns = 50 MHz  
1000 / 9.5 ns = 105.26 MHz  
1000 / 5 ns = 200 MHz

## Power Conversion

Design Compiler reported dynamic power units of 100 nW.

Therefore:

Power in mW = reported power units × 0.0001 mW

For the 10 ns synthesis run:

reported total power = 3.32e+03 units

Power = 3.32e+03 × 0.0001 mW

Power = 0.3320 mW

## Timing Result

The fastest tested clock period that met timing was 10 ns. That run had 0.00 ns slack, so it barely met the 100 MHz target. The next faster point, 9.5 ns, failed with -0.11 ns slack. I used 10 ns as the final implementation point because it was the fastest tested period with no violated constraints.

## Area Result

The 10 ns implementation had a total cell area of 34969.000000. The area was lower at 20 ns because the timing constraint was easier. When I pushed the clock faster than 10 ns, Design Compiler used more area but still could not close timing.

## Power Result

The 10 ns power report gave a reported total power of 0.3320 mW. The power report also warned that the library cells were not characterized for internal power, so I treat this value as a switching-power estimate rather than a final post-layout power number.

## RTL Simulation Result



RTL simulation was run in ModelSim using:



- `rtl/cordic\_pipelined.sv`

- `tb/tb\_cordic\_pipelined.sv`

- `tb/test\_vectors.txt`



The RTL and testbench both compiled with 0 errors and 0 warnings. The testbench loaded 11 test vectors and compared the RTL cosine and sine outputs against the Python-generated expected values.



The simulation completed with all tests passing.



Simulation log:



`results/modelsim\_rtl\_sim.log`



## Quartus FPGA Compile Result



Quartus Prime Lite Edition was also used to compile the RTL for a Cyclone V FPGA target.



Quartus full compilation completed successfully with 0 errors. With the 10 ns SDC clock constraint, Quartus reported positive worst-case setup slack at all timing corners.



| Timing Corner | Worst Setup Slack |

|---|---:|

| Slow 1100 mV 85°C | +5.223 ns |

| Slow 1100 mV 0°C | +5.133 ns |

| Fast 1100 mV 85°C | +7.427 ns |

| Fast 1100 mV 0°C | +7.657 ns |



The Quartus compile also reported 0 DSP block usage, supporting the shift-add CORDIC implementation.

## Final Implementation Point

Final selected clock period: 10 ns  
Final selected frequency: 100 MHz  
Total cell area: 34969.000000  
Reported total power: 0.3320 mW  
Latency: 16 cycles  
Steady-state throughput: 100 million sine/cosine output pairs per second

The design is a 16-stage fully pipelined fixed-point CORDIC accelerator. It has a latency of 16 cycles and a throughput of one sine/cosine output pair per clock cycle after the pipeline is filled.

At the fastest passing clock period of 10 ns, the design can run at 100 MHz. Since the design produces one output pair per cycle after the pipeline is full, the theoretical steady-state throughput is:

100 million sine/cosine output pairs per second.

