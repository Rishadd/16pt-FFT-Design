`timescale 1ns / 1ps

module butterfly
(
    input clk,                         // Clock signal
    input rst,                         // Reset signal (synchronous reset)
    
    // Inputs: Real and Imaginary parts of A and B
    input [15:0] Ar,
    input [15:0] Ai,
    input [15:0] Br,
    input [15:0] Bi,

    // Inputs: Real and Imaginary parts of the twiddle factor W
    input [15:0] Wr,
    input [15:0] Wi,

    // Outputs: Real and Imaginary parts of the two butterfly results
    output reg [15:0] Xr_F,
    output reg [15:0] Xi_F,
    output reg [15:0] Yr_F,
    output reg [15:0] Yi_F
);

    // Intermediate wires for results of the complex multiplication B * W
    wire [15:0] Zr_a;  // Br * Wr
    wire [15:0] Zr_b;  // Bi * Wi
    wire [15:0] Zi_a;  // Br * Wi
    wire [15:0] Zi_b;  // Bi * Wr

    // Final complex multiplication outputs (Z = B * W): Zr and Zi
    wire [15:0] Zrsub;  // Zr = Zr_a - Zr_b (subtraction via 2's complement)
    wire [15:0] Ziadd;  // Zi = Zi_a + Zi_b

    // Output values from butterfly computation
    wire [15:0] Xr;
    wire [15:0] Xi;
    wire [15:0] Yr;
    wire [15:0] Yi;

    // Pipeline registers to delay input A over 2 clock cycles for alignment
    reg [15:0] Ar_F;
    reg [15:0] Ai_F;
    reg [15:0] Ar_FF;
    reg [15:0] Ai_FF;

    /**************************
     * Sequential Logic
     *************************/
     
    always @(posedge clk) begin
        if (rst) begin
            // Reset all output registers to 0
            Xr_F <= 16'b0;
            Xi_F <= 16'b0;
            Yr_F <= 16'b0;
            Yi_F <= 16'b0;
        end
        else begin
            // Two-stage pipeline for input A (to match multiplier latency)
            Ar_F <= Ar;
            Ai_F <= Ai;
            Ar_FF <= Ar_F;
            Ai_FF <= Ai_F;

            // Register the final butterfly outputs
            Xr_F <= Xr;
            Xi_F <= Xi;
            Yr_F <= Yr;
            Yi_F <= Yi;
        end
    end

    /**************************
     * Complex Multiplication (Z = B * W)
     * Zr = Br*Wr - Bi*Wi
     * Zi = Br*Wi + Bi*Wr
     *************************/
     
    Multiplier_16Bit m1(.clk(clk), .rst(rst), .i_a(Br), .i_b(Wr), .i_vld(1'b1), .o_res(Zr_a));
    Multiplier_16Bit m2(.clk(clk), .rst(rst), .i_a(Bi), .i_b(Wi), .i_vld(1'b1), .o_res(Zr_b));
    Multiplier_16Bit m3(.clk(clk), .rst(rst), .i_a(Br), .i_b(Wi), .i_vld(1'b1), .o_res(Zi_a));
    Multiplier_16Bit m4(.clk(clk), .rst(rst), .i_a(Bi), .i_b(Wr), .i_vld(1'b1), .o_res(Zi_b));

    // Subtraction using 2's complement: Zr = Zr_a - Zr_b
    Adder_16Bit int1(.clk(clk), .rst(rst),
                     .i_a(Zr_a),
                     .i_b({(Zr_b[15] ^ 1'b1), Zr_b[14:0]}),  // Flip sign bit for subtraction
                     .i_vld(1'b1),
                     .o_res(Zrsub));

    // Zi = Zi_a + Zi_b
    Adder_16Bit int2(.clk(clk), .rst(rst),
                     .i_a(Zi_a),
                     .i_b(Zi_b),
                     .i_vld(1'b1),
                     .o_res(Ziadd));

    /**************************
     * Butterfly Computation
     * X = A + Z
     * Y = A - Z
     *************************/
     
    // Xr = Ar + Zr
    Adder_16Bit o1_r(.clk(clk), .rst(rst),
                     .i_a(Ar_FF),
                     .i_b(Zrsub),
                     .i_vld(1'b1),
                     .o_res(Xr));

    // Xi = Ai + Zi
    Adder_16Bit o1_i(.clk(clk), .rst(rst),
                     .i_a(Ai_FF),
                     .i_b(Ziadd),
                     .i_vld(1'b1),
                     .o_res(Xi));

    // Yr = Ar - Zr
    Adder_16Bit o2_r(.clk(clk), .rst(rst),
                     .i_a(Ar_FF),
                     .i_b({(Zrsub[15] ^ 1'b1), Zrsub[14:0]}),  // 2's complement to subtract
                     .i_vld(1'b1),
                     .o_res(Yr));

    // Yi = Ai - Zi
    Adder_16Bit o2_i(.clk(clk), .rst(rst),
                     .i_a(Ai_FF),
                     .i_b({(Ziadd[15] ^ 1'b1), Ziadd[14:0]}),  // 2's complement to subtract
                     .i_vld(1'b1),
                     .o_res(Yi));

endmodule
