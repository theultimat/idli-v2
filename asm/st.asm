    .include "test-wrapper.asm"


data:   .space 4


test_main:
    addpc   r1, @data       # ptr = &data[0]
    inc     r1, r1          # ptr++
    urx     r2              # tmp = uart()
    st      r2, r1, -1      # ptr[-1] = tmp
    urx     r2              # tmp = uart()
    -st     r2, r1          # *(--ptr) = tmp
    urx     r3              # tmp0 = uart()
    urx     r4              # tmp1 = uart()
    urx     r5              # tmp2 = uart()
    urx     r6              # tmp3 = uart()
    stm     r3..r6, r1      # ptr[0..3] = tmp0..tmp3
    mov     r1, zr          # out = 0
    ret                     # return 0
