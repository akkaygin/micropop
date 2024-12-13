`default_nettype none

module registerbank(
  input logic Clock,
  input logic Reset,

  input logic Enable,
  
  input logic[3:0] Source1Address,
  input logic[3:0] Source2Address,
  input logic[3:0] TargetAddress,
  
  input logic TargetWriteEnable,
  input logic[15:0] TargetIn,
  
  output logic[15:0] Source1Out,
  output logic[15:0] Source2Out,

  input logic Jump,
  output logic[15:0] InstructionPointerOut
);

  logic[15:0] RegisterBank[15:0];

  always_ff@(posedge Clock) begin
    if(Reset) begin
      for(int i = 0; i < 16; i = i+1) begin
        RegisterBank[i] = '0;
      end
    end else begin
      if(Enable) begin
        if(Jump) begin
          RegisterBank[15] <= RegisterBank[15]+TargetIn;
        end else begin
          if(TargetWriteEnable) begin
            if(TargetAddress != 0) begin
              RegisterBank[TargetAddress] <= TargetIn;
            end
          end

          RegisterBank[15] <= RegisterBank[15]+2;
        end
      end
    end
  end

  always_comb begin
    Source1Out = RegisterBank[Source1Address];
    Source2Out = RegisterBank[Source2Address];
    InstructionPointerOut = RegisterBank[15];
  end
endmodule