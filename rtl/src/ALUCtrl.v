`timescale 1ns / 1ps

module ALUCtrl (
    input [1:0] ALUOp,
    input [6:0] funct7, op,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

always @(*) begin
    ALUCtl = 4'b0000; // Default: ADD (for address calculation)

    case (ALUOp)
        2'b00: begin  // Load and Store operations (all use ADD)
            case (op)
                7'b0000011, // Loads: lw, lh, lhu, lb, lbu
                7'b0100011: // Stores: sw, sh, sb
                    ALUCtl = 4'b0000; // ADD for address calculation
                default: ALUCtl = 4'b0000;
            endcase
        end
        
        2'b01: begin // Branch operations
            case (funct3)
                3'b000: ALUCtl = 4'b0001; // BEQ (SUB, check zero flag)
                3'b001: ALUCtl = 4'b0001; // BNE (SUB, check nonzero flag)
                3'b100: ALUCtl = 4'b0101; // BLT (SLT signed)
                3'b101: ALUCtl = 4'b0101; // BGE (SLT signed, invert result)
                3'b110: ALUCtl = 4'b0110; // BLTU (SLTU unsigned)
                3'b111: ALUCtl = 4'b0110; // BGEU (SLTU unsigned, invert result)
                default: ALUCtl = 4'b0000;
            endcase
        end
        
        2'b10: begin // R-type and I-type ALU Operations
            case (funct3)
                3'b000: begin  // ADD / SUB
                    if (funct7 == 7'b0110011 && op[5]) 
                        ALUCtl = 4'b0001; // SUB
                    else
                        ALUCtl = 4'b0000; // ADD
                end
                3'b001: ALUCtl = 4'b0111; // SLL (Shift Left Logical)
                3'b010: ALUCtl = 4'b0101; // SLT (Set Less Than)
                3'b011: ALUCtl = 4'b0110; // SLTU (Set Less Than Unsigned)
                3'b100: ALUCtl = 4'b0100; // XOR
                3'b101: begin // SRL / SRA
                    if (funct7[5]) 
                        ALUCtl = 4'b1001; // SRA (Shift Right Arithmetic)
                    else 
                        ALUCtl = 4'b1000; // SRL (Shift Right Logical)
                end
                3'b110: ALUCtl = 4'b0011; // OR
                3'b111: ALUCtl = 4'b0010; // AND
                default: ALUCtl = 4'b0000;
            endcase
        end

        // LUI and AUIPC (U-type instructions)
        2'b11: begin
            if (op == 7'b0110111)  // LUI
                ALUCtl = 4'b1010;  // Load Upper Immediate
            else if (op == 7'b0010111)  // AUIPC
                ALUCtl = 4'b1011;  // Add Upper Immediate to PC
        end
        
        default: ALUCtl = 4'b0000;
    endcase               
end

endmodule
