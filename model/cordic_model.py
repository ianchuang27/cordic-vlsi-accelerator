import math
import os


# Fixed-point CORDIC model used to generate RTL reference vectors.


# Fixed-point settings


INTERNAL_WIDTH = 20
OUTPUT_WIDTH = 16
FRAC_BITS = 16
OUTPUT_FRAC_BITS = 15
ITERATIONS = 16

SCALE = 1 << FRAC_BITS
OUTPUT_SCALE = 1 << OUTPUT_FRAC_BITS

# Gain compensation constant for the CORDIC rotations.

K_FLOAT = 1.0
for i in range(ITERATIONS):
    K_FLOAT *= 1.0 / math.sqrt(1 + 2 ** (-2 * i))

K_FIXED = round(K_FLOAT * SCALE)

# atan table in radians, scaled by 2^16
ATAN_TABLE = [round(math.atan(2 ** -i) * SCALE) for i in range(ITERATIONS)]


def float_to_fixed(value, frac_bits=FRAC_BITS):

    # Scale a real value into fixed-point integer form.

    return int(round(value * (1 << frac_bits)))


def fixed_to_float(value, frac_bits=FRAC_BITS):

    # Convert fixed-point integer back to a real value.

    return value / float(1 << frac_bits)


def saturate_signed(value, width):

    # Clamp to the signed range for the selected width.

    # For 16-bit signed:
    # min = -2^15 = -32768
    # max =  2^15 - 1 = 32767

    min_val = -(1 << (width - 1))
    max_val = (1 << (width - 1)) - 1

    if value > max_val:
        return max_val
    elif value < min_val:
        return min_val
    else:
        return value


def cordic_rotation(theta_rad):
  # Reference CORDIC rotation-mode calculation.

  #  Input:
  #      theta_rad: input angle in radians

  #  Outputs:
  #      cos_q15: 16-bit signed Q1.15 cosine
  #      sin_q15: 16-bit signed Q1.15 sine
  #      cos_float: cosine converted back to float
  #      sin_float: sine converted back to float


    # Initial CORDIC vector.
    # x starts at K to compensate for CORDIC gain.
    # y starts at 0.
    # z starts as the desired input angle.
    x = K_FIXED
    y = 0
    z = float_to_fixed(theta_rad, FRAC_BITS)

    # CORDIC micro-rotations.
    for i in range(ITERATIONS):
        x_shift = y >> i
        y_shift = x >> i

        if z >= 0:
            x_new = x - x_shift
            y_new = y + y_shift
            z_new = z - ATAN_TABLE[i]
        else:
            x_new = x + x_shift
            y_new = y - y_shift
            z_new = z + ATAN_TABLE[i]

        x = x_new
        y = y_new
        z = z_new

    # Internal x/y values use 16 fractional bits.
    # Output uses Q1.15, so shift right by 1 bit.
    cos_q15 = saturate_signed(x >> (FRAC_BITS - OUTPUT_FRAC_BITS), OUTPUT_WIDTH)
    sin_q15 = saturate_signed(y >> (FRAC_BITS - OUTPUT_FRAC_BITS), OUTPUT_WIDTH)

    cos_float = cos_q15 / float(OUTPUT_SCALE)
    sin_float = sin_q15 / float(OUTPUT_SCALE)

    return cos_q15, sin_q15, cos_float, sin_float


def generate_test_vectors():

    # Write vectors for the RTL testbench.

    # Format per line:
    #     angle_fixed cos_expected_q15 sin_expected_q15


    os.makedirs("tb", exist_ok=True)

    # Test angles used for this project.
    test_angles = [
        -math.pi / 2,
        -math.pi / 3,
        -math.pi / 4,
        -math.pi / 6,
        -math.pi / 12,
        0.0,
        math.pi / 12,
        math.pi / 6,
        math.pi / 4,
        math.pi / 3,
        math.pi / 2,
    ]

    with open("tb/test_vectors.txt", "w") as f:
        for theta in test_angles:
            angle_fixed = float_to_fixed(theta, FRAC_BITS)
            cos_q15, sin_q15, _, _ = cordic_rotation(theta)
            f.write(f"{angle_fixed} {cos_q15} {sin_q15}\n")


def main():
    print("Fixed-Point CORDIC Golden Model")
    print("================================")
    print(f"ITERATIONS       = {ITERATIONS}")
    print(f"INTERNAL_WIDTH   = {INTERNAL_WIDTH}")
    print(f"OUTPUT_WIDTH     = {OUTPUT_WIDTH}")
    print(f"FRAC_BITS        = {FRAC_BITS}")
    print(f"K_FLOAT          = {K_FLOAT}")
    print(f"K_FIXED          = {K_FIXED}")
    print()

    print("atan lookup table:")
    for i, val in enumerate(ATAN_TABLE):
        print(f"i = {i:2d}, atan_fixed = {val}")
    print()

    print("theta(rad)       cos_math       cos_cordic     cos_error        sin_math       sin_cordic     sin_error")
    print("-------------------------------------------------------------------------------------------------------")

    test_angles = [
        -math.pi / 2,
        -math.pi / 3,
        -math.pi / 4,
        -math.pi / 6,
        -math.pi / 12,
        0.0,
        math.pi / 12,
        math.pi / 6,
        math.pi / 4,
        math.pi / 3,
        math.pi / 2,
    ]

    max_abs_error = 0.0

    for theta in test_angles:
        cos_q15, sin_q15, cos_cordic, sin_cordic = cordic_rotation(theta)

        cos_math = math.cos(theta)
        sin_math = math.sin(theta)

        cos_error = cos_cordic - cos_math
        sin_error = sin_cordic - sin_math

        max_abs_error = max(max_abs_error, abs(cos_error), abs(sin_error))

        print(
            f"{theta: .8f}   "
            f"{cos_math: .8f}   {cos_cordic: .8f}   {cos_error: .8e}   "
            f"{sin_math: .8f}   {sin_cordic: .8f}   {sin_error: .8e}"
        )

    print()
    print(f"Maximum absolute error over test set = {max_abs_error:.8e}")

    generate_test_vectors()
    print("Wrote test vectors to tb/test_vectors.txt")


if __name__ == "__main__":
    main()
