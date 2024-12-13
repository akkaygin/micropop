SVFILES := Micropop.sv Core.sv RegisterBank.sv ALU.sv CompareUnit.sv MemoryEmulator.sv
VERILATOR_FLAGS := -O2 -sv --cc --exe --trace -x-assign fast --build -j 0

all:
	verilator $(VERILATOR_FLAGS) $(SVFILES) Driver.cpp -o Micropop --Mdir Build/ --top-module micropop

run: all
	./Build/Micropop
