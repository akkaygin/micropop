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
unsigned StepTarget = 0;
bool Trace = true;

void ClockPosedge() {
  CycleCount += 1;
  if(Trace) tfp->dump(CycleCount*10-2);
  Micropop->eval();
  Micropop->Clock = 1;
  Micropop->eval();
  if(Trace) tfp->dump(CycleCount*10);
}

void ClockNegedge() {
  Micropop->Clock = 0;
  Micropop->eval();
  if(Trace) tfp->dump(CycleCount*10+5);
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

  //uint16_t Instr[] = {0x4084, 0x4104, 0x4184, 0x4204, 0x4284, 0x4304, 0x4384, 0x4404};
  ResetSystem();

  for(int i = 0; i < 16; i += 2) {
    uint16_t Instr = 0x4004|(1<<7);
    Micropop->rootp->micropop__DOT__InsturctionMemory__DOT__Memory[i] = Instr&0xFF;
    Micropop->rootp->micropop__DOT__InsturctionMemory__DOT__Memory[i+1] = Instr>>8;
  }

  StepTarget = 16;

  while(CycleCount < StepTarget) {
    ClockCycle();
  }

  tfp->close();

  return 0;
}