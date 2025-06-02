`timescale 1ns / 1ps

module Addition_16Bit (
    input sign_a,
    input sign_b,
    input [10:0] a, // 10-bit mantissa + 1 leading bit + 1 guard bit (if needed)
    input [10:0] b,
    output reg [11:0] res,     // wider to store carry or intermediate result
    output reg sign_res
);

    always @(*) begin
        if (sign_a == sign_b) begin
            // Same sign: simple addition, keep the sign
            res = a + b;
            sign_res = sign_a;
        end else if (a >= b) begin
            // Different signs: subtract smaller from larger
            res = a - b;
            sign_res = sign_a;
        end else begin
            res = b - a;
            sign_res = sign_b;
        end
    end

endmodule
