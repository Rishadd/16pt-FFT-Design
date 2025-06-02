`timescale 1ns / 1ps

module Multiplier_16Bit (
    input clk,
    input rst,
    input [15:0] i_a,
    input [15:0] i_b,
    input i_vld,
    output reg [15:0] o_res,
    output reg o_res_vld,
    output reg overflow
);

// Internal wires
wire sign_a, sign_b, sign_res;
wire [4:0] exp_a, exp_b, final_exp;
wire [9:0] final_mantissa;
wire result_overflow;
wire [10:0] man_a, man_b;

assign sign_a = i_a[15];
assign sign_b = i_b[15];
assign exp_a = i_a[14:10];
assign exp_b = i_b[14:10];
assign man_a = (exp_a == 5'b0) ? {1'b0, i_a[9:0]} : {1'b1, i_a[9:0]};
assign man_b = (exp_b == 5'b0) ? {1'b0, i_b[9:0]} : {1'b1, i_b[9:0]};

wire is_nan_a  = (exp_a == 5'b11111) && (man_a[9:0] != 0);
wire is_nan_b  = (exp_b == 5'b11111) && (man_b[9:0] != 0);
wire is_inf_a  = (exp_a == 5'b11111) && (man_a[9:0] == 0);
wire is_inf_b  = (exp_b == 5'b11111) && (man_b[9:0] == 0);
wire is_zero_a = (i_a[14:0] == 15'b0);
wire is_zero_b = (i_b[14:0] == 15'b0);

assign sign_res = sign_a ^ sign_b;

// Core multiplication module
Multiplication_16Bit u_Multiplication_16Bit (
    .man_a(man_a),
    .man_b(man_b),
    .exp_a(exp_a),
    .exp_b(exp_b),
    .final_mantissa(final_mantissa),
    .final_exp(final_exp),
    .overflow(result_overflow)
);

// Output control
always @(posedge clk or posedge rst) begin
    if (rst) begin
        o_res <= 16'b0;
        o_res_vld <= 1'b0;
        overflow <= 1'b0;
    end else if (i_vld) begin
        if (is_nan_a || is_nan_b || (is_inf_a && is_zero_b) || (is_zero_a && is_inf_b)) begin
            o_res <= 16'h7E00; // QNaN
            overflow <= 1'b1;
        end else if (is_inf_a || is_inf_b) begin
            o_res <= {sign_res, 5'b11111, 10'b0}; // Infinity
            overflow <= 1'b1;
        end else if (is_zero_a || is_zero_b) begin
            o_res <= {sign_res, 15'b0}; // Zero
            overflow <= 1'b0;
        end else if (result_overflow) begin
            o_res <= {sign_res, 5'b11111, 10'b0}; // Overflow → Inf
            overflow <= 1'b1;
        end else begin
            o_res <= {sign_res, final_exp, final_mantissa};
            overflow <= 1'b0;
        end
        o_res_vld <= 1'b1;
    end else begin
        o_res_vld <= 1'b0;
        o_res <= 16'b0;
    end
end

endmodule
