# Swapping variables between registers without a temporary variable
# x5 = a, x6 = b -> after: x5 = b, x6 = a

.global _start

_start:
    xor x5, x5, x6
    xor x6, x5, x6
    xor x5, x5, x6
