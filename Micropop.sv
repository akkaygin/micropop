`default_nettype none

module micropop(
  input logic Clock,
  input logic Reset
);

  logic InstructionReady;
  logic[15:0] Instruction;
  logic[15:0] InstructionAddress;

  logic ReadReady;
  logic WriteReady;

  logic DataWidth;

  logic ReadEnable;
  logic WriteEnable;

  logic[15:0] DataIn;
  logic[15:0] DataOut;
  logic[15:0] DataAddress;

  core CoreOne(
    Clock,
    Reset,

    InstructionReady,
    Instruction,
    InstructionAddress,

    DataWidth,

    ReadReady,
    WriteReady,

    DataIn,
    DataOut,
    DataAddress
  );

  memoryemulator#(0) InsturctionMemory(
    Clock,
    0,

    1,
    0,

    1,

    InstructionReady,
    ,

    Instruction,
    0,
    InstructionAddress
  );

  memoryemulator#(4) DataMemory(
    Clock,
    Reset,

    ReadEnable,
    WriteEnable,

    DataWidth,

    ReadReady,
    WriteReady,

    DataIn,
    DataOut,
    DataAddress
  );
endmodule