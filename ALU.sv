`default_nettype none

module alu(
  input logic[2:0] Operation,
  input logic[15:0] Operand1,
  input logic[15:0] Operand2,

  output logic[3:0] Flags,
  output logic[15:0] Result
);

  logic Zero;
  logic Negative;
  logic SignedOverflow;
  logic UnsignedOverflow;

  always_comb begin
    UnsignedOverflow = 0;
    case(Operation)
      3'h0: {UnsignedOverflow, Result} = Operand1 + Operand2;
      3'h1: {Result, UnsignedOverflow} = Operand1 - Operand2;
      3'h2: Result = Operand1 << Operand2;
      3'h3: Result = Operand1 >> Operand2;
      3'h4: Result = Operand1 >>> Operand2;
      3'h5: Result = Operand1 & Operand2;
      3'h6: Result = Operand1 | Operand2;
      3'h7: Result = Operand1 ^ Operand2;
    endcase
  end

  always_comb begin
    Zero = ~|Result;
    Negative = Result[15];
    SignedOverflow = (Operand1[14]&Operand2[14]&~Result[14])
                   | (~Operand1[14]&~Operand2[14]&Result[14]);
    
    Flags = {UnsignedOverflow, SignedOverflow, Negative, Zero};
  end

endmodule