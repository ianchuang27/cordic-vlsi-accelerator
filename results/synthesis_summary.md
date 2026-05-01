# CORDIC Synthesis Summary

## Clock Sweep Results

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

## Frequency Calculation

Frequency in MHz was calculated using:

frequency = 1000 / clock_period_ns

Examples:

1000 / 20 ns = 50 MHz  
1000 / 10 ns = 100 MHz  
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

## Final Timing Conclusion

The fastest tested clock period that met timing was 10 ns, corresponding to 100 MHz. The 10 ns run met timing with 0.00 ns slack, meaning the design barely satisfies the 100 MHz timing constraint. The 9.5 ns run violated timing with -0.11 ns slack, so the current RTL and synthesis setup did not reliably meet 105.26 MHz.

Therefore, the maximum verified clock frequency from the tested synthesis runs is 100 MHz.

## Area Discussion

The total cell area increased as the timing constraint became more aggressive. At the relaxed 20 ns clock period, the synthesized design had a total cell area of 17031.000000. At the fastest passing clock period of 10 ns, the area increased to 34969.000000.

More aggressive failing constraints, such as 9.5 ns, 9 ns, 8 ns, 5 ns, 3 ns, and 2 ns, caused Design Compiler to use even more area while still failing timing. This shows the tradeoff between tighter timing constraints and hardware cost.

The 10 ns result is the most important implementation point because it is the fastest tested clock period that successfully met timing.

## Power Discussion

The reported total power increased as the clock period became smaller. This is expected because a faster clock increases switching activity per unit time and because Design Compiler may select larger/faster cells to try to meet tighter timing constraints.

However, the power report included the warning:

"The cells in your design are not characterized for internal power. (PWR-229)"

Because of this library limitation, the reported power values should be interpreted as synthesis-level switching-power estimates. Internal power and leakage power were reported as 0.000 because the library did not characterize those components, not because the real chip would have zero internal or leakage power.

## Architecture Summary

The design is a 16-stage fully pipelined fixed-point CORDIC accelerator. It has a latency of 16 cycles and a throughput of one sine/cosine output pair per clock cycle after the pipeline is filled.

At the fastest passing clock period of 10 ns, the design can run at 100 MHz. Since the design produces one output pair per cycle after the pipeline is full, the theoretical steady-state throughput is:

100 million sine/cosine output pairs per second.
