`timescale 1ns / 1ps

module ALU (
    input [3:0] ALUCtl,
    input [31:0] A, B,
    input invert,
    output reg [31:0] ALUOut,
    output reg zero
);

always @(*) begin
    case (ALUCtl)
        4'b0000: ALUOut = A + B; // ADD
        4'b0001: ALUOut = A - B; // SUB
        4'b0010: ALUOut = A & B; // AND
        4'b0011: ALUOut = A | B; // OR
        4'b0100: ALUOut = A ^ B; // XOR
        4'b0101: begin
            ALUOut = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT (signed)
            if (invert) ALUOut = ~ALUOut & 32'd1;
        end
        4'b0110: begin
            ALUOut = (A < B) ? 32'd1 : 32'd0; // SLTU (unsigned)
            if (invert) ALUOut = ~ALUOut & 32'd1;
        end
        4'b0111: ALUOut = A << B[4:0];   // SLL
        4'b1000: ALUOut = A >> B[4:0];   // SRL
        4'b1001: ALUOut = $signed(A) >>> B[4:0]; // SRA
        4'b1010: ALUOut = B << 12; // LUI (Load Upper Immediate)
        4'b1011: ALUOut = A + (B << 12); // AUIPC (Add Upper Immediate to PC)
        default: ALUOut = 32'b0;
    endcase
end

// Separate always block for zero flag
always @(*) begin
    zero = (ALUOut == 32'b0) ? 1'b1 : 1'b0;
end

endmodule
