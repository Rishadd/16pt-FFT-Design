`timescale 1ns / 1ps

module Control (
    input [6:0] opcode,
    output reg branch,
    output reg jump,
    output reg memRead,
    output reg [1:0]resultSRC,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg regWrite
    );


always @(*)begin
case(opcode)
    7'b0000011: begin
            branch=1'b0;
            jump=1'b0;
            memRead=1'b1;
            resultSRC=2'b01;
            ALUOp=2'b00;
            memWrite=1'b0;
            ALUSrc=1'b1;
            regWrite=1'b1;
            end
    
    7'b0100011: begin
            branch=1'b0;
            jump=1'b0;
            memRead=1'b0;
            resultSRC=2'b01;
            ALUOp=2'b00;
            memWrite=1'b1;
            ALUSrc=1'b1;
            regWrite=1'b0;
            end
    7'b0110011: begin
            branch=1'b0;
            jump=1'b0;
            memRead=1'b0;
            resultSRC=2'b00;
            ALUOp=2'b10;
            memWrite=1'b0;
            ALUSrc=1'b0;
            regWrite=1'b1;
            end
    7'b1100011: begin
            branch=1'b1;
            jump=1'b0;
            memRead=1'b0;
            resultSRC=2'b00;
            ALUOp=2'b01;
            memWrite=1'b0;
            ALUSrc=1'b0;
            regWrite=1'b0;
            end
    7'b0010011: begin
            branch=1'b0;
            jump=1'b0;
            memRead=1'b0;
            resultSRC=2'b00;
            ALUOp=2'b10;
            memWrite=1'b0;
            ALUSrc=1'b1;
            regWrite=1'b1;
            end
    7'b1101111: begin
            branch=1'b0;
            jump=1'b1;
            memRead=1'b0;
            resultSRC=2'b10;
            ALUOp=2'b10;
            memWrite=1'b0;
            ALUSrc=1'b1;
            regWrite=1'b1;
            end
    7'b0010111: begin 
            branch = 1'b0;
            jump = 1'b0;
            memRead = 1'b0;
            resultSRC = 2'b10;
            ALUOp = 2'b11; 
            memWrite = 1'b0;
            ALUSrc = 1'b1; 
            regWrite = 1'b1; 
        end 
    7'b0110111: begin 
            branch = 1'b0;
            jump = 1'b0;
            memRead = 1'b0;
            resultSRC = 2'b11; 
            ALUOp = 2'b11; 
            memWrite = 1'b0;
            ALUSrc = 1'b1;
            regWrite = 1'b1;
        end
    default: begin
            branch=1'b0;
            jump=1'b0;
            memRead=1'b0;
            resultSRC=2'b00;
            ALUOp=2'b00;
            memWrite=1'b0;
            ALUSrc=1'b0;
            regWrite=1'b0;
            end
        
     endcase
end

endmodule




