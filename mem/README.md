# DE10-Lite CHIP-8 Interpreter

A CHIP-8 computer built in hardware (Verilog) on the Terasic DE10-Lite
(Intel MAX 10) FPGA. It outputs 640x480 VGA and takes input from a 4x4 keypad.

## Project structure

```text
chip8-de10lite/
├── README.md
├── .gitignore
│
├── rtl/
│
├── sim/                    # testbenches (simulation only, never in Quartus)
│
├── mem/                    # memory
│
├── roms/                   # CHIP-8 programs (.ch8)
│
└── .github/
    └── workflows/
        └── sim.yml         # runs the testbenches automatically on every push
```

**Always run commands from the repo root.**

## Simulate (Icarus Verilog)

```bash
make sim-fb      # framebuffer + VGA test
make sim-cpu     # CPU test, prints the screen as text
make test        # both
```

## References

- Tobias V. Langhoff, *Guide to making a CHIP-8 emulator*: https://tobiasvl.github.io/blog/write-a-chip-8-emulator/
- Timendus, *CHIP-8 test suite*: https://github.com/Timendus/chip8-test-suite
