    .include "test-wrapper.asm"


    .org 0x600

func:
    ret


    .org 0x500

test_main:
    mov     r2, lr
    bl      @func
    j       r2
