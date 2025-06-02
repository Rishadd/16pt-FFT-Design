`timescale 1ns / 1ps

module Multiplication_16Bit(
    input [10:0] man_a,
    input [10:0] man_b,
    input [4:0] exp_a,
    input [4:0] exp_b,
    output [9:0] final_mantissa,
    output [4:0] final_exp,
    output overflow
);

wire [21:0] product = man_a * man_b; // Multiply mantissas max (11x11 = 22 bits)

// Normalization
wire norm_shift = product[21]; //checking if number is normal or denormal
wire [9:0] man_norm = norm_shift ? product[20:11] : product[19:10]; //nomalizing the mantissa product
wire guard_bit = norm_shift ? product[10] : product[9]; //guard bit is the one after 10 bits from decimal point
wire sticky_bit = norm_shift ? |product[9:0] : |product[8:0]; //checking if there is a 1 present after guard bit
wire round = guard_bit & sticky_bit; //round = 1 if guard bit is 1 and sticky bit is 1

// Add rounding (could overflow mantissa → handled later)
wire [10:0] rounded = {1'b0, man_norm} + round; //11 bit wire to account for overflow
wire carry = rounded[10]; // For overflow detection after rounding
assign final_mantissa = carry ? rounded[10:1] : rounded[9:0]; //final 10 bits of the mantissa

//Exponent computation
wire [6:0] exp_raw = exp_a + exp_b - 5'd15 + norm_shift + carry; //15 is subtracted because it is added twice
assign final_exp = exp_raw[4:0];

assign overflow = exp_raw > 5'd30; //30 = 11110

endmodule
