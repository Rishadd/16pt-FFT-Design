`timescale 1ns / 1ps

module Memory_32x16 (
   input clk,
   input [3:0] write_addr_1,
   input [31:0] write_data_1,
   input write_en_1,
   input [3:0] write_addr_2,
   input [31:0] write_data_2,
   input write_en_2,
   input [3:0] read_addr_1,
   output [31:0] read_data_1,
   input [3:0] read_addr_2,
   output [31:0] read_data_2
);

   reg [31:0] mem_array [15:0];

   assign read_data_1 = mem_array[read_addr_1];
   assign read_data_2 = mem_array[read_addr_2];

   always @(posedge clk) begin

      if (write_en_1) begin
         mem_array[write_addr_1] <= write_data_1;
      end

      if (write_en_2) begin
         mem_array[write_addr_2] <= write_data_2;
      end

   end

endmodule
