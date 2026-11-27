#!/usr/bin/env python3
"""
rom2hex.py - pack CHIP-8 programs into memory images for the DE10-Lite project.

Usage:
    # one game -> 4 KB image (early milestones, simulation)
    python3 rom2hex.py 2-ibm-logo.ch8 -o ram_init

    # up to 8 games -> 32 KB ROM bank, bank N at address N*4096
    python3 rom2hex.py pong.ch8 breakout.ch8 tetris.ch8 -o rom_bank --banks 8
"""
import argparse
import os
import sys

FONT = [
    0xF0, 0x90, 0x90, 0x90, 0xF0,  # 0
    0x20, 0x60, 0x20, 0x20, 0x70,  # 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0,  # 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0,  # 3
    0x90, 0x90, 0xF0, 0x10, 0x10,  # 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0,  # 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0,  # 6
    0xF0, 0x10, 0x20, 0x40, 0x40,  # 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0,  # 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0,  # 9
    0xF0, 0x90, 0xF0, 0x90, 0x90,  # A
    0xE0, 0x90, 0xE0, 0x90, 0xE0,  # B
    0xF0, 0x80, 0x80, 0x80, 0xF0,  # C
    0xE0, 0x90, 0x90, 0x90, 0xE0,  # D
    0xF0, 0x80, 0xF0, 0x80, 0xF0,  # E
    0xF0, 0x80, 0xF0, 0x80, 0x80,  # F
]
FONT_BASE = 0x050
PROG_BASE = 0x200
BANK_SIZE = 4096


def make_bank(rom_path, pokes):
    mem = bytearray(BANK_SIZE)
    mem[FONT_BASE:FONT_BASE + len(FONT)] = bytes(FONT)
    if rom_path is not None:
        data = open(rom_path, "rb").read()
        if len(data) > BANK_SIZE - PROG_BASE:
            sys.exit(f"error: {rom_path} is {len(data)} bytes, max is {BANK_SIZE - PROG_BASE}")
        mem[PROG_BASE:PROG_BASE + len(data)] = data
    for addr, val in pokes:
        mem[addr] = val
    return mem


def write_hex(path, mem):
    with open(path, "w") as f:
        for b in mem:
            f.write(f"{b:02X}\n")


def write_mif(path, mem):
    with open(path, "w") as f:
        f.write(f"WIDTH=8;\nDEPTH={len(mem)};\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n")
        for a, b in enumerate(mem):
            f.write(f"    {a:04X} : {b:02X};\n")
        f.write("END;\n")


def parse_poke(s):
    addr, val = s.split("=")
    return int(addr, 0), int(val, 0)


def main():
    ap = argparse.ArgumentParser(description="Pack CHIP-8 ROMs into $readmemh / .mif images")
    ap.add_argument("roms", nargs="+", help=".ch8 files, one per bank, in bank order")
    ap.add_argument("-o", "--out", default="ram_init", help="output base name (default ram_init)")
    ap.add_argument("--banks", type=int, default=None,
                    help="total banks to emit (power of 2; empty banks get font only). "
                         "Default: 1 if one ROM, else next power of 2")
    ap.add_argument("--poke", action="append", default=[], type=parse_poke,
                    help="ADDR=VAL written into every bank after loading, e.g. 0x1FF=1")
    args = ap.parse_args()

    n = len(args.roms)
    banks = args.banks or (1 if n == 1 else 1 << (n - 1).bit_length())
    if banks < n or banks & (banks - 1):
        sys.exit("error: --banks must be a power of 2 and >= number of ROMs")

    image = bytearray()
    for i in range(banks):
        rom = args.roms[i] if i < n else None
        image += make_bank(rom, args.poke)

    write_hex(args.out + ".hex", image)
    write_mif(args.out + ".mif", image)

    print(f"{args.out}.hex / .mif : {banks} bank(s) x 4096 bytes = {len(image)} bytes "
          f"(address width {(len(image) - 1).bit_length()} bits)")
    for i in range(banks):
        name = os.path.basename(args.roms[i]) if i < n else "(empty)"
        size = os.path.getsize(args.roms[i]) if i < n else 0
        print(f"  bank {i}  SW={i:03b}  {name}  {size} bytes")


if __name__ == "__main__":
    main()
