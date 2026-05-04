\# Quartus Compile Summary



The CORDIC RTL was compiled in Quartus Prime Lite Edition.



\## Quartus Setup



\- Quartus version: 20.1.1 Build 720

\- Top-level entity: `cordic\_pipelined`

\- Target family: Cyclone V

\- Clock constraint: 10 ns / 100 MHz through `cordic\_pipelined.sdc`



\## Compilation Result



Quartus full compilation completed successfully with 0 errors.



After adding the SDC file, Quartus read the 10 ns clock constraint and found one clock named `clk`.



\## Timing Result



The 10 ns Quartus timing run met timing.



Worst-case setup slack from the Quartus Timing Analyzer:



| Timing Corner | Worst Setup Slack |

|---|---:|

| Slow 1100 mV 85°C | +5.223 ns |

| Slow 1100 mV 0°C | +5.133 ns |

| Fast 1100 mV 85°C | +7.427 ns |

| Fast 1100 mV 0°C | +7.657 ns |



\## FPGA Resource Utilization



From the Quartus Flow Summary:



| Resource | Usage |

|---|---:|

| Logic utilization | 513 / 18,480 ALMs (3%) |

| Total registers | 957 |

| Total pins | 56 / 224 (25%) |

| Block memory bits | 0 / 3,153,920 (0%) |

| DSP blocks | 0 / 66 (0%) |

| PLLs | 0 / 4 (0%) |



\## Notes



The 0 DSP block usage supports the CORDIC design goal of using shifts and add/subtract operations instead of hardware multipliers.



The main ASIC-style timing, area, and power sweep is still the Synopsys Design Compiler result. The Quartus result is included as an additional FPGA compile check and RTL tool-flow verification.

