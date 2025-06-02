`timescale 1ns / 1ps

module fft_ctrl (
   input  wire        clk,
   input  wire        reset,

   input  wire        in_push,
   input  wire [15:0] in_real,
   input  wire [15:0] in_imag,
   output reg         in_stall_F,

   output reg  [3:0]  read_addr_1_F,
   output reg  [3:0]  read_addr_2_F,
   output reg  [2:0]  W_addr_F,

   output reg  [3:0]  write_addr_1_F,
   output reg  [31:0] write_data_1_F,
   output reg         write_en_1_F,
   output reg  [3:0]  write_addr_2_F,
   output reg         write_en_2_F,
   output reg         write_back_F,

   output reg         out_push_F,
   input  wire        out_stall
);

   // FSM States
   localparam READ       = 2'b00;
   localparam RX_STORE   = 2'b01;
   localparam TRANSMIT   = 2'b10;

   reg [1:0]  state, next_state;

   reg [3:0]  counter;      // Counter for sample index (0 to 15)
   reg [2:0]  butterfly;    // Butterfly index (0 to 7)
   reg [1:0]  stage;        // FFT stage index (0 to 3)

   wire [3:0] A_addr, B_addr;
   wire [2:0] W_addr;

   // LUT instance for address generation
   address_lut address_lut_inst (
      .stage(stage),
      .butterfly(butterfly),
      .A_addr(A_addr),
      .B_addr(B_addr),
      .W_addr(W_addr)
   );

   // Combinational logic for FSM behavior
   always @(*) begin
      // Default signal values
      in_stall_F     = 1;
      out_push_F     = 0;
      write_en_1_F   = 0;
      write_en_2_F   = 0;
      write_back_F   = 0;
      read_addr_1_F  = 0;
      read_addr_2_F  = 0;
      write_addr_1_F = 0;
      write_addr_2_F = 0;
      write_data_1_F = 0;
      W_addr_F       = W_addr;
      next_state     = state;

      case (state)

         // READ: Input 16 complex samples
         READ: begin
            in_stall_F = 0;
            if (in_push) begin
               write_en_1_F   = 1;
               write_addr_1_F = counter;
               write_data_1_F = {in_real, in_imag};

               if (counter == 4'd15)
                  next_state = RX_STORE; // Move to processing
            end
         end

         // RX_STORE: Read two inputs, perform butterfly, and write outputs
         RX_STORE: begin
            read_addr_1_F  = A_addr;
            read_addr_2_F  = B_addr;
            write_addr_1_F = A_addr;
            write_addr_2_F = B_addr;
            write_en_1_F   = 1;
            write_en_2_F   = 1;
            write_back_F   = 1;

            // Move to next stage or transition to transmit
            if (butterfly == 3'd7) begin
               if (stage == 2'd3)
                  next_state = TRANSMIT;
            end
         end

         // TRANSMIT: Output 16 FFT results one by one
         TRANSMIT: begin
            out_push_F    = 1;
            read_addr_1_F = counter;

            if (counter == 4'd15)
               next_state = READ; // Loop back for next input set
         end
      endcase
   end

   // Sequential logic: state and counter updates
   always @(posedge clk or posedge reset) begin
      if (reset) begin
         state      <= READ;
         counter    <= 0;
         butterfly  <= 0;
         stage      <= 0;
      end else begin
         state <= next_state;

         case (state)

            // READ: Increment input sample counter
            READ: begin
               if (in_push) begin
                  counter <= counter + 1;
               end
            end

            // RX_STORE: Increment butterfly, update stage if needed
            RX_STORE: begin
               if (butterfly == 3'd7) begin
                  butterfly <= 0;
                  if (stage != 2'd3)
                     stage <= stage + 1;
               end else begin
                  butterfly <= butterfly + 1;
               end
            end

            // TRANSMIT: Output counter reset after last sample
            TRANSMIT: begin
               counter <= counter + 1;
               if (counter == 4'd15)
                  counter <= 0;
            end
         endcase
      end
   end

endmodule
