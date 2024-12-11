#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vmicropop.h"
#include "Vmicropop___024root.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

Vmicropop* Micropop;
VerilatedVcdC* tfp;

unsigned CycleCount = 0;
unsigned StepsRemaining = 0;

void ClockPosedge() {
  CycleCount += 1;
  tfp->dump(CycleCount*10-2);
  Micropop->eval();
  Micropop->Clock = 1;
  Micropop->eval();
  tfp->dump(CycleCount*10);
}

void ClockNegedge() {
  Micropop->Clock = 0;
  Micropop->eval();
  tfp->dump(CycleCount*10+5);
}

void ClockCycle() {
  ClockPosedge();
  ClockNegedge();
}

void ResetSystem() {
  Micropop->Reset = 1;
  ClockCycle();
  ClockCycle();
  Micropop->Reset = 0;
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Micropop = new Vmicropop;

  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  Micropop->trace(tfp, 99);
  tfp->open("trace.vcd");

  ResetSystem();

  StepsRemaining = 16;

  while(StepsRemaining > 0) {
    ClockCycle();
    StepsRemaining -= 1;
  }

  tfp->close();

  return 0;
}