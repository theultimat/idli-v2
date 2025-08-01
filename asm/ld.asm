    .include "test-wrapper.asm"


data:       .int 0x1234
            .int 0x5678
            .int 0x9abc
            .int 0xdef0


test_main:
    addpc   r1, @data       # ptr = &data[0]
    ld+     r2, r1          # tmp = *ptr++
    utx     r2              # uart(tmp)
    ldm     r2..r4, r1      # tmp0..tmp2 = ptr[0..2]
    utx     r2              # uart(tmp0)
    utx     r3              # uart(tmp1)
    utx     r4              # uart(tmp2)
    mov     r1, zr          # out = 0
    ret                     # return out
