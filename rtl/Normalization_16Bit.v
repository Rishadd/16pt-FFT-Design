`timescale 1ns / 1ps

module Normalization_16Bit (
    input [11:0] res,
    input [4:0] exp_base,
    output reg [10:0] man_res,
    output reg [4:0] exp_res,
    output reg overflow
);

    reg [11:0] normalized_result;

    always @(*) begin
        normalized_result = res;
        exp_res = exp_base;
        overflow = 0;

        if (normalized_result == 0) begin //explicitly handle 0 case for lower runtime
            man_res = 0;
            exp_res = 0;
            overflow = 0;
        end 
        else begin
            if (normalized_result[11]) begin // If MSB is 1, shift right once and increment exponent
                normalized_result = normalized_result >> 1;
                exp_res = exp_base + 1;
            end 
            else begin // Shift left until bit 10 is 1 or exponent reaches 0, max 12 times
                repeat (12) begin
                    if (normalized_result[10] == 0) begin
                        normalized_result = normalized_result << 1;
                        exp_res = exp_res - 1;
                    end
                end
            end

            man_res = normalized_result[10:0];
            if (exp_res == 5'b11111) begin
                overflow = 1;
            end
        end
    end

endmodule
