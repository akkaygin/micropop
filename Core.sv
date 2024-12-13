`default_nettype none

module core(
  input logic MainClock,
  input logic Reset,

  input logic InstructionReady,
  input logic[15:0] Instruction,
  output logic[15:0] InstructionAddress,

  output logic DataWidth,

  input logic ReadReady,
  input logic WriteReady,

  input logic[15:0] DataIn,
  output logic[15:0] DataOut,
  output logic[15:0] DataAddress
);

  logic Clock;
  assign Clock = MainClock&InstructionReady;

  logic[15:0] CoreControlRegister;
  logic[1:0] CoreState;

  logic Enable;

  logic[3:0] Source1Address;
  logic[3:0] Source2Address;
  logic[3:0] TargetAddress;

  logic TargetWriteEnable;
  logic[15:0] TargetIn;

  logic[15:0] Source1Out;
  logic[15:0] Source2Out;

  logic Jump;
  logic[15:0] InstructionPointerOut;

  always_comb begin
    Enable = CoreState == 0;

    if(Instruction[2:0] == 3'b011) begin
      TargetAddress = Instruction[9:6];
    end else begin
      TargetAddress = {2'h0, Instruction[15:14]};
    end

    if(Instruction[2:0] == 3'b100) begin
      Source1Address = {2'd0, Instruction[15:14]};
    end else begin
      Source1Address = Instruction[13:10];
    end

    Source2Address = Instruction[9:6];

    TargetWriteEnable = (Instruction[1:0] != 2)|(Instruction[1:0] != 1)|ReadReady;

    Jump = JumpOK&(Instruction[1:0] == 1);
  end

  registerbank RegisterBank(
    Clock,
    Reset,

    Enable,

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

  logic[15:0] Embedded1;
  logic[15:0] Embedded2;
  logic[15:0] Embedded3;
  
  logic[2:0] Operation;

  logic[15:0] ALUOperand1;
  logic[15:0] ALUOperand2;

  logic[3:0] ALUFlags;
  logic[15:0] ALUResult;

  always_comb begin
    Embedded1 = {{9{Instruction[6]}}, Instruction[13:7]};
    Embedded2 = {{7{Instruction[6]}}, Instruction[15:14], Instruction[13:7]};
    Embedded3 = {{11{Instruction[6]}}, Instruction[15:14], Instruction[9:7]};
  end

  always_comb begin
    Operation = Instruction[5:3];

    if(Instruction[2] == 0) begin
      ALUOperand1 = Source1Out;
      ALUOperand2 = Source2Out;
    end else begin
      ALUOperand1 = Source1Out;
      ALUOperand2 = Embedded1;
    end
  end

  alu ALU(
    Operation,
    ALUOperand1,
    ALUOperand2,

    ALUFlags,
    ALUResult
  );

  logic[3:0] CUFlags;
  logic[3:0] Condition;

  logic JumpOK;

  always_comb begin
    CUFlags = CoreControlRegister[3:0];
    Condition = Instruction[5:2];
  end

  compareunit CU(
    CUFlags,
    Condition,

    JumpOK
  );

  always_ff@(posedge Clock) begin
    if(Reset) begin
      CoreControlRegister <= '0;
      CoreState <= 0;
    end else begin
      if(CoreState == 0) begin
        CoreControlRegister[3:0] <= ALUFlags;

        if(Instruction[2:0] == 3'b010) begin
          CoreState <= 1;
        end else if(Instruction[2:0] == 3'b110) begin
          CoreState <= 2;
        end else if(Instruction[2:0] == 3'b010) begin
          CoreState <= 3;
        end

        DataWidth <= Instruction[3];
      end else if(CoreState == 1) begin
        if(ReadReady) begin
          CoreState <= 0;
        end
      end else if(CoreState == 2) begin
        if(WriteReady) begin
          CoreState <= 0;
        end
      end else begin
        // Interrupt, maybe.
      end
    end
  end

  always_comb begin
    TargetIn = 0;
    if(CoreState == 0) begin
      if(Instruction[1:0] == 0) begin
        TargetIn = ALUResult;
      end else if(Instruction[1:0] == 1) begin
        TargetIn = Embedded2;
      end else if(Instruction[1:0] == 2) begin
        TargetIn = 0;
      end else begin
        TargetIn = Source1Out;
      end
    end else if(CoreState == 1) begin
      if(InstructionReady)
      TargetIn = DataIn;
    end else begin
      TargetIn = 0;
    end
  end

  always_comb begin
    InstructionAddress = InstructionPointerOut;
  end
endmodule