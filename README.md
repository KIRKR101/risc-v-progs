## Setup for macOS

```bash
brew install riscv-gnu-toolchain qemu riscv64-elf-gdb
```

`qemu-riscv64` (linux-user mode) doesn't work on macOS, it needs Linux syscall translation. Use `qemu-system-riscv64` (full-system emulation) instead.

## Linker script

`link.ld`:

```ld
OUTPUT_ARCH(riscv)
ENTRY(_start)
SECTIONS
{
  . = 0x80000000;
  .text : { *(.text*) }
  .data : { *(.data*) }
  .bss  : { *(.bss*) }
}
```

`0x80000000` is QEMU `virt`'s reset PC after the mask ROM at `0x1000` jumps to it.

## Build

```bash
riscv64-unknown-elf-as -o prog.o prog.s
riscv64-unknown-elf-ld -T link.ld -o prog.elf prog.o
```

## Run

**Interactive debugging (default):**

```bash
qemu-system-riscv64 -nographic -machine virt -bios none -kernel prog.elf -s -S
```

In another tab:

```bash
riscv64-elf-gdb prog.elf
```

```
target remote :1234
layout asm
layout regs
stepi
info registers
```

Each command needs its own `Enter`. `stepi` steps one instruction at a time; `layout regs` shows live registers alongside disassembly.

**Trace log (non-interactive, dumps every instruction to a file):**

```bash
qemu-system-riscv64 -nographic -machine virt -bios none -kernel prog.elf -d in_asm,exec -D trace.log
```

## Output

Bare-metal on `virt` has no `write` syscall so write bytes directly to the NS16550 UART at `0x10000000`.

```asm
.equ UART, 0x10000000

.section .text
.global _start
_start:
    la a0, msg
    call puts
    j _exit

puts:
    li t0, UART
1:
    lb t1, 0(a0)
    beqz t1, 2f
    sb t1, 0(t0)
    addi a0, a0, 1
    j 1b
2:
    ret

_exit:
    j _exit

.section .data
msg:
    .asciz "Hello, RISC-V!\n"
```

## Halting

Use an infinite loop:

```asm
_exit:
    j _exit
```

This is the expected steady state — QEMU links the trace buffer back to itself once the program halts.

If OpenSBI is loaded (drop `-bios none`), a proper shutdown is available via SBI:

```asm
li a7, 8      # SBI_SHUTDOWN
ecall
```

## Example program

```asm
# Extract byte fields from a packed word
# x10 = 0xAABBCCDD, split into four registers

.global _start

_start:
    li   x10, 0xAABBCCDD
    andi x11, x10, 0xFF        # x11 = 0x000000DD (byte 0)
    srli x12, x10, 8
    andi x12, x12, 0xFF        # x12 = 0x000000CC (byte 1)
    srli x13, x10, 16
    andi x13, x13, 0xFF        # x13 = 0x000000BB (byte 2)
    srli x14, x10, 24          # x14 = 0x000000AA (byte 3, no mask needed)

_exit:
    j _exit
```
