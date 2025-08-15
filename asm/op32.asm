    .include "test-wrapper.asm"


test_main:
    urx     r1              # x0 = uart()
    urx     r2              # x1 = uart()
    urx     r3              # y0 = uart()
    urx     r4              # y1 = uart()
    carry   2
    add     r5, r1, r3      # z = x + y
    add     r6, r2, r4
    utx     r5              # uart(z0)
    utx     r6              # uart(z1)
    carry   2
    sub     r5, r1, r3      # z = x - y
    sub     r6, r2, r4
    utx     r5              # uart(z0)
    utx     r6              # uart(z1)
    carry   2
    srl     r6, r2          # z = x >> 1
    srl     r5, r1
    utx     r5              # uart(z0)
    utx     r6              # uart(z1)
    carry   2
    sra     r6, r2          # z = x >>> 1
    sra     r5, r1
    utx     r5              # uart(z0)
    utx     r6              # uart(z1)
    mov     r1, zr
    ret
