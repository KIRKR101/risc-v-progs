# Reverse an array in-place
# Each integer occupies 4 bytes

.global _start

_start:
    li   x8, 0x1000      # base address of array
    li   x11, 10         # n = 10

    addi x9, x0, 0       # i = 0
    addi x10, x11, -1    # j = n - 1

Loop:
    bge  x9, x10, _exit   # while (i < j)

    # load arr[i]
    slli x12, x9, 2      # i * 4
    add  x12, x8, x12    # &arr[i]
    lw   x13, 0(x12)     # x13 = arr[i]

    # load arr[j]
    slli x5, x10, 2
    add  x5, x8, x5
    lw   x6, 0(x5)

    # swap
    sw   x6, 0(x12)
    sw   x13, 0(x5)

    # i++, j--
    addi x9, x9, 1
    addi x10, x10, -1

    j Loop

_exit:
    j _exit
