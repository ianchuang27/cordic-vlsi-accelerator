# Power Report Note

Synopsys Design Compiler generated power report files for each synthesis run. The reports include switching power values, but they also include the warning:

"The cells in your design are not characterized for internal power. (PWR-229)"

For example, the 10 ns report gives:

- Switch power: 3.32e+03 units
- Internal power: 0.000
- Leakage power: 0.000
- Total power: 3.32e+03 units

The report states that dynamic power units are 100 nW, so:

3.32e+03 units × 100 nW = 0.3320 mW

Because internal and leakage power are not characterized in the target library, the power values should be treated as synthesis-level switching-power estimates rather than final post-layout power measurements.

