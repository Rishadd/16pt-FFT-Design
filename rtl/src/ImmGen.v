`timescale 1ns / 1ps

module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    // ImmGen generates immediate value based on opcode

    wire [6:0] opcode = inst[6:0];
    reg [1:0] ImmSrc;

    always @(*) begin
        case(opcode)
            7'b0000011: ImmSrc = 2'b00; // Load Instructions (I-type)
            7'b0100011: ImmSrc = 2'b01; // Store Instructions (S-type)
            7'b0110011: ImmSrc = 2'b00; // ALU Register Instructions (R-type) (No immediate)
            7'b1100011: ImmSrc = 2'b10; // Branch Instructions (B-type)
            7'b0010011: ImmSrc = 2'b00; // ALU Immediate Instructions (I-type)
            7'b1101111: ImmSrc = 2'b11; // JAL (J-type)
            7'b1100111: ImmSrc = 2'b00; // JALR (I-type)
            7'b0010111: ImmSrc = 2'b11; // AUIPC (U-type)
            7'b0110111: ImmSrc = 2'b11; // LUI (U-type)
            default:    ImmSrc = 2'b00;
        endcase
    end
    
    always @(*) begin 
        case(ImmSrc)
            2'b00: begin // I-type (Load, JALR, ALU Immediate)
                imm = {{20{inst[31]}}, inst[31:20]}; // Sign-extend 12-bit immediate
            end
            2'b01: begin // S-type (Store)
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // Sign-extend Store immediate
            end
            2'b10: begin // B-type (Branch)
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // Sign-extend Branch immediate
            end
            2'b11: begin // J-type (JAL) and U-type (AUIPC, LUI)
                if (opcode == 7'b1101111) // JAL
                    imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // Sign-extend JAL immediate
                else // AUIPC, LUI
                    imm = {inst[31:12], 12'b0}; // Upper 20-bit immediate
            end
            default: imm = 32'b0;
        endcase
    end 
            
endmodule
