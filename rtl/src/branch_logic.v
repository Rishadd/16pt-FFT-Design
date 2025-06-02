`timescale 1ns / 1ps

module BranchLogic(
    input branch,          // High for branch instructions
    input jump,            // High for JAL, JALR
    input zero,            // ALU Zero Flag
    input [31:0]inst,  // Branch condition type
    input signed [31:0] ALUResult, // ALU result for signed comparisons
    output reg PCSrc       // Control signal for PC selection
);
    reg [2:0]funct3;
    always @(*) begin
        PCSrc=0;
        funct3=inst[14:12];
        case(funct3)
            3'b000: PCSrc = branch & zero;             // BEQ (Branch if Equal)
            3'b001: PCSrc = branch & ~zero;            // BNE (Branch if Not Equal)
            3'b100: PCSrc = branch & (ALUResult < 0);  // BLT (Branch if Less Than)
            3'b101: PCSrc = branch & (ALUResult >= 0); // BGE (Branch if Greater or Equal)
            3'b110: PCSrc = branch & ($unsigned(ALUResult) < 0);  // BLTU (Unsigned BLT)
            3'b111: PCSrc = branch & ($unsigned(ALUResult) >= 0); // BGEU (Unsigned BGE)
            default: PCSrc = 0;                        // Default: Don't branch
        endcase

        // JAL and JALR always cause a jump
        if (jump)
            PCSrc = 1;
    end

endmodule
