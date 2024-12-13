`default_nettype none

module compareunit(
  input logic[3:0] CUFlags,
  input logic[3:0] Condition,

  output logic JumpOK
);

  logic Zero;
  logic Negative;
  logic SignedOverflow;
  logic UnsignedOverflow;

  always_comb begin
    Zero = CUFlags[0];
    Negative = CUFlags[1];
    SignedOverflow = CUFlags[2];
    UnsignedOverflow = CUFlags[3];
  end

  always_comb begin
    case(Condition)
      4'h0: JumpOK = Zero;
      4'h1: JumpOK = UnsignedOverflow;
      4'h2: JumpOK = UnsignedOverflow&~Zero;
      4'h3: JumpOK = Negative==SignedOverflow;
      4'h4: JumpOK = ~Zero&(Negative==SignedOverflow);
      4'h5: JumpOK = SignedOverflow;
      4'h6: JumpOK = ~Negative;
      4'h7: JumpOK = 0;
      4'h8: JumpOK = ~Zero;
      4'h9: JumpOK = ~(UnsignedOverflow&~Zero);
      4'hA: JumpOK = ~UnsignedOverflow;
      4'hB: JumpOK = Zero|(Negative!=SignedOverflow);
      4'hC: JumpOK = Negative!=SignedOverflow;
      4'hD: JumpOK = ~SignedOverflow;
      4'hE: JumpOK = Negative;
      4'hF: JumpOK = 0;
    endcase
  end
endmodule