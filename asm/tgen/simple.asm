    .include "../test-wrapper.asm"

test_main:
    add r1, zr, 0x61ff
    add r2, zr, 0x5d52
    add r3, zr, 0x29ef
    add r4, zr, 0xf8b0
    add r5, zr, 0xdbc1
    add r6, zr, 0x9c1c
    add r7, zr, 0x56bf
    add r8, zr, 0xc011
    add r9, zr, 0x69eb
    add r10, zr, 0x9d5b
    add r11, zr, 0xb0c4
    add r12, zr, 0x7e3
    add r13, zr, 0x14d5
    add lr, zr, 0xbae4
    add sp, zr, 0xfe4c
    ltu r9, r12
    eqx r3, r8
    andn.t r9, r3, r13
    rol zr, r10
    getp r4
    ror r11, r9
    xor r6, r2, r2
    sub r7, r12, zr
    getp r3
    eq r2, r8
    eqx sp, r9
    ror.t r8, r12
    lt r2, zr
    xor r4, r13, r6
    or r4, r6, r9
    cex 6
    orp.t 6
    andp.t 12
    any.f r10, r3
    ltu.f r4, r3
    ltu.f r9, lr
    rol.t r8, r1
    ge r12, r2
    andn r7, r2, zr
    ltu r9, r7
    andp 0
    putp r3
    ltux r6, r12
    carry.t 2
    ltx r7, r13
    ror.t r11, r11
    geu r7, r6
    gex r11, lr
    ltu.t r8, r12
    or r8, lr, r3
    lt zr, r12
    not r1, r7
    sra r4, r2
    anyx r9, r9
    rol.t r12, r10
    add r13, r3, r8
    and r7, r5, lr
    ltx r13, lr
    and.t r12, r1, 0x4aae
    ne lr, r9
    andp 14
    anyx r2, r6
    or.t lr, r8, r12
    rol r12, r10
    anyx r13, r9
    sub.t r8, r13, r9
    andn r5, r4, r9
    rol r8, r2
    any r6, zr
    cex 3
    eq.f r3, r8
    eq.t r13, r6
    xor.f r3, r3, lr
    add r5, r9, r6
    gex r4, r3
    add.t r9, r3, lr
    sub r10, r9, r2
    gex zr, r11
    andn.t r5, r1, r5
    carry 13
    rol sp, r7
    addpc zr, r13
    ltu r11, r6
    lt r5, r11
    srl zr, r8
    carry 0
    eqx r5, lr
    getp.t r9
    ltux r4, zr
    srl.t r4, r4
    eqx r12, r12
    ne.t zr, r10
    sra r7, r2
    cex 1
    orp.t 7
    ne r4, r1
    geu r4, r8
    inc r6, r10
    anyx r8, r11
    add.t r6, r7, lr
    eqx r10, 0x89cb
    orp.t 6
    sub r10, r8, r10
    sub r9, r11, r3
    ltx lr, r11
    geu.t r10, r4
    anyx r13, r13
    srl.t r7, r1
    putp zr
    inc r10, r12
    ltux r1, r12
    or.t r13, r11, r12
    eqx r1, lr
    ge.t sp, r12
    cex 5
    lt.t r8, r11
    and.f r8, sp, zr
    dec.f r3, sp
    sub.f r4, lr, r9
    dec.t zr, r4
    cex 2
    srl.f r4, r10
    putp.f r12
    any r1, lr
    dec r4, lr
    ne r11, r4
    and r11, r2, zr
    ne r2, r3
    orp 0
    dec r6, r13
    add r11, r7, r6
    geux r12, r11
    addpc.t r9, lr
    rol r10, r13
    orp 6
    ltx r5, 0x756d
    ne.t r1, r11
    dec r4, zr
    lt r11, r13
    nex r3, r2
    dec.t r8, r12
    anyx r7, r1
    inc.t r4, sp
    getp r9
    eq r10, r3
    andp 13
    or r3, sp, r1
    getp r3
    sra lr, r10
    add r2, r10, r10
    putp r10
    geu r6, r5
    or r12, r3, r2
    getp r11
    dec sp, sp
    sra r7, zr
    putp r3
    carry 3
    carry 11
    geu r8, r6
    or r3, zr, r6
    ge r2, r2
    sra sp, r6
    cex 1
    ge.t r11, r2
    inc r1, lr
    addpc sp, r11
    sub zr, r2, r5
    srl lr, r6
    sub sp, r4, r4
    getp r3
    srl lr, r3
    and r4, r4, r7
    ne lr, lr
    eqx sp, r12
    or.t r12, lr, 0x473a
    eq r3, r10
    carry 7
    addpc r5, r9
    geu r9, r11
    anyx r11, r5
    ne.t lr, 0x6efa
    ltu sp, r1
    ne r2, r5
    getp r7
    cex 6
    sra.t r6, r6
    rol.f zr, lr
    inc.f r6, r12
    sra.f r6, r13
    orp.f 15
    sub.t r11, r8, r13
    eqx r9, r11
    and.t r8, r1, r2
    gex r4, r10
    ltu.t r9, r9
    lt r4, 0x43bc
    anyx r1, r1
    rol.t r7, r3
    gex sp, r10
    any.t r3, r9
    geux r5, r2
    getp.t r1
    ltux r9, r10
    lt.t r7, r2
    anyx r8, r10
    any.t r4, r3
    addpc r10, r10
    not r3, lr
    getp r8
    xor r13, lr, r6
    carry 11
    inc r11, r2
    and r3, r10, r10
    andn r5, r10, r13
    ge r1, lr
    not sp, r9
    nex r5, r11
    sub.t r10, r10, r11
    putp 0xac27
    srl r12, r13
    ltx r1, r10
    carry.t 12
    addpc lr, lr
    ltx r6, r4
    and.t r2, r1, r10
    geu r11, r1
    any lr, 0xbb6b
    andp 12
    add r5, r13, r7
    eq r6, r11
    geux r5, r10
    ror.t r10, r13
    and r1, r8, r6
    sub r10, r2, r5
    inc r4, r1
    putp r5
    ne r3, r6
    ltx r6, r7
    sra.t r1, r8
    nex lr, r2
    andp.t 4
    ror r8, zr
    add r9, r6, 0xf54c
    andn r8, r11, zr
    rol r3, r2
    xor r5, sp, r7
    andn r6, r3, r5
    getp r6
    and r9, r1, r6
    getp r8
    ltx r5, r13
    putp.t r12
    geux lr, r11
    ge.t lr, r12
    lt r4, r1
    cex 7
    ne.t r13, r13
    srl.t lr, r3
    ltu.f r4, r4
    andp.f 1
    and.f r12, zr, lr
    geu.t r12, r13
    orp.f 3
    sub r6, r2, lr
    add r1, zr, zr
    j $test_ret
