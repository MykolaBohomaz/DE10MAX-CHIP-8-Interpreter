# mem/

Memory initialisation files (`.hex`) loaded with `$readmemh`.
Not Verilog: the memory *modules* are in `rtl/mem/`.

- `rom.hex`  – font at 0x050 + a small test program at 0x200 (used by `chip8_mem`)
- `font.hex` – the font on its own

Paths inside the Verilog (e.g. `"mem/rom.hex"`) are relative to the repo root,
so always run simulations from the repo root.
