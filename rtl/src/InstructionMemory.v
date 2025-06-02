`timescale 1ns / 1ps

module InstructionMemory (
    input [31:0] readAddr,
    output reg [31:0] inst
);
    
    // Do not modify this file!

    integer i;
reg [31:0] insts [0:127];

initial begin
    for(i = 0; i < 128; i = i + 1) begin
        insts[i] = 0;
    end
    $readmemh("C:\\Users\\RAVI\\Vivado Projects\\RISCV_4\\RISCV_4.srcs\\sources_1\\new\\TEST_INSTRUCTIONS.dat", insts);
end

always @(*) begin
    inst = insts[readAddr[31:2]]; // Word-aligned memory access
end

endmodule
