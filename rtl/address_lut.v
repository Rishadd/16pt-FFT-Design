`timescale 1ns / 1ps

module address_lut (
   input [1:0] stage,           // Current FFT stage (0 to 3 for 16-point FFT)
   input [2:0] butterfly,       // Butterfly index within the stage (0 to 7)
   output reg [3:0] A_addr,     // Address for input A
   output reg [3:0] B_addr,     // Address for input B
   output reg [2:0] W_addr      // Twiddle factor index
);

// The address pattern follows bit-reversed input ordering.
// Each case block below corresponds to a specific FFT stage.

   always @(*) begin
      case (stage)

         0: begin  // Stage 0 - butterflies span 8 indices apart
            case (butterfly)
               0: begin A_addr = 0;  B_addr = 8;  W_addr = 0; end
               1: begin A_addr = 4;  B_addr = 12; W_addr = 0; end
               2: begin A_addr = 2;  B_addr = 10; W_addr = 0; end
               3: begin A_addr = 6;  B_addr = 14; W_addr = 0; end
               4: begin A_addr = 1;  B_addr = 9;  W_addr = 0; end
               5: begin A_addr = 5;  B_addr = 13; W_addr = 0; end
               6: begin A_addr = 3;  B_addr = 11; W_addr = 0; end
               7: begin A_addr = 7;  B_addr = 15; W_addr = 0; end
            endcase
         end

         1: begin  // Stage 1 - butterflies span 4 indices
            case (butterfly)
               0: begin A_addr = 0;  B_addr = 4;  W_addr = 0; end
               1: begin A_addr = 8;  B_addr = 12; W_addr = 4; end
               2: begin A_addr = 2;  B_addr = 6;  W_addr = 0; end
               3: begin A_addr = 10; B_addr = 14; W_addr = 4; end
               4: begin A_addr = 1;  B_addr = 5;  W_addr = 0; end
               5: begin A_addr = 9;  B_addr = 13; W_addr = 4; end
               6: begin A_addr = 3;  B_addr = 7;  W_addr = 0; end
               7: begin A_addr = 11; B_addr = 15; W_addr = 4; end
            endcase
         end

         2: begin  // Stage 2 - butterflies span 2 indices
            case (butterfly)
               0: begin A_addr = 0;  B_addr = 2;  W_addr = 0; end
               1: begin A_addr = 8;  B_addr = 10; W_addr = 2; end
               2: begin A_addr = 4;  B_addr = 6;  W_addr = 4; end
               3: begin A_addr = 12; B_addr = 14; W_addr = 6; end
               4: begin A_addr = 1;  B_addr = 3;  W_addr = 0; end
               5: begin A_addr = 9;  B_addr = 11; W_addr = 2; end
               6: begin A_addr = 5;  B_addr = 7;  W_addr = 4; end
               7: begin A_addr = 13; B_addr = 15; W_addr = 6; end
            endcase
         end

         3: begin  // Stage 3 - butterflies span 1 index
            case (butterfly)
               0: begin A_addr = 0;  B_addr = 1;  W_addr = 0; end
               1: begin A_addr = 8;  B_addr = 9;  W_addr = 1; end
               2: begin A_addr = 4;  B_addr = 5;  W_addr = 2; end
               3: begin A_addr = 12; B_addr = 13; W_addr = 3; end
               4: begin A_addr = 2;  B_addr = 3;  W_addr = 4; end
               5: begin A_addr = 10; B_addr = 11; W_addr = 5; end
               6: begin A_addr = 6;  B_addr = 7;  W_addr = 6; end
               7: begin A_addr = 14; B_addr = 15; W_addr = 7; end
            endcase
         end

      endcase
   end

endmodule
