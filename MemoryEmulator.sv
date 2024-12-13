`default_nettype none

module memoryemulator#(
  parameter DELAY = 1
)(
  input logic Clock,
  input logic Reset,

  input logic ReadEnable,
  input logic WriteEnable,

  input logic DataWidth,

  output logic ReadReady,
  output logic WriteReady,

  output logic[15:0] DataOut,
  input logic[15:0] DataIn,
  input logic[15:0] DataAddress
);

  logic[7:0] Memory[0:2**16-1];
  
  generate if(DELAY > 0) begin
    logic[1:0] State;
    logic[$clog2(DELAY):0] DelayCounter;

    always_ff@(posedge Clock) begin
      if(Reset) begin
        for(int i = 0; i < 512; i += 1) begin
          Memory[i] = 0;
        end

        State <= 0;
        ReadReady <= 0;
        WriteReady <= 0;

        DelayCounter <= 0;
      end else begin
        if(State == 0) begin
          if(ReadEnable) begin
            State <= 1;
          end else if(WriteEnable) begin
            State <= 2;
          end

          ReadReady <= 0;
          WriteReady <= 0;

          DelayCounter <= 0;
        end else if(State == 1) begin
          if({1'b0, DelayCounter} == DELAY-1) begin
            if(DataWidth) begin
              DataOut[7:0] <= Memory[DataAddress];
              DataOut[15:8] <= Memory[DataAddress+1];
            end else begin
              DataOut[7:0] <= Memory[DataAddress];
              DataOut[15:8] <= 8'h00;
            end

            ReadReady <= 1;
            State <= 0;
          end

          DelayCounter <= DelayCounter+1;
        end else if(State == 2) begin
          if({1'b0, DelayCounter} == DELAY-1) begin
            if(DataWidth) begin
              Memory[DataAddress+1] <= DataIn[15:8];
              Memory[DataAddress] <= DataIn[7:0];
            end else begin
              Memory[DataAddress] <= DataIn[7:0];
            end

            WriteReady <= 1;
            State <= 0;
          end

          DelayCounter <= DelayCounter+1;
        end else begin
          State <= 0;
        end
      end
    end
  end else begin
    always_ff@(posedge Clock) begin
      if(Reset) begin
        for(int i = 0; i < 512; i += 1) begin
          Memory[i] = 0;
        end

        ReadReady <= 0;
        WriteReady <= 0;
      end else begin
        if(ReadEnable) begin
          if(DataWidth) begin
            DataOut[7:0] <= Memory[DataAddress];
            DataOut[15:8] <= Memory[DataAddress+1];
          end else begin
            DataOut[7:0] <= Memory[DataAddress];
            DataOut[15:8] <= 8'h00;
          end

          ReadReady <= 1;
        end else if(WriteEnable) begin
          if(DataWidth) begin
            Memory[DataAddress+1] <= DataIn[15:8];
            Memory[DataAddress] <= DataIn[7:0];
          end else begin
            Memory[DataAddress] <= DataIn[7:0];
          end

          WriteReady <= 1;
        end else begin
          ReadReady <= 0;
          WriteReady <= 0;
        end
      end
    end
  end endgenerate
endmodule