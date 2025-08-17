    add r1, zr, 0x1420
    add r2, zr, 0x1dde
    add r3, zr, 0xc3ff
    add r4, zr, 0xb955
    add r5, zr, 0x354e
    add r6, zr, 0x45c
    add r7, zr, 0x452a
    add r8, zr, 0xdaf
    add r9, zr, 0x8a88
    add r10, zr, 0xe1d9
    add r11, zr, 0xf9e
    add r12, zr, 0xb12a
    add r13, zr, 0x285a
    add lr, zr, 0xe233
    add sp, zr, 0x729c
    putp zr
    orp 7
    not r6, r3
    geu r11, r10
    anyx lr, r7
    any.t lr, r4
    geu r7, r5
    sub r10, r2, r7
    bl lr
        .org 0xe259
    addpc r3, r4
    rol sp, r9
    rol sp, r5
    jl r1
        .org 0x1420
    orp 15
    geu r12, r12
    srl r1, r13
    any r8, zr
    not zr, r12
    rol r5, r13
    inp 3
    putp r2
    geu r1, r12
    sub lr, r3, lr
    geux r7, r6
    j.t 0x854c
        .org 0x854c
    andn r11, r1, r2
    sub r10, r8, r9
    inpx 2
    xor.t r10, r9, r11
    -ld sp, r3
    getp r6
    inc lr, r11
    ld- r13, r1
    ld- r9, r10
    inp 1
    ldm r1..lr, r9
    any r7, r10
    stm r2..r9, r9
    urx r2
    outn 1, zr
    nex r10, r1
    st-.t zr, r4
    dec r5, r9
    andn r13, zr, r1
    addpc r4, r6
    not r6, lr
    inpx 0
    add.t r6, r12, zr
    putp r4
    ld+ r5, sp
    srl r5, r6
    or r9, r5, lr
    putp r4
    inpx 3
    lt.t zr, r3
    add sp, r10, r9
    andp 0
    ltu r6, r7
    eq r9, r6
    addpc r9, r6
    gex r2, r10
    and.t r4, r12, r4
    andn r8, sp, r10
    cex 7
    addpc.t r5, r6
    putp.f r10
    +ld.f r13, r1
    inp.t 3
    ld.t lr, r13, 0x115
    add.t r7, r9, r8
    sub.f zr, r4, r6
    getp r12
    lt r13, r11
    st r8, r11, 0xe7e4
    ge sp, r12
    st- zr, r11
    outp 3
    b 0x2f8c
        .org 0xb50f
    carry 9
    add r11, r2, lr
    sub r6, r12, r1
    inp 1
    j r7
        .org 0x532f
    eqx r7, r2
    dec.t r8, sp
    outp 2
    utx zr
    add r4, r11, lr
    rol r13, r4
    dec r3, r2
    bl r6
        .org 0xbe62
    add sp, r13, r9
    inc r8, r9
    or r11, zr, r1
    st r9, r3, r10
    eqx sp, r9
    ld-.t r5, r9
    inc r4, r11
    ror r10, r6
    geu r10, r3
    ld r10, r12, 0x9403
    anyx r12, r8
    xor.t r9, lr, r6
    +st r5, r5
    geux r2, r13
    st.t r9, r8, 0x55d4
    utx r10
    stm lr..r11, lr
    sub r11, r4, r2
    anyx zr, r12
    not.t r2, r8
    st r4, r7, 0x8b14
    ld r1, r11, 0x22e1
    and r9, r13, r9
    gex r4, r7
    orp.t 11
    or r8, lr, r5
    any r6, r3
    and r10, r6, r7
    +ld r3, sp
    outp 1
    ltu sp, r6
    anyx r4, r8
    or.t sp, r2, r4
    outp 2
    outn 1, r4
    and sp, r1, zr
    ltux zr, 0xdff6
    sub.t r2, r3, lr
    ltux r7, zr
    add.t r1, r3, r1
    rol r8, lr
    add r9, sp, r10
    geux r5, lr
    lt.t r1, r8
    ld+ r8, r1
    st+ r3, r9
    st- r9, r9
    putp lr
    ld sp, lr, 0x7a0e
    cex 7
    stm.t zr..lr, r13
    +ld.f r6, r3
    srl.t r2, r4
    outp.t 2
    ltu.t r1, r11
    jl.t 0xb42c
    st.f r10, zr, 0x90
    sra r7, r12
    not r4, r10
    any r2, lr
    ltx r10, r11
    andn.t r4, lr, r9
    bl r13
        .org 0xb9f0
    not r10, r6
    andn r2, r13, r1
    ltx r7, r10
    ror.t r2, r13
    j r2
        .org 0x6140
    addpc r3, r2
    -st zr, r3
    dec r12, sp
    ld- r5, r1
    st r10, r12, r7
    or r11, zr, r12
    ld sp, r1, 0xeace
    ge r11, r10
    rol r7, zr
    xor r1, r10, r9
    orp 6
    lt sp, zr
    ltu r10, r5
    and sp, r8, r13
    ror r3, zr
    utx r2
    ror r7, r7
    geu r6, r3
    getp r11
    geu r5, lr
    +ld r3, r4
    addpc r1, r11
    st+ lr, sp
    ne sp, 0x615a
    inc r12, r8
    add r4, r13, r11
    andn r6, r13, r2
    inc sp, r11
    outp 0
    nex sp, r12
    ld+.t lr, lr
    inc r2, r6
    cex 3
    ld.t r1, r13, 0xca80
    carry.f 10
    rol.t r4, r1
    cex 2
    st.t sp, r11, 0xf62e
    ror.f r5, r10
    rol lr, r7
    ld- lr, r8
    st r2, sp, 0xf117
    getp zr
    eq r4, r13
    xor r13, sp, r12
    cex 4
    ld.f r2, r5, r3
    st.t lr, r7, 0xd1df
    eq.f r9, r8
    ld.t sp, r7, 0xbc64
    geux sp, r10
    ltu.t r2, 0x8d8f
    ge r7, r7
    -ld r7, r13
    xor r11, r3, r13
    getp sp
    add r9, lr, zr
    dec r12, r10
    ld lr, r12, 0xd876
    geu r11, zr
    carry 1
    addpc r5, r8
    -st r10, r11
    out 2, r3
    geu r5, r2
    utx r4
    ldm r4..r1, r7
    outp 0
    add r6, r12, r13
    carry 13
    sub r9, r7, r1
    sub r9, r12, r2
    stm r3..r5, r12
    ltu r12, r12
    ltux r11, zr
    ld-.t r11, r11
    geux r13, r5
    xor.t r3, r10, r12
    ltux r8, r7
    any.t r8, r8
    add r9, r8, zr
    rol r3, r5
    putp r6
    ltx r13, r5
    outp.t 1
    jl lr
        .org 0xc46f
    +ld sp, r11
    +st sp, r13
    ge r2, lr
    cex 5
    any.t r6, zr
    j.f 0x9a63
        .org 0x9a63
    ne.t sp, r2
    eq.f r4, r12
    ltu.t r13, r9
    addpc sp, r2
    ldm r4..sp, r9
    putp r2
    st- r2, r9
    srl r11, r9
    carry 8
    ne r5, r3
    ld+ r7, r5
    -st sp, r10
    ror r8, r3
    srl r6, r7
    eqx r2, r6
    ror.t r5, r10
    ror r3, r4
    dec r7, r2
    geu r7, lr
    gex r11, r9
    bl.t r9
    geu r11, r1
    ld- r5, r11
    gex r6, r9
    ldm.t r3..r7, lr
    eqx r11, r11
    addpc.t r12, r8
    ne r1, lr
    rol r12, r3
    andp 0
    putp r12
    andp 8
    any r4, r4
    ltux r8, 0xbfd2
    sub.t r2, r4, r2
    st r11, r9, 0x5ea0
    ne r3, r4
    bl lr
        .org 0xe6cd
    dec r7, r1
    stm r3..zr, lr
    add r5, r12, r6
    ltx r13, r11
    inc.t r4, r12
    any r11, r8
    ge r10, r4
    andp 14
    ror r9, r8
    not r6, r3
    getp r6
    eq r12, r2
    ltux r2, r11
    ror.t r4, lr
    eq r6, zr
    andn r3, r4, r8
    ldm r1..r12, sp
    -st r1, r11
    getp r5
    ror r12, r3
    anyx r6, r11
    b.t r2
    andp 13
    j r8
        .org 0x5b99
    inpx 2
    ld+.t r9, r12
    j 0x9bdb
        .org 0x9bdb
    andn r7, r9, 0x568d
    ldm r11..zr, r1
    geu r5, r4
    eqx r6, r9
    utx.t lr
    ltu r5, r6
    +st r13, r4
    not r13, r7
    andp 7
    ld r3, r4, 0x261b
    ge r7, r1
    ld- r10, r3
    addpc r12, r9
    st zr, r1, r4
    ld lr, lr, 0x2e10
    or r8, r6, r9
    +ld r9, r4
    inpx 1
    srl.t r8, r7
    putp r11
    not r2, r8
    ne r7, r6
    ne r9, 0xf4ca
    +st r12, sp
    ne r10, r3
    ldm r3..zr, r12
    ne lr, r1
    and r10, r4, zr
    ltu r2, zr
    orp 12
    ld zr, r7, 0xe752
    ltux r7, r7
    rol.t r4, lr
    sra sp, r5
    dec sp, r13
    -st lr, r4
    st+ r4, r3
    ltx r7, r1
    -ld.t r9, r12
    or r13, lr, r13
    eq r10, r5
    +ld r9, r13
    gex r7, 0x3ccd
    ld.t r12, r10, 0x35f7
    out 0, zr
    ltu r2, r1
    putp r2
    eq r11, r13
    xor r8, r1, r9
    andn sp, r6, r7
    ror r12, r12
    ld sp, r10, 0x35d8
    putp r3
    putp r3
    ltux r11, r4
    st.t r5, zr, r7
    any r6, lr
    any r2, r6
    st r9, r9, r6
    +st r6, r5
    +st r3, r5
    xor r12, r6, r12
    ne r12, r10
    inc r4, r12
    getp r12
    inpx 2
    utx.t 0xe8e
    st r13, zr, 0x6234
    stm sp..r6, r6
    ld- r5, r9
    jl lr
        .org 0x14f6
    or r1, r4, zr
    inp 3
    putp r4
    add r11, zr, r3
    inc r2, lr
    ltux r9, r8
    lt.t r2, r4
    +ld lr, r5
    or r7, r10, r3
    getp r11
    ror r4, r6
    ltux r13, lr
    srl.t r8, r4
    orp 11
    ne r9, r7
    ltu r5, r1
    ld sp, r7, 0x428d
    inc r10, r11
    ne sp, r11
    xor r2, r12, r5
    any r1, r13
    andn r10, zr, r8
    -st r1, r8
    sra r2, sp
    andp 2
    gex r5, r9
    jl.t r7
    stm r11..r8, r2
    st r13, r9, 0xd669
    getp r1
    st- sp, r7
    geu r13, r8
    not zr, r8
    rol r1, r7
    b r1
        .org 0x543f
    bl r3
        .org 0xf3d2
    eq r2, r12
    ld r6, r5, 0x2b3d
    rol r4, r1
    inp 2
    st lr, r13, 0xfcb9
    sra r13, r11
    sra r13, zr
    putp zr
    lt r8, r8
    outp 1
    any r1, r2
    add r4, r5, r12
    j 0x9e57
        .org 0x9e57
    ge r3, r11
    geu r2, r9
    anyx lr, r9
    sra.t r10, sp
    st r9, r9, r10
    not r7, r9
    st r1, r4, 0x1425
    inp 0
    ld r3, r12, r7
    inpx 0
    sra.t r12, r9
    any r6, r6
    ld+ r6, r3
    cex 4
    st.f r10, lr, zr
    carry.t 8
    inc.f r4, r5
    getp.t r12
    ltx r4, lr
    +ld.t r2, r4
    cex 1
    dec.t sp, r9
    anyx r2, r9
    +ld.t lr, r4
    geu r10, r2
    orp 1
    putp r9
    st r8, r4, r8
    ld r8, r2, 0x1a80
    ltux sp, r3
    andp.t 12
    inc r7, r4
    j r3
        .org 0xb7f4
    not r1, r5
    carry 6
    st- r2, sp
    addpc r6, r6
    dec r13, r13
    st r11, r12, 0x7a04
    xor sp, r12, r3
    rol r4, sp
    inc sp, r7
    putp r2
    and r5, r11, r2
    ld sp, r5, r8
    andn sp, r1, lr
    add r8, lr, r9
    eqx r11, 0xa125
    utx.t r1
    anyx r3, zr
    dec.t r3, zr
    dec lr, r13
    jl 0x6782
        .org 0x6782
    srl r9, r9
    dec r6, sp
    st r11, r5, 0x8180
    ltux lr, r4
    st+.t r1, r2
    ror r4, r9
    add r4, r10, r4
    geux r5, r2
    urx.t r4
    orp 6
    or r3, r7, r11
    ltx lr, r12
    sub.t r4, r7, r9
    sra r5, r2
    sub r2, r7, r6
    utx r5
    utx lr
    ldm lr..r2, r9
    andp 14
    ld r1, r9, r3
    stm r5..r8, r6
    eqx r10, r1
    carry.t 1
    or r7, r6, 0xf4b4
    inpx 0
    st.t r10, r12, 0xad8e
    or r6, r4, zr
    or zr, r4, lr
    orp 11
    st r5, r12, 0x8a7c
    carry 14
    stm r7..r12, r7
    lt r11, r8
    andn r11, r5, r13
    inpx 0
    ld.t lr, zr, 0xdf35
    inp 1
    cex 3
    any.t r2, r4
    ltu.t sp, r5
    st.t sp, r11, 0xc832
    andp 13
    srl lr, r12
    or r13, sp, r3
    ror r5, r5
    xor r12, r7, zr
    anyx r3, r10
    ltu.t r4, r9
    andp 11
    rol r11, r13
    dec zr, sp
    ldm r10..zr, r3
    inpx 3
    and.t sp, r12, r8
    ld r1, r7, 0x6d71
    inc r2, sp
    andp 7
    orp 7
    ldm lr..r2, r13
    andn lr, r10, r7
    ge r7, r12
    srl r13, r10
    srl r10, r11
    out 1, 0x43f0
    carry 10
    cex 2
    st.f sp, r4, zr
    st.t r12, r8, 0xb170
    nex r7, r9
    ld.t sp, lr, r5
    andp 1
    utx r11
    ld+ r9, r2
    st r6, sp, r3
    ldm r5..lr, r12
    xor r10, r8, r12
    utx r7
    andn r12, r2, lr
    st+ r8, sp
    utx r13
    -st r4, lr
    any r2, r5
    sra r11, r7
    outn 1, 0x2c70
    eq r7, r10
    ld r1, lr, 0x15cf
    ge r13, r2
    addpc r1, r13
    inp 0
    gex r5, 0x880b
    rol.t r10, r1
    gex r10, r5
    getp.t r11
    ror r6, r10
    sra r11, r13
    eqx r5, r2
    addpc.t r1, r1
    b r1
        .org 0x7bb2
    ror r4, r3
    and r11, r5, r2
    ror r4, zr
    andp 6
    st- r10, r13
    ld r10, r10, r10
    orp 14
    rol r2, r9
    cex 2
    outn.t 2, r4
    ld.f r3, r2, 0x173a
    -ld r3, r12
    addpc r4, r5
    sub zr, r11, r7
    ltux r10, r13
    getp.t r11
    andn r7, lr, r6
    ne sp, r4
    not sp, r8
    st- lr, r8
    xor r7, r1, r9
    out 0, lr
    rol r1, r4
    outp 1
    sub r12, sp, r2
    ltux r12, 0xc5c4
    rol.t zr, r3
    inc r2, r4
    getp r5
    ldm r10..r6, r3
    andn r6, r4, 0xb30d
    geu zr, r12
    rol r12, r6
    ld zr, zr, 0x6d11
    putp r4
    dec zr, lr
    st lr, r8, 0xcb48
    srl r13, r10
    eqx sp, 0x3c73
    out.t 2, r7
    inp 3
    orp 14
    eqx r12, r2
    st.t r2, zr, lr
    ge r7, r6
    outn 0, r2
    eq r10, lr
    xor zr, lr, r1
    srl r12, r6
    ld+ r9, r10
    -st r7, r12
    geux r4, r5
    eq.t r9, r4
    any r2, r6
    ne r9, r13
    xor r10, r8, r10
    outp 2
    rol r12, r9
    +st r4, r3
    ge r8, zr
    not lr, r1
    addpc r13, r9
    ld- r1, r9
    sra r4, r8
    andn sp, r3, r7
    urx r8
    urx r6
    not r2, r9
    and r2, r8, r1
    ltux r5, 0x823c
    andp.t 12
    carry 9
    and r13, r5, r13
    and r10, r12, r11
    addpc r8, r6
    andp 6
    inc r9, sp
    outn 1, r12
    anyx r8, r4
    st.t r9, r8, r2
    add r9, r9, r6
    sub r10, r13, r3
    sub r4, r11, r8
    ror r3, r4
    ld- r4, r7
    ror lr, r4
    -st r7, sp
    ne r10, r11
    stm sp..r2, r9
    st+ r7, r12
    ld+ r6, r8
    sub r3, r1, r2
    ror r11, r6
    or r6, r11, r8
    add r13, r4, r7
    ltx r9, r6
    out.t 0, 0x2289
    out 0, r8
    putp r5
    gex r13, r6
    st.t sp, r1, 0xbaaf
    ltu r12, r2
    st lr, r3, 0x6246
    st- r11, r11
    srl r7, r5
    rol sp, r7
    eqx r6, r5
    putp.t 0x2950
    ld r5, r5, r12
    andn r2, r10, lr
    ld r2, r11, 0xc081
    srl lr, r10
    st r7, r3, 0x2c58
    st r5, sp, 0x82a6
    andp 6
    ldm r8..zr, sp
    ror r8, r5
    ne r6, zr
    any r10, r3
    putp r7
    gex r13, r9
    st-.t zr, r6
    ge r8, r12
    srl r8, r4
    ne r6, r10
    -st r11, r7
    or r1, zr, r3
    ldm r8..r6, r4
    gex zr, r13
    eq.t r5, r4
    rol lr, r10
    ltux sp, r9
    not.t r2, sp
    cex 5
    xor.f r8, r2, r3
    dec.t r7, zr
    putp.f r11
    st.f r1, r6, r10
    rol.t r7, zr
    ld- r1, r11
    not sp, r1
    rol r13, r6
    -st r2, r13
    srl sp, r8
    j r8
        .org 0x4798
    any r10, r3
    outn 2, zr
    -ld r7, lr
    anyx r5, r1
    ldm.t r13..r4, sp
    geux r8, r2
    lt.t r6, zr
    dec r6, r12
    rol r12, r5
    ltx r1, r3
    putp.t r11
    ltx r6, r7
    +ld.t r13, sp
    -st r7, lr
    addpc r13, r13
    eqx r7, r6
    st-.t r11, r11
    -ld r7, r6
    ne r7, r12
    urx r12
    eq sp, r10
    ltx r8, r7
    st-.t r3, sp
    addpc r1, lr
    inc r7, zr
    orp 8
    andp 9
    geux r2, r11
    geu.t r12, r5
    srl r5, r4
    andn r6, r3, 0x785d
    bl r5
        .org 0x5451
    +ld lr, r4
    orp 0
    not r2, r13
    sub r4, r12, r3
    putp r1
    sub r12, r7, 0xb34c
    andp 0
    rol r10, r7
    lt r9, r12
    j r9
        .org 0x3742
    putp r8
    lt r3, r11
    andp 8
    ltux r2, r11
    geu.t r1, r10
    anyx r6, r11
    or.t r12, zr, r11
    eqx r13, lr
    getp.t r10
    getp r8
    outp 0
    geux zr, zr
    putp.t 0x5bea
    anyx r12, r12
    dec.t r4, r8
    geu lr, r10
    add r12, r9, r13
    anyx r8, r12
    sub.t sp, r2, r13
    ror r12, r8
    any r3, r3
    geu r2, r4
    addpc r4, r8
    dec r9, zr
    utx r4
    ltu lr, r1
    not r2, sp
    ld- r11, lr
    putp r9
    ltux r3, lr
    st.t lr, r4, 0x11c6
    or r13, sp, r13
    andp 8
    inc r9, sp
    ld r5, sp, 0xfdad
    andn r7, r6, r4
    st+ r8, r1
    lt r9, r7
    ld sp, lr, r1
    +ld r2, r9
    ldm r9..r1, sp
    urx r8
    ltx r4, r8
    st-.t r3, r11
    cex 2
    inp.t 2
    st.f r3, r4, 0xfa1f
    geu r5, r3
    ne r1, lr
    stm r2..r7, r10
    ne r8, r5
    rol r1, lr
    ne r7, r5
    st+ r2, r12
    outp 0
    bl r2
        .org 0x69e0
    add r4, sp, r6
    srl r1, r10
    +st zr, r6
    sub r6, r7, r9
    xor zr, r12, r12
    utx r8
    sra r10, sp
    addpc r3, r1
    anyx r9, r13
    -st.t r6, r8
    addpc r10, r6
    or r11, sp, r13
    ge r12, r6
    outp 0
    +st r4, r2
    out 2, r8
    sub r13, r10, 0xb72f
    sub r10, zr, r9
    -st r12, r13
    not r8, r7
    outp 3
    outp 2
    dec r6, sp
    eq r3, r12
    and r6, r1, 0xca5a
    srl r5, r4
    srl r3, zr
    ld r5, r1, 0x52ac
    st+ sp, r1
    eq r7, 0x23c8
    st sp, zr, 0xea93
    dec r12, r6
    eqx r7, r3
    dec.t r6, r8
    add r8, lr, r7
    sub r9, lr, r12
    ltux r6, r2
    geu.t r11, r10
    +st r11, r6
    rol r13, r13
    carry 9
    +st r7, r6
    ltx r2, r1
    st.t r3, r9, 0xf0f5
    ld r2, r10, r5
    dec r10, r3
    sub r3, r2, zr
    xor r1, zr, r12
    sra r11, r5
    rol r1, zr
    xor r5, r9, r2
    andn r1, lr, zr
    ltx r5, r6
    andn.t r9, r10, r2
    +st r7, r12
    utx r12
    ld+ r7, r11
    anyx r12, r7
    ld.t r5, sp, zr
    st lr, r12, 0x29a0
    nex r11, lr
    or.t r12, r10, zr
    getp r12
    nex r4, r1
    sub.t r2, r8, r4
    dec r12, sp
    nex r6, lr
    xor.t r12, r5, r2
    outn 3, r3
    nex r9, r2
    orp.t 6
    rol r1, sp
    dec r9, r5
    lt r3, r13
    bl r4
        .org 0x86f2
    -st r2, r4
    srl r2, r12
    stm zr..r9, r1
    andn r5, r6, r9
    or r2, lr, r10
    not r3, r12
    outp 0
    ldm lr..r10, lr
    ltx lr, zr
    ld+.t r11, r11
    outn 3, r11
    dec lr, r8
    +ld r9, r8
    rol r11, sp
    ltx zr, zr
    ne.t sp, r5
    eq r10, r7
    andn lr, zr, lr
    ltx r1, r8
    ltu.t lr, r2
    eqx r1, r9
    -st.t zr, r6
    andn r4, lr, r2
    and r10, r5, r11
    inp 1
    geu r8, r11
    -ld lr, sp
    +st r2, r7
    st r12, sp, 0x3481
    or r1, r2, r6
    urx r1
    st+ r6, r9
    rol r12, r6
    any r4, r4
    dec r9, r12
    srl zr, r1
    inp 0
    ltu r5, lr
    sra r4, zr
    +st r7, lr
    urx r11
    urx r12
    inpx 3
    ld.t sp, r8, r7
    ld r12, r12, r11
    ld+ r6, r9
    j r13
        .org 0xc233
    jl r1
        .org 0xcc53
    st r1, r2, 0x3c4f
    sub sp, r5, r11
    ld lr, r2, r8
    getp r6
    xor r3, r9, r6
    not r13, lr
    out 1, lr
    sub lr, r9, r7
    add zr, r4, r4
    geu r1, r2
    putp 0x7bd3
    putp r3
    ld r13, r12, r3
    ge r10, r9
    addpc r4, lr
    geu r10, r10
    out 0, r8
    geux r1, r9
    inc.t r10, r8
    bl r2
        .org 0x5851
    ldm r1..r2, r13
    ld r9, r8, r7
    ld r13, r8, r10
    sub r5, r11, r11
    st r12, r8, 0x22a5
    ror zr, r11
    st- lr, r4
    -ld r13, r11
    carry 14
    not r3, r8
    st r10, zr, 0x4d75
    j 0x44ef
        .org 0x44ef
    ltu r2, r6
    ltx zr, zr
    or.t r10, r12, r4
    sub r12, r13, r13
    putp r3
    rol r5, r9
    lt r13, r7
    ld r6, r8, 0x73b2
    st+ lr, r13
    -st r5, r9
    geu r10, r9
    outp 2
    gex sp, r7
    +ld.t zr, r3
    nex r10, r3
    carry.t 6
    add zr, zr, zr
    add zr, zr, zr
    add zr, zr, zr
    add zr, zr, zr
    add zr, zr, zr
    add zr, zr, zr
    utx 0x40
    utx 0x40
    utx 0x45
    utx 0x4e
    utx 0x44
    utx 0x40
    utx 0x40
    utx zr
    b 0xffff
        .org 0x9bad
        .int 0xfe7d
        .org 0x142d
        .int 0xbb76
        .org 0x8aa9
        .int 0xa849
        .org 0xa849
        .int 0x94d4
        .org 0xa84a
        .int 0x2303
        .org 0xa84b
        .int 0x1e51
        .org 0xa84c
        .int 0x52ea
        .org 0xa84d
        .int 0x3ffa
        .org 0xa84e
        .int 0x62d4
        .org 0xa84f
        .int 0x49d3
        .org 0xa850
        .int 0xd08
        .org 0xa851
        .int 0x9b38
        .org 0xa852
        .int 0x819c
        .org 0xa853
        .int 0xa399
        .org 0xa854
        .int 0x5d81
        .org 0xa855
        .int 0x4480
        .org 0xa856
        .int 0xc9c0
        .org 0xfe7d
        .int 0x471e
        .org 0x115
        .int 0xaf1f
        .org 0x9404
        .int 0xaa36
        .org 0x9850
        .int 0x9eab
        .org 0xde38
        .int 0x8a11
        .org 0x9eab
        .int 0xbbed
        .org 0xcd45
        .int 0xeefd
        .org 0x9eac
        .int 0x535e
        .org 0x8979
        .int 0x56e5
        .org 0x1014
        .int 0xd0e2
        .org 0xbea9
        .int 0xb380
        .org 0xc5c8
        .int 0xec88
        .org 0xbbed
        .int 0xea60
        .org 0x2440
        .int 0xc4d5
        .org 0xbbeb
        .int 0xb014
        .org 0x6d48
        .int 0x8513
        .org 0xb014
        .int 0xefe6
        .org 0xb015
        .int 0xee21
        .org 0xb016
        .int 0xe894
        .org 0xb017
        .int 0xeb88
        .org 0xb018
        .int 0xba6f
        .org 0xb019
        .int 0x86e2
        .org 0xb01a
        .int 0xb878
        .org 0xb01b
        .int 0x4f36
        .org 0xb01c
        .int 0xb4f1
        .org 0xb01d
        .int 0xc40f
        .org 0xb01e
        .int 0xc46f
        .org 0xb01f
        .int 0x2639
        .org 0xb020
        .int 0x3cc7
        .org 0xb021
        .int 0x10c2
        .org 0x4f37
        .int 0x9467
        .org 0xba6f
        .int 0x26c7
        .org 0xba70
        .int 0xc69c
        .org 0xba71
        .int 0x1664
        .org 0xba72
        .int 0x57ac
        .org 0xba73
        .int 0x2426
        .org 0xba74
        .int 0x340
        .org 0xba75
        .int 0xad27
        .org 0xba76
        .int 0x40d3
        .org 0xba77
        .int 0xa984
        .org 0xba78
        .int 0x95b4
        .org 0xba79
        .int 0x4c43
        .org 0xba7a
        .int 0x7408
        .org 0xc69c
        .int 0xe120
        .org 0x19f
        .int 0x68d9
        .org 0x4c43
        .int 0x534b
        .org 0x4c44
        .int 0x90db
        .org 0x4c45
        .int 0x9823
        .org 0x4c46
        .int 0x91b
        .org 0x4c47
        .int 0xbaf4
        .org 0x7408
        .int 0xc99c
        .org 0x7409
        .int 0x812e
        .org 0x740a
        .int 0x35e0
        .org 0x740b
        .int 0xd3b3
        .org 0x740c
        .int 0xac47
        .org 0x740d
        .int 0xba41
        .org 0x740e
        .int 0xd342
        .org 0x740f
        .int 0x5b99
        .org 0x7410
        .int 0x2e8
        .org 0x7411
        .int 0xdda9
        .org 0x7412
        .int 0x72b8
        .org 0x7413
        .int 0x2481
        .org 0xc99c
        .int 0xaf97
        .org 0xc99d
        .int 0xc313
        .org 0xc99e
        .int 0x9d01
        .org 0xc99f
        .int 0x740b
        .org 0xc9a0
        .int 0x433d
        .org 0xc9a1
        .int 0x950a
        .org 0xf9cf
        .int 0x1211
        .org 0x1211
        .int 0x5713
        .org 0xa21b
        .int 0xf549
        .org 0xd3b5
        .int 0xab4d
        .org 0x9ed1
        .int 0x9f92
        .org 0x9ed2
        .int 0x7db3
        .org 0x9ed3
        .int 0x21c9
        .org 0x9ed4
        .int 0x707f
        .org 0x9ed5
        .int 0x45d9
        .org 0x9ed6
        .int 0x99be
        .org 0x9ed7
        .int 0xf4a9
        .org 0x9ed8
        .int 0xa430
        .org 0x9ed9
        .int 0x9529
        .org 0x9eda
        .int 0xc88e
        .org 0x9edb
        .int 0x117b
        .org 0x9edc
        .int 0x14f6
        .org 0x9edd
        .int 0xbdf0
        .org 0x9ede
        .int 0xc829
        .org 0x2d2b
        .int 0x5a13
        .org 0x1600
        .int 0x51a1
        .org 0x35f7
        .int 0x12d7
        .org 0x35d8
        .int 0xd760
        .org 0x51a1
        .int 0xb817
        .org 0xb818
        .int 0xe8c3
        .org 0xe220
        .int 0xf456
        .org 0xe355
        .int 0x485d
        .org 0xae60
        .int 0xb7f3
        .org 0xb7f3
        .int 0x650f
        .org 0xb81a
        .int 0x9f45
        .org 0xb81b
        .int 0x2ce
        .org 0xb9c5
        .int 0xf55c
        .org 0xf55d
        .int 0xb141
        .org 0x28d0
        .int 0x3f95
        .org 0x28d1
        .int 0x946e
        .org 0x28d2
        .int 0xbcae
        .org 0x28d3
        .int 0x7905
        .org 0x28d4
        .int 0x4894
        .org 0xe0ed
        .int 0x8956
        .org 0xb81d
        .int 0xcda6
        .org 0xb81e
        .int 0x5131
        .org 0xb81f
        .int 0x2557
        .org 0xb820
        .int 0x11d8
        .org 0xb821
        .int 0x90cf
        .org 0xb822
        .int 0xcc2
        .org 0xb823
        .int 0x8a7
        .org 0x6325
        .int 0x298b
        .org 0x11d8
        .int 0x8f7e
        .org 0x11d9
        .int 0x49fa
        .org 0x11da
        .int 0x1ffc
        .org 0x11db
        .int 0x7c0d
        .org 0x11dc
        .int 0xfbb3
        .org 0x6fd3
        .int 0x9885
        .org 0xfbb3
        .int 0x5e1c
        .org 0x2557
        .int 0x4c0c
        .org 0x2558
        .int 0x5632
        .org 0x2559
        .int 0x4a5a
        .org 0x255a
        .int 0x15c4
        .org 0x255b
        .int 0xdcac
        .org 0x255c
        .int 0x28cb
        .org 0x255d
        .int 0x7c56
        .org 0x255e
        .int 0x109f
        .org 0x255f
        .int 0xabdf
        .org 0x2560
        .int 0xbd90
        .org 0xd35e
        .int 0xa5a4
        .org 0x4f0c
        .int 0x3640
        .org 0xd093
        .int 0x6e35
        .org 0x4223
        .int 0x1dcd
        .org 0x1dcd
        .int 0x8c3a
        .org 0x1dce
        .int 0x3d2c
        .org 0x1dcf
        .int 0x499a
        .org 0x1dd0
        .int 0x1728
        .org 0x1dd1
        .int 0xc41
        .org 0x1dd2
        .int 0xb7eb
        .org 0x1dd3
        .int 0xa0c7
        .org 0x1dd4
        .int 0x82b4
        .org 0x1dd5
        .int 0x39be
        .org 0x1dd6
        .int 0xd1be
        .org 0x1dd7
        .int 0x6783
        .org 0x1dd8
        .int 0xd818
        .org 0x1dd9
        .int 0x1a03
        .org 0x6d11
        .int 0xe64c
        .org 0x8c3a
        .int 0x13c7
        .org 0x13c7
        .int 0x73ad
        .org 0xcf6f
        .int 0xe2c4
        .org 0x1596
        .int 0x153b
        .org 0xffa7
        .int 0x3c20
        .org 0x4b1d
        .int 0x632c
        .org 0xd818
        .int 0x66bc
        .org 0xd819
        .int 0xef0c
        .org 0xd81a
        .int 0x2f3a
        .org 0xd81b
        .int 0xc5af
        .org 0xd81c
        .int 0x41ba
        .org 0xd81d
        .int 0x70a6
        .org 0xd81e
        .int 0x8b9
        .org 0xd81f
        .int 0x7f83
        .org 0xd820
        .int 0x15fc
        .org 0xe2c4
        .int 0x2c8e
        .org 0xe2c5
        .int 0x3742
        .org 0xe2c6
        .int 0xb4e2
        .org 0xe2c7
        .int 0xbb47
        .org 0xe2c8
        .int 0x1075
        .org 0xe2c9
        .int 0x39fa
        .org 0xe2ca
        .int 0x68b6
        .org 0xe2cb
        .int 0xa85c
        .org 0xe2cc
        .int 0x1960
        .org 0xe2cd
        .int 0xc3be
        .org 0xe2ce
        .int 0x9858
        .org 0xe2cf
        .int 0xdfc0
        .org 0xe2d0
        .int 0x7cdf
        .org 0xe2d1
        .int 0x60f9
        .org 0xe2d2
        .int 0x2432
        .org 0xbb47
        .int 0xcf85
        .org 0x69c4
        .int 0xd505
        .org 0x23cc
        .int 0xb213
        .org 0x23cd
        .int 0x8017
        .org 0x23ce
        .int 0x6e21
        .org 0x23cf
        .int 0x631c
        .org 0x23d0
        .int 0xd782
        .org 0x23d1
        .int 0xaa94
        .org 0x23d2
        .int 0x28aa
        .org 0x23d3
        .int 0x1933
        .org 0x1073
        .int 0x655
        .org 0x1934
        .int 0x208c
        .org 0x208c
        .int 0x6ad1
        .org 0x6bce
        .int 0xc231
        .org 0xe851
        .int 0x580d
        .org 0x6e23
        .int 0x3263
        .org 0x580d
        .int 0xd243
        .org 0x580e
        .int 0x5cf4
        .org 0x580f
        .int 0x1034
        .org 0x5810
        .int 0x6c62
        .org 0x5811
        .int 0x7356
        .org 0x5812
        .int 0xe0a4
        .org 0x5813
        .int 0x1c1f
        .org 0x5814
        .int 0x9399
        .org 0x5815
        .int 0xbfbf
        .org 0x8126
        .int 0x84db
        .org 0xb298
        .int 0x1efe
        .org 0x426d
        .int 0x2dc5
        .org 0x1c1f
        .int 0x5a6e
        .org 0x6a32
        .int 0x74ad
        .org 0x6a33
        .int 0xc1bd
        .org 0x6a34
        .int 0xcf91
        .org 0x6a35
        .int 0x717
        .org 0x6a36
        .int 0x8be9
        .org 0x6a37
        .int 0xc877
        .org 0x6a38
        .int 0xae9b
        .org 0x6a39
        .int 0xde22
        .org 0x6a3a
        .int 0x8f60
        .org 0x6a3b
        .int 0x4190
        .org 0x6a3c
        .int 0x782d
        .org 0x6a3d
        .int 0xd32b
        .org 0x6a3e
        .int 0xb890
        .org 0x782e
        .int 0x960d
        .org 0xc1bc
        .int 0xe084
        .org 0xa358
        .int 0x5c74
        .org 0x1ec0
        .int 0x6267
        .org 0x417
        .int 0x294e
        .org 0x7b35
        .int 0x8edf
        .org 0x8edf
        .int 0x5665
        .org 0x8ee0
        .int 0x9c9f
        .org 0xb9bf
        .int 0x22cd
        .org 0xf05d
        .int 0x4817
        .org 0x76a1
        .int 0xf98a
        .org 0xebe0
        .int 0x3cd
        .org 0x87d2
        .int 0x53ac
