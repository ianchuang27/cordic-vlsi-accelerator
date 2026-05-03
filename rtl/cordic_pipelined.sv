
// 16-stage fixed-point CORDIC pipeline.
// Rotation mode: angle_in -> cos_out/sin_out.
// Internal values use 20-bit signed fixed point with 16 fractional bits.
// Outputs are saturated to 16-bit Q1.15.

module cordic_pipelined #(
    parameter integer IW = 20,
    parameter integer OW = 16,
    parameter integer FRAC_BITS = 16,
    parameter integer OUT_FRAC_BITS = 15,
    parameter integer ITERATIONS = 16
)(
    input  logic clk,
    input  logic rst_n,

    input  logic valid_in,
    input  logic signed [IW-1:0] angle_in,

    output logic valid_out,
    output logic signed [OW-1:0] cos_out,
    output logic signed [OW-1:0] sin_out
);

    // K = 0.607252935 * 2^16 = 39797
    localparam logic signed [IW-1:0] K_FIXED = 20'sd39797;

    // x/y/z state for each pipeline stage.
    logic signed [IW-1:0] x_pipe [0:ITERATIONS];
    logic signed [IW-1:0] y_pipe [0:ITERATIONS];
    logic signed [IW-1:0] z_pipe [0:ITERATIONS];

    logic valid_pipe [0:ITERATIONS];

    integer i;


    // atan(2^-i) table, scaled by 2^16.

    function automatic logic signed [IW-1:0] atan_const(input integer idx);
        begin
            case (idx)
                0:  atan_const = 20'sd51472;
                1:  atan_const = 20'sd30386;
                2:  atan_const = 20'sd16055;
                3:  atan_const = 20'sd8150;
                4:  atan_const = 20'sd4091;
                5:  atan_const = 20'sd2047;
                6:  atan_const = 20'sd1024;
                7:  atan_const = 20'sd512;
                8:  atan_const = 20'sd256;
                9:  atan_const = 20'sd128;
                10: atan_const = 20'sd64;
                11: atan_const = 20'sd32;
                12: atan_const = 20'sd16;
                13: atan_const = 20'sd8;
                14: atan_const = 20'sd4;
                15: atan_const = 20'sd2;
                default: atan_const = '0;
            endcase
        end
    endfunction


    // Convert internal value to saturated Q1.15 output.

function automatic logic signed [OW-1:0] sat_q15(input logic signed [IW-1:0] val);
    logic signed [IW-1:0] shifted;
    logic signed [OW-1:0] narrowed;
    begin
        shifted = val >>> (FRAC_BITS - OUT_FRAC_BITS);
        narrowed = shifted[OW-1:0];

        if (shifted > 20'sd32767)
            sat_q15 = 16'sd32767;
        else if (shifted < -20'sd32768)
            sat_q15 = -16'sd32768;
        else
            sat_q15 = narrowed;
    end
endfunction

    // One CORDIC micro-rotation per pipeline stage.

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i <= ITERATIONS; i = i + 1) begin
                x_pipe[i] <= '0;
                y_pipe[i] <= '0;
                z_pipe[i] <= '0;
                valid_pipe[i] <= 1'b0;
            end
        end else begin
            // Stage 0 initialization
            x_pipe[0] <= K_FIXED;
            y_pipe[0] <= '0;
            z_pipe[0] <= angle_in;
            valid_pipe[0] <= valid_in;

            // Stages 0 through 15
            for (i = 0; i < ITERATIONS; i = i + 1) begin
                valid_pipe[i+1] <= valid_pipe[i];

                if (z_pipe[i] >= 0) begin
                    x_pipe[i+1] <= x_pipe[i] - (y_pipe[i] >>> i);
                    y_pipe[i+1] <= y_pipe[i] + (x_pipe[i] >>> i);
                    z_pipe[i+1] <= z_pipe[i] - atan_const(i);
                end else begin
                    x_pipe[i+1] <= x_pipe[i] + (y_pipe[i] >>> i);
                    y_pipe[i+1] <= y_pipe[i] - (x_pipe[i] >>> i);
                    z_pipe[i+1] <= z_pipe[i] + atan_const(i);
                end
            end
        end
    end

    assign valid_out = valid_pipe[ITERATIONS];
    assign cos_out = sat_q15(x_pipe[ITERATIONS]);
    assign sin_out = sat_q15(y_pipe[ITERATIONS]);

endmodule
