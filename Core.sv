`default_nettype none

module core(
  input logic Clock,
  input logic Reset,

  input logic[15:0] Instruction
);

  logic[15:0] CoreControlRegister;
  always_ff@(Clock) begin
    if(Reset) begin
      CoreControlRegister <= '0;
    end
  end

  logic[3:0] Source1Address;
  logic[3:0] Source2Address;
  logic[1:0] TargetAddress;

  logic TargetWriteEnable;
  logic[15:0] TargetIn;

  logic[15:0] Source1Out;
  logic[15:0] Source2Out;

  logic Jump;
  logic[15:0] InstructionPointerOut;

  always_comb begin
    TargetAddress = Instruction[15:14];

    if(Instruction[2:0] == 3'b100) begin
      Source1Address = {2'd0, Instruction[15:14]};
    end else begin
      Source1Address = Instruction[13:10];
    end

    Source2Address = Instruction[9:6];

    TargetWriteEnable = 1;

    Jump = Instruction[1:0] == 2'b01;
  end

  registerbank RegisterBank(
    Clock,
    Reset,

    Source1Address,
    Source2Address,
    TargetAddress,

    TargetWriteEnable,
    TargetIn,

    Source1Out,
    Source2Out,

    Jump,
    InstructionPointerOut
  );

  logic[2:0] Operation;
  
  logic[15:0] Embedded1;
  logic[15:0] Embedded2;
  logic[15:0] Embedded3;

  logic[15:0] ALUOperand1;
  logic[15:0] ALUOperand2;

  logic[3:0] ALUFlags;
  logic[15:0] ALUResult;

  always_comb begin
    Operation = Instruction[5:3];
    Embedded1 = {{9{Instruction[6]}}, Instruction[13:7]};
    Embedded2 = {{7{Instruction[6]}}, Instruction[15:14], Instruction[13:7]};
    Embedded2 = {{11{Instruction[6]}}, Instruction[15:14], Instruction[9:7]};
  end

  always_comb begin
    if(Instruction[2] == 0) begin
      ALUOperand1 = Source1Out;
      ALUOperand2 = Source2Out;
    end else begin
      ALUOperand1 = Source1Out;
      ALUOperand2 = Embedded1;
    end
  end

  alu ALU(
    Clock,

    Operation,
    ALUOperand1,
    ALUOperand2,

    ALUFlags,
    ALUResult
  );

  assign TargetIn = ALUResult;
endmodule