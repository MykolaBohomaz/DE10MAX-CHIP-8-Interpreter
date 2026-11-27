# ROM sources, licenses and bank map

## ROM bank (`mem/rom_bank.hex`)

| SW[2:0] | Bank | ROM | Controls |
|---|---|---|---|
| 000 | 0 | Corax+ opcode test (CPU test) | none: shows a pass/fail mark per instruction |
| 001 | 1 | Br8kout | 7 / 9 move the paddle |
| 010 | 2 | Super Pong | 6 serves, 7 / 9 move the paddle |
| 011 | 3 | Dino Run | 5 jumps |
| 100 | 4 | Flight Runner | 7 / 9 steer |
| 101 | 5 | Ghost Escape | hold 0 to rise, release to sink |
| 110 | 6 | Mini Lights Out | all 16 keys: each toggles its light |
| 111 | 7 | IBM logo (first-light test) | none |

## tests/ — Timendus CHIP-8 test suite

https://github.com/Timendus/chip8-test-suite — GPL-3.0 (see `tests/LICENSE`); source code at that link.

| File | Tests |
|---|---|
| 1-chip8-logo.ch8 | 00E0, 1NNN, 6XNN, ANNN, DXYN |
| 2-ibm-logo.ch8 | Same plus 7XNN; the classic first target |
| 3-corax+.ch8 | Every opcode except keys and timers |
| 4-flags.ch8 | VF carry / borrow / shift, and write order |
| 5-quirks.ch8 | Quirk behaviour (write 1 to 0x1FF to skip the menu: `rom2hex.py --poke 0x1FF=1`) |
| 6-keypad.ch8 | EX9E, EXA1, FX0A |

## games/ — CHIP-8 Archive

https://github.com/JohnEarnest/chip8Archive — placed under Creative Commons 0 ("No Rights Reserved").

| File | Title | Author(s) |
|---|---|---|
| br8kout.ch8 | Br8kout | SharpenedSpoon |
| superpong.ch8 | Super Pong | offstatic |
| dinorun.ch8 | Dino Run | Andrezinrc |
| flightrunner.ch8 | Flight Runner | TodPunk |
| ghostEscape.ch8 | Ghost Escape | Tom Rintjema |
| mini-lights-out.ch8 | Mini Lights Out | tobiasvl |
