`default_nettype none

module alu(
  input logic Clock,

  input logic[2:0] Operation,
  input logic[15:0] Operand1,
  input logic[15:0] Operand2,

  output logic[3:0] Flags,
  output logic[15:0] Result
);

  // Temporary ALU
  always_ff@(posedge Clock) begin
    case(Operation)
      3'h0: Result <= Operand1 + Operand2;
      3'h1: Result <= Operand1 - Operand2;
      3'h2: Result <= Operand1 << Operand2;
      3'h3: Result <= Operand1 >> Operand2;
      3'h4: Result <= Operand1 >>> Operand2;
      3'h5: Result <= Operand1 & Operand2;
      3'h6: Result <= Operand1 | Operand2;
      3'h7: Result <= Operand1 ^ Operand2;
    endcase
  end
endmodule