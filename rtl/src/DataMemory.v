`timescale 1ns / 1ps

module DataMemory(
    input rst,
    input clk,
    input memWrite,
    input memRead,
    input [31:0] address,
    input [31:0] writeData,inst, // Determines load/store size
    output reg [31:0] readData
);
    reg [7:0] data_memory [127:0];
    wire [2:0]funct3;
    integer i;
    assign funct3=inst[14:12];
    always @(posedge clk) begin
        if (~rst) begin

            for (i = 0; i < 128; i = i + 1) begin
                data_memory[i] <= 8'b0;
            end
        end 
        else if (memWrite) begin
            case (funct3)
                3'b010: begin // sw (store word)
                    data_memory[address + 3] <= writeData[31:24];
                    data_memory[address + 2] <= writeData[23:16];
                    data_memory[address + 1] <= writeData[15:8];
                    data_memory[address]     <= writeData[7:0];
                end
                3'b000: begin // sb (store byte)
                    data_memory[address] <= writeData[7:0];
                end
                3'b001: begin // sh (store half-word)
                    data_memory[address + 1] <= writeData[15:8];
                    data_memory[address]     <= writeData[7:0];
                end
            endcase
        end
    end

    always @(*) begin
        if (memRead) begin
            case (funct3)
                3'b010: begin // lw (load word)
                    readData[31:24] = data_memory[address + 3];
                    readData[23:16] = data_memory[address + 2];
                    readData[15:8]  = data_memory[address + 1];
                    readData[7:0]   = data_memory[address];
                end
                3'b000: begin // lb (load byte, sign-extended)
                    readData = {{24{data_memory[address][7]}}, data_memory[address]};
                end
                3'b100: begin // lbu (load byte, zero-extended)
                    readData = {24'b0, data_memory[address]};
                end
                3'b001: begin // lh (load half-word, sign-extended)
                    readData = {{16{data_memory[address + 1][7]}}, data_memory[address + 1], data_memory[address]};
                end
                3'b101: begin // lhu (load half-word, zero-extended)
                    readData = {16'b0, data_memory[address + 1], data_memory[address]};
                end
                default: begin
                    readData = 32'b0;
                end
            endcase
        end else begin
            readData = 32'b0;
        end
    end
endmodule
