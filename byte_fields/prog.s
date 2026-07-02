# Extract byte fields from a packed word
# x10 = 0xAABBCCDD, split into four registers

.global _start

_start:
    # x10 = 0xAABBCCDD, split into four registers
    li   x10, 0xAABBCCDD
    andi x11, x10, 0xFF        # x11 = 0x000000DD (byte 0)
    srli x12, x10, 8
    andi x12, x12, 0xFF        # x12 = 0x000000CC (byte 1)
    srli x13, x10, 16
    andi x13, x13, 0xFF        # x13 = 0x000000BB (byte 2)
    srli x14, x10, 24          # x14 = 0x000000AA (byte 3, no mask needed)

_exit:
    j _exit
