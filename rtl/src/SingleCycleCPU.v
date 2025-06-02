module SingleCycleCPU (
    input clk,
    input start,
    output [31:0]ALUResult, inst, PC_out, PC_in, PCPlus4,PCTarget,
    writeData,readData,
    output branch,
    output jump,
    output memRead,
    output [1:0]resultSRC,
    output [1:0] ALUOp,
    output memWrite,
    output ALUSrc,
    output regWrite,
    output reg [31:0]SrcA,
    output [31:0]SrcB,Result,
    output [3:0]ALUCtl,
    output opp,functt,
    output PCSrc,
    output [6:0] funct7, op,
    output [2:0] funct3
    
);

assign opp = inst[5];
assign functt = inst[5];
// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,


PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(PC_in),
    .pc_o(PC_out)
);


Adder m_Adder_1(
    .a(PC_out),
    .b(32'd4),
    .sum(PCPlus4)
);

//wire [31:0] inst;
InstructionMemory m_InstMem(
    .readAddr(PC_out),
    .inst(inst)
);

/*wire branch;
wire jump;
wire memRead;
wire [1:0]resultSRC;
wire [1:0] ALUOp;
wire memWrite;
wire ALUSrc;
wire regWrite;*/
Control m_Control(
    .opcode(inst[6:0]),
    .branch(branch),
    .jump(jump),
    .memRead(memRead),
    .resultSRC(resultSRC),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);

always @(*) begin
    if (ALUCtl == 4'b1011) 
        SrcA = PC_out;  // AUIPC case
    else 
        SrcA = readData1;
end

//wire [31:0]Result;
//wire [31:0]SrcA;
//wire [31:0]writeData;
wire [31:0]readData1;
Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(inst[19:15]),
    .readReg2(inst[24:20]),
    .writeReg(inst[11:7]),
    .writeData(Result),
    .readData1(readData1),
    .readData2(writeData)
);


wire [31:0]imm;
ImmGen #(.Width(32)) m_ImmGen(
    .inst(inst),
    .imm(imm)
);

Adder m_Adder_2(
    .a(PC_out),
    .b(imm),
    .sum(PCTarget)
);

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PCSrc),
    .s0(PCPlus4),
    .s1(PCTarget),
    .out(PC_in)
);

//wire [31:0]SrcB;
Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc),
    .s0(writeData),
    .s1(imm),
    .out(SrcB)
);
wire [2:0]storeSize,loadSize;
//wire [3:0]ALUCtl;
//wire [6:0] funct7, op;
//wire [2:0] funct3;

assign funct7=inst[6:0];
assign op=inst[31:25];
assign funct3=inst[14:12];

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(inst[6:0]),
    .op(inst[31:25]),
    .funct3(inst[14:12]),
    .ALUCtl(ALUCtl)
);

wire invert;
//wire [31:0]ALUResult;
ALU m_ALU(
    .ALUCtl(ALUCtl),
    .A(SrcA),
    .B(SrcB),
    .invert(invert),
    .ALUOut(ALUResult),
    .zero(zero)
);
//wire PCSrc;
BranchLogic brancher(
    branch, jump, zero, inst, ALUResult, PCSrc);
//wire [31:0] readData;
DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(ALUResult),
    .writeData(writeData),
    .inst(inst),
    .readData(readData)
);

assign Result = (resultSRC==2'b00)? ALUResult :
                ((resultSRC==2'b01)? readData :PCPlus4);
                
endmodule
