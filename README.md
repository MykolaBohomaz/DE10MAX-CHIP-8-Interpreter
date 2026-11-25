chip8-de10lite/
├── README.md               # what it is, how to build, how to play
├── .gitignore              # keeps Quartus's generated junk out
├── Makefile                # shortcuts: make sim-cpu, make rom ROM=roms/pong.ch8
│
├── chip8.qpf               # Quartus project file
├── chip8.qsf               # Quartus settings + pin assignments
├── chip8.sdc               # timing constraint (the 50 MHz clock)
│
├── rtl/                    # the actual hardware (what goes on the FPGA)
│   ├── chip8_top.v         #   top level: wires everything together
│   ├── chip8_cpu.v         #   CPU
│   ├── chip8_mem.v         #   4 KB RAM
│   ├── framebuffer.v       #   64x32 screen memory
│   ├── vga_ctrl.v          #   VGA output
│   ├── hex7seg.v           #   7-segment driver
│   ├── keypad.v            #   (to do) 4x4 keypad scanner
│   ├── sound.v             #   (to do) buzzer
│   └── test/
│       └── de10lite_fb_test.v   # standalone framebuffer test top level
│
├── sim/                    # testbenches (simulation only, never in Quartus)
│   ├── tb_fb.v
│   └── tb_cpu.v
│
├── mem/                    # memory start-up images Quartus loads at compile time
│   ├── rom.hex             #   font + current game (generated, but committed
│   └── fb_init.txt         #   so a fresh clone compiles right away)
│
├── roms/                   # CHIP-8 programs (.ch8)
│   ├── test_draw.ch8
│   └── ...                 #   test ROMs and games you're allowed to share
│
├── tools/                  # helper scripts
│   ├── make_rom.py
│   ├── make_test_rom.py
│   └── make_fb_init.py
│
├── docs/                   # for the team and the report
│   ├── interfaces.md       #   the agreed ports between modules
│   ├── block_diagram.png
│   └── progress.md         #   which instructions are done / tested
│
└── .github/
    └── workflows/
        └── sim.yml         # runs the testbenches automatically on every push