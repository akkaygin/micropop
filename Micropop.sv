`default_nettype none

module micropop(
  input logic Clock,
  input logic Reset
);

  core CoreOne(
    Clock,
    Reset,

    16'h4084
  );
endmodule