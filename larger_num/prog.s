# Store the larger of two numbers in a max variable

.global _start

_start:
    li   x10, 0x00FF    # a
    li   x11, 0x00AC    # b

    bge  x10, x11, Bigger

    mv   x7, x11        # max = b
    j    _exit

Bigger:
    mv   x7, x10        # max = a

_exit:
    j _exit
