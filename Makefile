# Run every target from the repo root.
IVERILOG = iverilog -g2005 -Wall

.PHONY: sim-fb test clean

# framebuffer (fb_mem) testbench
sim-fb:
	$(IVERILOG) -o sim/fb_mem_tb.vvp sim/fb_mem_tb.v rtl/mem/fb_mem.v
	vvp -n sim/fb_mem_tb.vvp

# every testbench (add new sim-* targets here as they are written)
test: sim-fb

clean:
	rm -f sim/*.vvp sim/*.vcd
