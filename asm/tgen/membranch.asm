    add r1, zr, 0xbc58
    add r2, zr, 0x452c
    add r3, zr, 0x5881
    add r4, zr, 0xf3ea
    add r5, zr, 0x2fa8
    add r6, zr, 0x8ba0
    add r7, zr, 0x8309
    add r8, zr, 0x8ca5
    add r9, zr, 0x29da
    add r10, zr, 0x8d88
    add r11, zr, 0x3a2c
    add r12, zr, 0x3efc
    add r13, zr, 0x56b
    add lr, zr, 0x7541
    add sp, zr, 0xa935
    putp zr
    st+ r13, r10
    +ld r2, r9
    st- r4, r13
    ld r12, r7, r10
    j r6
        .int 0x9d96
        .int 0x2008
        .org 0x8ba0
    +ld r13, sp
    -ld zr, r9
    st- r10, r11
    +st r8, r4
    ld+ r4, r8
    stm r11..r3, r13
    stm r2..r7, r4
    j r3
        .int 0xae45
        .int 0xfbc0
        .org 0x5881
    -st r2, r12
    bl r2
        .int 0xfbb9
        .int 0x1832
        .org 0x366d
    st r1, r4, 0xf095
    -ld r2, r5
    j lr
        .int 0x263d
        .int 0x434d
        .org 0x5883
    ld r8, r6, 0xe1cc
    j r8
        .int 0xa060
        .int 0x2302
        .org 0x2009
    st r10, r13, r12
    ld sp, r10, 0x21a8
    st r4, r2, r4
    add lr, r3, r13
    j 0x465d
        .int 0xa018
        .int 0x5e2e
        .org 0x465d
    stm r13..r3, r10
    ld r9, r8, r10
    +st r2, r7
    ld+ r11, lr
    ld lr, zr, 0xc020
    ld sp, r4, 0x894b
    ldm r12..r11, sp
    ld r7, r13, zr
    +ld r11, r3
    stm r12..r8, r12
    ld r8, zr, 0xa2ce
    +st r11, r2
    jl r10
        .int 0x55d7
        .int 0x33a4
        .org 0x3fef
    b r6
        .int 0x9e07
        .int 0x2aee
        .org 0xfe3c
    +ld r5, r8
    ld+ r12, r9
    j 0x5651
        .int 0xfc83
        .int 0x9168
        .org 0x5651
    stm r10..r4, r4
    j r6
        .int 0x1dba
        .int 0x986f
        .org 0xbe4d
    ld r12, lr, zr
    st r2, r6, 0x58b
    -ld r13, r11
    -st r4, r5
    +st r2, r8
    add lr, sp, lr
    st+ r10, r9
    ld r11, lr, r11
    -ld r8, r7
    +ld r13, r5
    jl 0xafbb
        .int 0xc1fe
        .int 0xe0cd
        .org 0xafbb
    -ld r5, r2
    add r3, r13, r13
    ld r9, r7, 0x9ac0
    ldm r1..r4, lr
    ldm r10..zr, r3
    +st r13, lr
    st r12, r10, r3
    st- sp, r5
    -ld r1, r12
    -st r1, r5
    ld- r9, r2
    ld zr, r6, 0x6a2c
    ld r8, r7, 0x8d91
    ld r3, zr, 0x5d18
    jl r3
        .int 0x342f
        .int 0x4ec0
        .org 0xaf09
    ld zr, r12, 0x436a
    ld- r12, r4
    st r7, r1, zr
    j 0x9416
        .int 0x1333
        .int 0xbb6
        .org 0x9416
    ld- r6, r8
    st r8, r4, 0xd548
    b r11
        .int 0xca7f
        .int 0x1bd3
        .org 0x53e2
    -st r6, r5
    st lr, r4, 0xb770
    +ld r9, sp
    st r10, r13, 0x1a3c
    st r5, r3, r9
    +st r1, r6
    ld r3, sp, r3
    j r12
        .int 0xca35
        .int 0x14f0
        .org 0x58b2
    ld r4, r7, 0xb73f
    st- zr, r2
    st r8, r13, 0xc7fc
    st lr, r12, 0x6bcd
    ld r6, r3, 0x353f
    st+ r3, r9
    b r8
        .int 0xfa21
        .int 0xfe9e
        .org 0x5f0e
    st r9, r4, r3
    st r9, r2, 0x1ac8
    ld- r9, r6
    -ld r11, r8
    st r13, r13, 0x53f0
    +ld r2, r9
    st sp, lr, r12
    add r1, r13, r10
    ld r4, zr, 0x2296
    -ld r2, r1
    -ld r5, r7
    -st lr, r11
    b r3
        .int 0xebce
        .int 0x1e29
        .org 0xeff4
    ld r11, r11, 0xcd08
    ld r10, r1, 0x6b89
    st- r9, r11
    -st r11, r1
    ld r12, r10, r8
    ld r5, r13, 0xeac3
    st r7, r1, 0x48c
    bl r13
        .int 0x6db3
        .int 0x764c
        .org 0x9fc5
    ldm r9..r9, r2
    ld+ r10, r10
    -st lr, r10
    ldm r3..r8, r4
    ld+ r10, r3
    ld- r10, r7
    ld r2, r1, 0x81c3
    ld+ zr, r12
    st- r7, r3
    ld sp, r11, 0xb6f7
    ld r11, r5, r4
    ld- r11, sp
    st r5, r3, 0x8b14
    st r4, r5, r9
    st r7, r3, 0x1f6c
    ld r1, zr, r2
    b r9
        .int 0x5b84
        .int 0x39c9
        .org 0x41f
    ld r6, r3, 0x7cba
    -ld r1, r6
    b r13
        .int 0xd70b
        .int 0x10ab
        .org 0xb3e8
    st r10, r12, 0x7af6
    ld r11, r1, lr
    add r8, r11, zr
    ld+ r9, r12
    ld r10, zr, 0x8c76
    ld r9, zr, 0xe29a
    ldm r6..sp, r1
    jl r13
        .int 0xefff
        .int 0x87ff
        .org 0xa798
    j 0xa5b7
        .int 0x8b54
        .int 0x707f
        .org 0xa5b7
    st- r9, r6
    st sp, r13, 0xf9f4
    ld+ r1, r6
    st r7, r4, r11
    st- r10, r10
    st r5, r6, 0x1c57
    j lr
        .int 0xe89d
        .int 0x8a00
        .org 0xb3f3
    st r9, r7, r4
    stm r5..lr, r8
    +ld r6, r6
    bl r9
        .int 0xd6f7
        .int 0x6e35
        .org 0xd4e4
    ld sp, r3, 0xda14
    ld+ r11, r11
    st r12, zr, 0xea2a
    -st r3, r8
    st- r13, r12
    st+ lr, r9
    st lr, zr, 0x9e76
    st+ r3, r6
    j r6
        .int 0xeaf
        .int 0x5c62
        .org 0x3125
    -ld zr, r4
    ld+ zr, r5
    st+ r1, lr
    st+ r13, r5
    st r9, sp, r12
    ld+ r8, lr
    st- r9, r9
    ld r7, zr, 0x31ce
    ld- r12, r12
    st- zr, lr
    ld r11, zr, 0xf671
    st r7, r2, 0xdb99
    ld r10, r8, 0x2a39
    +st r11, r2
    ld r5, r6, 0x2305
    ld r13, r6, 0x4d28
    st sp, r4, 0x4dce
    j r12
        .int 0xcd32
        .int 0xe10d
        .org 0xe36b
    st r5, r4, 0x2950
    ldm r7..r5, r13
    st r11, r13, r12
    st- r1, r7
    ld r4, zr, 0xb68d
    ld lr, r11, r9
    ldm lr..sp, sp
    ld- r8, r10
    ld+ r3, r2
    +ld r4, r13
    +st zr, r3
    ld- r3, r7
    ld- lr, r5
    bl 0xf63b
        .int 0xbf67
        .int 0x90f0
        .org 0xd9b6
    ld r7, zr, 0x59b8
    ldm r11..r6, r9
    stm r6..r8, r3
    +st sp, r1
    ld+ r13, r13
    ld+ sp, r5
    st r10, zr, 0x5ee4
    -ld r3, r7
    -ld r4, lr
    ldm r2..sp, r8
    ldm lr..r13, r13
    ldm lr..r7, r10
    ld- r4, r1
    st lr, r10, 0xab69
    ld- sp, r5
    st r2, r10, 0x3c23
    ld r11, r2, 0x6249
    j 0x20d6
        .int 0xd999
        .int 0xe4f
        .org 0x20d6
    ldm r8..r10, r9
    st+ r10, r1
    -st r11, r12
    jl 0xca1a
        .int 0xc6cd
        .int 0x7c10
        .org 0xca1a
    bl 0xf278
        .int 0xa26e
        .int 0x24b2
        .org 0xbc93
    add r8, r2, r11
    ld r1, r5, 0x3bd8
    ld+ r7, lr
    -ld r8, r5
    j r7
        .int 0x6592
        .int 0x860c
        .org 0x96c4
    st r13, r5, 0x3fcd
    -ld r9, r4
    ld r7, lr, 0x65d3
    j 0x581e
        .int 0x699c
        .int 0x1aaa
        .org 0x581e
    st r12, r3, 0x2105
    -st r10, r12
    j r1
        .int 0xb241
        .int 0x90c4
        .org 0x89b
    +ld r8, r7
    st+ zr, r11
    st r12, r12, 0x956f
    ld+ r5, r3
    -st r1, r10
    st r8, r1, 0xce95
    st- r12, r3
    +st r11, r6
    +st r12, r7
    st r9, r11, 0x3b24
    ld+ lr, sp
    -ld r12, r8
    st r5, r10, r3
    ld r13, r7, r1
    st- r2, r13
    st+ sp, r13
    ld+ r6, r2
    ld r10, r1, r12
    j 0x37c8
        .int 0xc3f2
        .int 0xf642
        .org 0x37c8
    ld+ lr, r12
    st zr, r3, 0xc34a
    st r1, r4, 0x6703
    stm r4..r11, r11
    st r6, r12, 0x5fa4
    -st r13, r4
    b r4
        .int 0x3253
        .int 0x1bdf
        .org 0xfcdb
    st lr, r7, 0x4c25
    j lr
        .int 0x973e
        .int 0x7ac5
        .org 0x9010
    st r5, lr, r10
    ld r4, zr, 0xdc41
    ld- sp, r5
    ld+ r4, r5
    st r11, r5, 0xeaf2
    stm r8..r4, r4
    st lr, r11, 0xb30e
    j 0x92e9
        .int 0xe066
        .int 0xa54e
        .org 0x92e9
    st+ r5, r10
    b r5
        .int 0xbd91
        .int 0x8218
        .org 0x2800
    st lr, r11, 0xeaee
    ld r5, zr, 0xd664
    -ld lr, sp
    ld- r3, r9
    stm r4..r1, lr
    +st r7, r7
    -st r3, r6
    st r3, r6, 0x841c
    st sp, r9, r12
    j 0xc88b
        .int 0x5cd6
        .int 0x911b
        .org 0xc88b
    +st r1, r13
    jl r2
        .int 0x7e59
        .int 0x8e9a
        .org 0x4646
    ld lr, r11, r7
    +ld r12, lr
    st r9, r7, r8
    ld r5, r2, 0x4363
    stm r4..r6, r5
    st r8, sp, 0x6a18
    bl r9
        .int 0xb0bf
        .int 0x702a
        .org 0x9870
    b r8
        .int 0x7644
        .int 0xb4cb
        .org 0x8033
    st zr, r2, 0x3341
    st+ r11, r10
    b 0xe75e
        .int 0x8ec8
        .int 0x5549
        .org 0x6795
    -st r11, r5
    b r5
        .int 0x72dc
        .int 0xf4c0
        .org 0x8bac
    ld r6, r8, 0xa556
    st r13, r11, r1
    ld r3, lr, 0xefc6
    -st r3, r6
    ld lr, r1, 0x7773
    ld sp, r1, 0xf111
    b r3
        .int 0x2e0
        .int 0xe3bf
        .org 0x1e91
    ld r7, r13, 0x83f7
    ld r3, zr, 0xc5f0
    b r13
        .int 0x8157
        .int 0x4ac1
        .org 0xfd62
    add r10, r11, r11
    st r10, r11, 0xa1ee
    -ld r11, r12
    j 0xb6c
        .int 0xc191
        .int 0xa1de
        .org 0xb6c
    add zr, r4, r7
    st r11, r7, 0x6cfa
    st- lr, r9
    ld r2, r2, 0x4edf
    st r9, zr, 0x2c42
    ld- r11, lr
    ld- r9, lr
    st+ r10, r7
    +ld r9, r13
    st r13, r11, zr
    b r1
        .int 0x9f4f
        .int 0xc4ce
        .org 0x1414
    ld r3, r8, 0x3d64
    ld lr, r2, r8
    stm r5..r12, sp
    st r9, r1, 0xa0a1
    st r12, sp, lr
    st r9, zr, 0x3cdb
    st+ r11, lr
    st r3, r9, 0x7a98
    ld r8, r2, r13
    st r1, r11, lr
    st- r5, r3
    -ld r8, r8
    st r11, lr, 0x9b37
    st r10, r5, 0x6699
    st- r9, r7
    ld zr, r13, 0x3596
    -st r9, r7
    ld r10, r6, 0x68eb
    j 0x246
        .int 0xed40
        .int 0xddd3
        .org 0x246
    stm r7..r1, r8
    ld r10, r5, 0x6fbe
    st r10, r1, 0x71f7
    ld r12, lr, 0xeef4
    ld r5, r4, 0x56a9
    -ld r3, r12
    -ld r8, r5
    ld+ r6, r2
    +ld r2, r10
    ld r13, r5, 0xbf23
    -ld r11, r1
    st+ r7, r3
    ld r8, r12, 0x81fe
    ldm r12..lr, r9
    add r4, lr, r4
    st r6, r1, 0x3c23
    st r3, lr, 0x8687
    +ld r5, r8
    st r3, r6, 0x8f21
    +ld r6, r6
    st r8, r7, 0xa13f
    ld lr, r8, 0xd132
    ld r7, r10, r13
    ld r13, r1, r8
    -st r3, r11
    ld r8, sp, 0xcb1
    ld+ r12, r2
    st r7, r10, r3
    -st r13, r9
    jl r4
        .int 0x862a
        .int 0x5fb
        .org 0x83ff
    st lr, r3, r5
    ld+ zr, r3
    st r7, zr, 0x95bf
    jl r8
        .int 0x952d
        .int 0xf210
        .org 0xa113
    b 0xd51d
        .int 0xca92
        .int 0x5bfa
        .org 0x7631
    st r3, r11, r7
    b 0x89
        .int 0xc602
        .int 0xd3b3
        .org 0x76bc
    st+ zr, lr
    -st r4, r10
    -ld r9, r8
    ldm r2..r5, r12
    -st r1, r2
    st r8, r11, 0x8113
    ld r13, r11, 0x53f4
    j 0x91e
        .int 0xc0dc
        .int 0xef46
        .org 0x91e
    st r3, sp, r9
    -ld r1, r9
    ld r3, r5, r4
    ld- lr, r3
    ld zr, r9, 0x766e
    -st r1, r9
    ld lr, r9, 0xf979
    st r1, r7, r10
    st r4, r3, 0xe33b
    +st r6, r4
    ld- r13, r7
    ld r1, r6, r5
    ldm r3..r8, lr
    b r5
        .int 0x88d4
        .int 0x7a84
        .org 0xebf0
    add lr, r6, lr
    add r12, r1, lr
    st+ r7, r5
    -st r6, r13
    -ld r5, r4
    st- sp, r1
    st zr, sp, 0xe3c6
    st r7, r2, 0x60e
    j 0x9f66
        .int 0xfae1
        .int 0x39e9
        .org 0x9f66
    ld r12, sp, 0x4c91
    st+ r9, r3
    j 0xaab8
        .int 0x80a6
        .int 0xdb1a
        .org 0xaab8
    st- r3, r3
    ld r8, r5, r6
    add r6, r8, r8
    ld r5, r9, 0x8ac6
    +st r3, r11
    b lr
        .int 0x9846
        .int 0x3f22
        .org 0x1840
    j r8
        .int 0xc2d3
        .int 0x91f9
        .org 0x6800
    st- r8, r12
    -ld r6, r9
    +st r5, lr
    +st r13, lr
    j 0xcebc
        .int 0x8e17
        .int 0x2f8a
        .org 0xcebc
    ld r2, r3, 0x5460
    jl 0x77cf
        .int 0xdda3
        .int 0x8d20
        .org 0x77cf
    ld r1, r9, 0x1594
    ld r3, r11, 0x75f6
    +st r13, r5
    ldm zr..r11, r2
    st+ r2, r10
    +st r6, r13
    ld- r4, r8
    ld r10, r10, 0x292f
    st+ lr, r6
    ld+ r9, r8
    +ld r11, r7
    +ld r11, r11
    ld r12, sp, 0x7af0
    j 0xf4d6
        .int 0xec7b
        .int 0x1164
        .org 0xf4d6
    -st r7, r5
    st r3, r8, 0xbf0
    -st r9, r3
    ld lr, r3, 0x70f1
    +ld r4, r10
    b r10
        .int 0xbfa3
        .int 0x34bd
        .org 0x31da
    st r5, zr, 0xd551
    st r9, r2, r3
    ld r9, r10, 0x4c7f
    -st r10, r5
    j r2
        .int 0xec6a
        .int 0x2303
        .org 0x267d
    ld r13, r7, 0x84ec
    st+ r6, r4
    st r1, r10, r1
    ld zr, r10, 0xc7e0
    stm r9..sp, r9
    -st r5, r12
    st r7, r9, 0xd45
    st r10, r7, r10
    ld- r4, r1
    st- r6, r1
    st r10, sp, 0xc1f2
    b 0xde31
        .int 0x902
        .int 0xfea1
        .org 0x4be
    stm r10..r1, lr
    ld r7, r12, 0xa852
    ld zr, r10, 0xf1c0
    ld r10, r3, r3
    st r7, r7, 0x9554
    ld sp, r12, r7
    st r4, r3, 0x51a0
    j 0x23fa
        .int 0x5fb1
        .int 0x69e6
        .org 0x23fa
    st r11, r9, r1
    bl r8
        .int 0xf95d
        .int 0x61b3
        .org 0x6b17
    st r2, r9, 0x7dcd
    +ld r10, r7
    ld r1, r5, r12
    +ld r8, r4
    -st zr, r3
    st- sp, r11
    ld r13, r8, r8
    +ld r12, r12
    st sp, r7, 0xa8da
    jl 0x907b
        .int 0x96a6
        .int 0xed6a
        .org 0x907b
    -st r2, r12
    -st r3, r13
    -ld r3, r3
    +ld lr, sp
    st r11, r12, 0x9e89
    b r2
        .int 0x44f2
        .int 0x5a1f
        .org 0xb6fe
    st r5, r12, 0x7bc7
    j 0xb4ea
        .int 0x83cf
        .int 0xcef9
        .org 0xb4ea
    st r4, lr, 0x75cd
    jl 0x6dce
        .int 0x7f08
        .int 0x86d0
        .org 0x6dce
    ld sp, sp, 0x5893
    st r1, zr, 0xfbad
    ld r5, r1, 0xc6e8
    ld- r9, lr
    st r1, r11, 0xc2c8
    st r9, r10, 0xbc8b
    st+ r1, r8
    +st r9, sp
    -ld r3, r11
    -st r11, r11
    +st r9, r7
    ldm r11..r9, r5
    st+ r12, r13
    st- sp, r9
    ld- r10, sp
    ld- r10, r13
    st lr, r6, lr
    ld r4, r9, 0x8d5f
    ldm r11..r3, r10
    st- r1, r12
    ld r10, r10, 0xf2fe
    ldm r12..r4, r3
    st- r1, r5
    st- r11, r2
    st r2, r7, r3
    stm r10..r12, r12
    stm r10..r3, r13
    +ld r12, sp
    -ld r8, r10
    ld+ r1, r2
    -ld r6, r11
    st r12, r7, zr
    j 0x722f
        .int 0xea7f
        .int 0x4e7a
        .org 0x722f
    -ld zr, r4
    ld sp, r13, 0x904d
    st r10, zr, 0xd034
    stm r5..lr, r8
    st r11, r5, 0x3e51
    ld r2, r10, r7
    ld r11, r9, 0xea5c
    ld sp, r4, r7
    b r12
        .int 0xe2d3
        .int 0x2824
        .org 0x5fe9
    ld r4, r7, 0x3c64
    j r4
        .int 0x84ed
        .int 0xdf64
        .org 0x6b68
    st+ r11, sp
    ld r10, r5, 0x44cd
    bl 0x7b57
        .int 0xc66c
        .int 0x6a2c
        .org 0xe6c3
    ld r5, sp, 0x46c1
    ld+ r11, sp
    stm r13..r12, sp
    ld r1, r5, lr
    st r1, zr, 0xb240
    +ld r12, r6
    j r1
        .int 0xee23
        .int 0x4aa1
        .org 0xf784
    jl r12
        .int 0x6641
        .int 0x7824
        .org 0x706b
    ld zr, sp, 0x4939
    ld r12, r8, 0xd269
    ld r3, zr, 0xd96b
    ld r12, r3, lr
    b r11
        .int 0xd2cf
        .int 0xabb9
        .org 0xc6b6
    st r11, r6, r8
    +ld r8, r2
    st lr, r7, r7
    stm r13..sp, r10
    ld+ r1, lr
    ld r1, r2, r5
    st r8, r8, r2
    st r3, r7, 0x1486
    -ld r9, r2
    +st r3, lr
    st r12, r10, 0x827d
    -ld lr, r2
    ld sp, r2, r12
    +st r2, r7
    -st r13, r6
    st sp, r8, r11
    +st r12, r3
    ld r2, r1, 0x8190
    ldm r3..r4, r1
    st r13, r5, r6
    ld r5, lr, 0xb56a
    -st lr, r6
    +st r1, sp
    st- r8, r2
    st r6, r9, r13
    ld lr, sp, r7
    ld+ r11, r9
    -st lr, r3
    ld r13, zr, 0x960
    stm r12..r13, r12
    st r3, r3, 0xe9c2
    ld- lr, r13
    ld r6, lr, 0x9a1f
    ldm r2..r13, r9
    +ld r4, r8
    +ld r5, r10
    ld r10, zr, 0xd499
    j 0x22c
        .int 0xb8ed
        .int 0x4e49
        .org 0x22c
    add zr, r11, r10
    st+ r10, r12
    jl 0x467c
        .int 0x698
        .int 0x4c28
        .org 0x467c
    j 0x2bd2
        .int 0x7a09
        .int 0x10a5
        .org 0x2bd2
    +st r10, r3
    j 0x93a8
        .int 0x8d5f
        .int 0x6811
        .org 0x93a8
    ld r6, r3, 0x28e1
    st r11, r11, 0x7946
    +st sp, r6
    jl 0x1d82
        .int 0x4d61
        .int 0x14b
        .org 0x1d82
    ld r8, zr, 0xebc9
    ld- sp, r12
    st+ r13, r8
    ld- r10, lr
    -st zr, r12
    st r7, r12, 0x6d2c
    st- r3, r9
    ld r6, r2, r13
    -ld r1, r12
    ld- sp, r8
    st r4, zr, 0x4791
    -ld zr, r10
    ld+ r1, r9
    st+ r8, r1
    ld zr, zr, 0xd80
    bl 0x2922
        .int 0xdbac
        .int 0x9bef
        .org 0x46b8
    st- r1, r4
    -ld r3, r12
    b 0xb43
        .int 0xf4fa
        .int 0xe40e
        .org 0x51fe
    st r2, zr, 0xa625
    st sp, r11, 0x861e
    st r11, sp, 0xee05
    +ld r13, r6
    ld lr, r10, 0xb353
    st r5, r7, r2
    ld r7, r9, 0x6a57
    +ld r10, r5
    ld r9, r2, r1
    ld r2, r12, 0xb3da
    ld r4, r9, 0x184b
    ld- r7, r10
    st r2, r12, 0xcac8
    bl r9
        .int 0xb8e1
        .int 0x682f
        .org 0xcf32
    st- r3, r4
    bl lr
        .int 0x74b9
        .int 0xb285
        .org 0x2147
    ld r1, r13, 0xba83
    st r12, r11, lr
    ld r6, r6, r1
    st r7, r3, 0xff56
    -ld sp, r7
    st r5, zr, 0x9de6
    st zr, zr, 0xb89c
    -st r9, r3
    -ld r4, r12
    ld r7, r10, 0x6bc
    ld sp, r3, 0xd888
    +ld zr, r1
    -st r12, r10
    jl 0x3ebd
        .int 0x26b1
        .int 0x567c
        .org 0x3ebd
    st- r4, r6
    st lr, zr, 0x3beb
    ld r10, r8, 0x457c
    +ld zr, r9
    st lr, r11, r1
    j 0x34f3
        .int 0x45ea
        .int 0x9fb7
        .org 0x34f3
    ld- r12, r7
    ld lr, r10, 0x7ef6
    jl 0xe7f2
        .int 0x6013
        .int 0xaf67
        .org 0xe7f2
    ld+ r2, sp
    st r7, r4, r9
    ld+ zr, r2
    -ld r5, r8
    ld sp, r12, r7
    ld sp, r11, 0x740
    st r12, r8, 0x857a
    st- r10, sp
    add r5, r3, r9
    j 0x8d57
        .int 0x169c
        .int 0xa0d0
        .org 0x8d57
    +ld r3, r1
    st+ r10, r6
    st+ r7, r3
    -ld r5, sp
    ld r7, zr, 0x5bb6
    b r11
        .int 0x10b1
        .int 0xd821
        .org 0xbe82
    +ld r4, r12
    add r9, sp, r6
    st r10, r4, r12
    ld r9, r12, 0x8181
    ld r9, lr, 0x8dd5
    -st r3, r8
    add r5, r3, r6
    +ld r11, lr
    ld r2, zr, 0x43e8
    +ld r13, r1
    b 0x1c43
        .int 0xdf2e
        .int 0x3943
        .org 0xdad3
    +ld r11, sp
    st r12, zr, 0xbf48
    st r2, r2, 0x433d
    ld lr, sp, 0x6f31
    st+ r2, r11
    ldm r10..zr, r5
    -st r6, lr
    ld sp, r11, 0x64cc
    st r12, r6, r11
    st- zr, r12
    stm r4..r3, r2
    ld- r2, r10
    j 0x5036
        .int 0xc2ae
        .int 0x1b38
        .org 0x5036
    b r7
        .int 0x899a
        .int 0xf767
        .org 0xaaa5
    b r3
        .int 0xd178
        .int 0xcce6
        .org 0x9f40
    ld+ lr, r3
    -st r5, r13
    st r6, r6, 0x841a
    -st r6, r2
    ld r6, r2, 0x7828
    st- sp, r6
    j r3
        .int 0x9ff3
        .int 0x8c00
        .org 0xf49c
    -st r13, r8
    ld r10, r1, 0xc1b1
    st r1, r5, 0x9037
    b r3
        .int 0xca17
        .int 0x203c
        .org 0xe93d
    -ld r3, r9
    stm r8..r12, r11
    b r9
        .int 0x5a4d
        .int 0xd63
        .org 0x1ead
    add lr, r2, zr
    +st r3, r3
    ld+ r1, r6
    ld r10, r6, r4
    st r13, zr, 0xd84b
    ld zr, r6, 0xfaf9
    st r7, r3, 0xa8fe
    ld r13, r11, 0x96c6
    b r13
        .int 0x85da
        .int 0xec1d
        .org 0xa230
    -ld r3, r11
    ld sp, zr, 0xe7f
    ld r9, r5, 0x8ef7
    -ld r12, r9
    st+ r2, r3
    b r4
        .int 0x7749
        .int 0xaf8e
        .org 0x9b43
    add r5, r6, r1
    ld lr, r10, r3
    -ld r2, r1
    b r4
        .int 0x8d91
        .int 0xd32b
        .org 0x9452
    bl r6
        .int 0x187
        .int 0xe371
        .org 0xff5a
    j lr
        .int 0xd3a0
        .int 0xcdde
        .org 0x9453
    -ld r10, r5
    ld r4, r5, 0x5cdd
    st r4, r5, 0xddd
    ld r11, zr, 0xe310
    st- sp, r11
    ld r3, r5, 0xb71d
    ld- r11, sp
    st sp, r5, 0x767b
    ld r5, zr, 0x6ac8
    st r3, r7, 0x59da
    j r12
        .int 0x12d
        .int 0x2810
        .org 0x7f78
    ld r4, zr, r13
    ld r10, r2, r4
    st r3, r2, 0xec0
    -st r9, sp
    b r9
        .int 0xfc7a
        .int 0x7ab1
        .org 0x3912
    +st r2, r5
    st r8, zr, 0xcc5c
    b 0xe1f3
        .int 0xf7b5
        .int 0xbb2b
        .org 0x1b09
    +st sp, r11
    st r11, lr, r13
    st r12, r2, lr
    st+ r10, r7
    b r4
        .int 0x859
        .int 0xa434
        .org 0x5b30
    j r4
        .int 0x5b03
        .int 0x4c4b
        .org 0x4023
    ld r9, r5, 0xdb99
    ld sp, lr, 0x5851
    ld r8, r12, 0x8e1c
    ld r4, r9, r13
    st r2, zr, r10
    st r11, r8, r1
    j 0x2f84
        .int 0xc380
        .int 0x3211
        .org 0x2f84
    ld r8, r1, 0x4228
    jl 0xbd11
        .int 0xaca1
        .int 0x5de6
        .org 0xbd11
    -st r9, r2
    +st r5, r9
    st r9, sp, r8
    ld r3, lr, zr
    j 0xc183
        .int 0x9ba9
        .int 0xb24b
        .org 0xc183
    st r13, r6, 0xa870
    st r5, r12, 0xea7e
    ld r6, r9, r1
    +st r12, r10
    ld+ r1, r6
    ld r11, r10, 0x220d
    st r4, r3, 0x3ab9
    +ld zr, r8
    ld zr, r4, r1
    ld- r5, sp
    b 0x7b8a
        .int 0xc8c4
        .int 0xd898
        .org 0x3d1c
    st+ r4, sp
    b r6
        .int 0x6f3
        .int 0xf72a
        .org 0x6d9b
    ld r1, zr, 0xe609
    ld r8, zr, r5
    +st r4, r3
    ld lr, r13, 0x65cb
    ldm r11..lr, r7
    stm r6..r2, r1
    ld r10, r7, 0x5a98
    st r5, r11, 0x47e6
    b r4
        .int 0x159a
        .int 0x4386
        .org 0xfbb7
    b r4
        .int 0x96fb
        .int 0x1e92
        .org 0x89c7
    st- r1, r6
    ld zr, r13, 0xcc23
    ld r1, r2, r10
    st+ r11, r8
    st r12, sp, 0x8eee
    st r5, lr, 0x3514
    stm zr..r10, r1
    st+ r2, r8
    jl 0x9844
        .int 0xcf3b
        .int 0xa19f
        .org 0x9844
    stm lr..r8, r10
    ld sp, sp, 0x3dfe
    -st r2, r9
    +ld zr, r8
    ld r2, r10, 0x45d5
    ld sp, r10, 0x72a
    st r10, r4, 0x45cb
    st r4, lr, r5
    add lr, r11, r6
    st r6, r4, 0xec5b
    ld r12, r11, r2
    st zr, r13, 0x81c6
    jl 0x582f
        .int 0xe9bc
        .int 0x7b13
        .org 0x582f
    -st zr, r9
    st+ sp, r11
    -ld zr, r13
    j 0x8503
        .int 0x7f2c
        .int 0xc9c5
        .org 0x8503
    ld r1, r9, 0x7e62
    ld+ r3, r1
    bl 0x3208
        .int 0x8737
        .int 0x49f0
        .org 0xb70f
    b r12
        .int 0x80a6
        .int 0xabe4
        .org 0x1a06
    ld r4, r1, r1
    st r6, r11, 0xd9b3
    ld r6, r7, 0x8b0f
    j r11
        .int 0x6fd0
        .int 0xfed2
        .org 0xe6ac
    +st r6, lr
    -st r10, r3
    st r3, r10, 0x4211
    st- r8, r12
    add r11, r11, r12
    st r13, r10, r7
    ld r12, r7, 0x1cb2
    bl r13
        .int 0x7a4c
        .int 0x319
        .org 0xfb6e
    -ld r11, r2
    st r2, r10, 0xf638
    +st r5, r6
    st r5, r1, 0x39d4
    st r9, r9, 0x1eb6
    st r13, r13, 0x5b89
    +ld r8, r2
    st r10, r10, 0x638e
    bl r3
        .int 0x4191
        .int 0x5b2b
        .org 0x8849
    b lr
        .int 0x7be2
        .int 0x94bb
        .org 0x83c5
    +st r12, r13
    ld r6, r11, 0x6edf
    ldm r2..zr, r1
    -ld sp, r8
    -st r1, r11
    j r5
        .int 0x1a3c
        .int 0x3701
        .org 0x4507
    +ld r3, lr
    ld r1, zr, 0x8411
    stm sp..r3, sp
    b r9
        .int 0x4f8b
        .int 0x8877
        .org 0x9d66
    st r8, r8, 0x100d
    ld r4, r5, r13
    +ld r4, r1
    st sp, r5, r10
    -ld r4, r3
    -ld r9, r3
    ld r6, zr, 0x8360
    st- r1, r4
    ld r10, r7, 0xd972
    ld r6, zr, 0x3d27
    st+ r10, r6
    -ld r7, r11
    ld- r11, r4
    jl 0x2b1f
        .int 0x53d6
        .int 0x5644
        .org 0x2b1f
    st r4, r9, r13
    ld+ r4, r11
    jl 0x45b8
        .int 0x7a92
        .int 0x9a6a
        .org 0x45b8
    ld r12, r5, 0x468
    ld+ r13, r11
    +st r9, r4
    j 0x8b82
        .int 0x1c95
        .int 0x82d5
        .org 0x8b82
    ld r1, r7, 0x4047
    b 0xd9b7
        .int 0x162
        .int 0x65a7
        .org 0x653c
    ld r10, zr, 0x86bb
    j 0x279a
        .int 0xb26
        .int 0xa405
        .org 0x279a
    j 0x20f9
        .int 0x3cd5
        .int 0x747e
        .org 0x20f9
    ld r3, r11, 0xb6dd
    +st r13, r7
    -st r3, sp
    stm r13..zr, r9
    st r10, r9, 0xf94f
    -st r7, r2
    ld r10, lr, 0xfd04
    st r12, sp, 0x75f2
    ld r10, r3, 0x50d3
    st r5, r1, 0x36c7
    st r12, r13, r9
    jl lr
        .int 0x73ba
        .int 0xb057
        .org 0x2b23
    b 0x5e65
        .int 0x3b9
        .int 0x4da7
        .org 0x8989
    st r4, r9, 0xc490
    ld sp, r3, 0x8dfe
    st lr, r4, 0x6a32
    -ld r7, r1
    ld r10, r5, 0x37a9
    j 0xd2fa
        .int 0xbd7a
        .int 0x14c2
        .org 0xd2fa
    ld r13, r10, 0x9d3b
    ld r13, r12, 0x71ab
    b r8
        .int 0xe9ce
        .int 0x12a9
        .org 0x2916
    st+ r4, r12
    ld r7, r9, 0xf2a5
    ld r12, r8, 0xb597
    +ld sp, r12
    ld r4, r13, r9
    st+ r1, lr
    st r9, zr, 0x4a1b
    ld lr, r11, 0x5166
    ld+ r2, sp
    +st r7, r7
    st r2, r5, 0xeaf5
    -ld r5, r3
    +ld r5, r10
    ld lr, r9, 0x2142
    bl 0xeb14
        .int 0x209b
        .int 0x27d7
        .org 0x143f
    ld+ lr, r11
    st+ r8, sp
    ld r11, r12, r6
    +st r1, r13
    ld- r6, r2
    -st r1, r2
    +ld r12, r10
    st r4, r3, 0x8f0f
    -ld sp, r4
    st r4, r8, 0x6721
    ld r10, r3, 0x646
    st r9, r3, 0xd8d1
    ld r5, r13, 0x9cfe
    +st r11, r1
    j 0x3cbc
        .int 0xc6c2
        .int 0xfff8
        .org 0x3cbc
    +st lr, sp
    +st r12, r13
    ld r6, r7, 0x95cb
    +st r2, r2
    st- r5, lr
    st r13, r9, 0xacdc
    st+ r13, r6
    b r2
        .int 0x325f
        .int 0x65a0
        .org 0xd904
    j 0x8e0a
        .int 0x4dcb
        .int 0xcd88
        .org 0x8e0a
    st r5, zr, 0xec1c
    ld r7, r10, r8
    +ld r12, r13
    st r3, r5, r1
    st r1, r1, 0x6d89
    st r8, r1, r1
    ld r13, r4, 0xfe37
    +st r3, r12
    st r13, r10, r13
    b r1
        .int 0x20b9
        .int 0x6f08
        .org 0x9712
    j 0x7b3f
        .int 0x3e95
        .int 0x46de
        .org 0x7b3f
    ld r10, r9, 0x2967
    j 0xc6fa
        .int 0x3328
        .int 0xde1d
        .org 0xc6fa
    ldm r12..zr, r13
    ld r9, r11, 0x1e8b
    bl r10
        .int 0x16ac
        .int 0xe5b8
        .org 0x1946
    b r8
        .int 0xf9f5
        .int 0xdfb5
        .org 0x6f5e
    st r9, sp, r7
    bl r9
        .int 0x66f4
        .int 0x78df
        .org 0xe863
    st r13, r7, 0xe0b3
    j 0xd780
        .int 0x2a9b
        .int 0xf3b5
        .org 0xd780
    ld- r3, r11
    st sp, r5, 0x50fa
    j r12
        .int 0xc1ac
        .int 0x32db
        .org 0xe06c
    st r6, r12, r13
    +st lr, r6
    ld- r9, r5
    ld r1, r1, 0x6641
    jl 0x7ad2
        .int 0x99ff
        .int 0xcddd
        .org 0x7ad2
    ld r10, r9, r13
    ldm r7..r9, r13
    ld- zr, r5
    st+ sp, r11
    +st r1, r7
    ld r12, sp, r7
    st r3, r11, r3
    b r4
        .int 0x2e45
        .int 0xc3dd
        .org 0xb6db
    j 0xcfae
        .int 0x7083
        .int 0x5256
        .org 0xcfae
    ld r9, r13, 0x12c4
    -ld r7, r6
    st- r6, r9
    +st r12, sp
    ld r7, r2, r5
    ld+ r2, r8
    st r2, r3, 0xed0f
    ld r12, r3, r7
    ld r3, zr, 0x6fb1
    +st r13, r10
    ld- r5, r8
    bl r8
        .int 0xc46b
        .int 0x9083
        .org 0x1ad0
    st sp, r9, r12
    st sp, r13, 0x4cc2
    st r1, r10, r4
    st lr, r9, 0x6edc
    +st r2, r5
    +st r13, r10
    st r8, r9, 0xf40c
    +ld r10, r10
    utx 0x40
    utx 0x40
    utx 0x45
    utx 0x4e
    utx 0x44
    utx 0x40
    utx 0x40
    utx zr
    b 0xffff
        .org 0x29db
        .int 0xddeb
        .org 0x1092
        .int 0xb02f
        .org 0xa936
        .int 0x4d7f
        .org 0x29da
        .int 0x9124
        .org 0x8ca5
        .int 0xba5
        .org 0x2fa7
        .int 0xd4b8
        .org 0x6d6c
        .int 0x2009
        .org 0xaf31
        .int 0x6e
        .org 0xad92
        .int 0xbdc3
        .org 0xa600
        .int 0x6c2c
        .org 0xc020
        .int 0x8d95
        .org 0x94f0
        .int 0x19de
        .org 0x19de
        .int 0xc9c1
        .org 0x19df
        .int 0xb29b
        .org 0x19e0
        .int 0xa6be
        .org 0x19e1
        .int 0x8abe
        .org 0x19e2
        .int 0xde3d
        .org 0x19e3
        .int 0xaee5
        .org 0x19e4
        .int 0xd381
        .org 0x19e5
        .int 0x7674
        .org 0x19e6
        .int 0x8f55
        .org 0x19e7
        .int 0x45d8
        .org 0x19e8
        .int 0xbe4d
        .org 0x19e9
        .int 0xf7ce
        .org 0x19ea
        .int 0xa0aa
        .org 0x19eb
        .int 0x2024
        .org 0x19ec
        .int 0x3fef
        .org 0x19ed
        .int 0x924d
        .org 0xb29b
        .int 0x2fe6
        .org 0x7675
        .int 0xb397
        .org 0xa2ce
        .int 0x7b70
        .org 0x7b71
        .int 0xa4ed
        .org 0x2024
        .int 0x8d1f
        .org 0x466d
        .int 0xe3c8
        .org 0xb396
        .int 0x6a02
        .org 0x84c1
        .int 0xb567
        .org 0x2fe5
        .int 0xbd2a
        .org 0xa4ed
        .int 0xbb7a
        .org 0xd381
        .int 0x2f1f
        .org 0xcaa5
        .int 0x8896
        .org 0xbe5a
        .int 0xf98a
        .org 0xbe5b
        .int 0xd71c
        .org 0xbe5c
        .int 0x988f
        .org 0xbe5d
        .int 0x687f
        .org 0x988f
        .int 0xe620
        .org 0x9890
        .int 0xbfc9
        .org 0x9891
        .int 0x85b0
        .org 0x9892
        .int 0xafc6
        .org 0x9893
        .int 0xf38e
        .org 0x9894
        .int 0xd0bb
        .org 0x9895
        .int 0xf433
        .org 0x85af
        .int 0x22fa
        .org 0xd71c
        .int 0x7ba0
        .org 0x2879
        .int 0xe2f5
        .org 0xbd76
        .int 0x653
        .org 0x5d18
        .int 0xaf09
        .org 0xc919
        .int 0xf499
        .org 0x687f
        .int 0x58b2
        .org 0x653
        .int 0x1ff4
        .org 0xd0bc
        .int 0x5490
        .org 0x7fc5
        .int 0x90d7
        .org 0xe724
        .int 0x4f06
        .org 0xc616
        .int 0xfa23
        .org 0xfa23
        .int 0x7aeb
        .org 0x651
        .int 0xaf57
        .org 0x7aec
        .int 0x291a
        .org 0x2296
        .int 0xde7b
        .org 0x95e5
        .int 0xd43c
        .org 0x2fe4
        .int 0xfdb0
        .org 0x7c5e
        .int 0x2e24
        .org 0x16e
        .int 0x5348
        .org 0x5999
        .int 0x705e
        .org 0x9a89
        .int 0x677
        .org 0xd43c
        .int 0x6446
        .org 0x5348
        .int 0xfeb7
        .org 0xde7b
        .int 0xd6ed
        .org 0xde7c
        .int 0x1fbc
        .org 0xde7d
        .int 0x96a5
        .org 0xde7e
        .int 0xaba8
        .org 0xde7f
        .int 0xaad1
        .org 0xde80
        .int 0x2079
        .org 0xd6ed
        .int 0x2704
        .org 0xaad1
        .int 0x25cb
        .org 0x17a7
        .int 0xfdbb
        .org 0x705e
        .int 0xa5e3
        .org 0xe51a
        .int 0xb444
        .org 0xb661
        .int 0xa284
        .org 0xb444
        .int 0xd37d
        .org 0xfdbb
        .int 0xa2e7
        .org 0x53a7
        .int 0xac76
        .org 0xac75
        .int 0x5d3
        .org 0xf5d3
        .int 0x7ec5
        .org 0x705f
        .int 0xd3a9
        .org 0x8c76
        .int 0x8008
        .org 0xe29a
        .int 0x29d3
        .org 0x5d3
        .int 0xb95d
        .org 0x5d4
        .int 0x7845
        .org 0x5d5
        .int 0xfa3e
        .org 0x5d6
        .int 0x20ee
        .org 0x5d7
        .int 0x9751
        .org 0x5d8
        .int 0x99f3
        .org 0x5d9
        .int 0xc76d
        .org 0x5da
        .int 0xa798
        .org 0x5db
        .int 0x8f28
        .org 0x5dc
        .int 0xbfc5
        .org 0xb95c
        .int 0x3a3
        .org 0xb95e
        .int 0x3124
        .org 0xb101
        .int 0xbe2f
        .org 0x99f3
        .int 0x787
        .org 0x1fbb
        .int 0xf466
        .org 0x96a5
        .int 0x2a55
        .org 0xb3f8
        .int 0xf027
        .org 0x31ce
        .int 0x537f
        .org 0xc76c
        .int 0xe36b
        .org 0xf671
        .int 0xa7f8
        .org 0x1a60
        .int 0x8a31
        .org 0x542a
        .int 0xea7e
        .org 0x7e4d
        .int 0x5195
        .org 0x5195
        .int 0xd5ad
        .org 0x5196
        .int 0x6a89
        .org 0x5197
        .int 0x8e25
        .org 0x5198
        .int 0x6b55
        .org 0x5199
        .int 0xa7e
        .org 0x519a
        .int 0x250a
        .org 0x519b
        .int 0x8274
        .org 0x519c
        .int 0xd232
        .org 0x519d
        .int 0x9029
        .org 0x519e
        .int 0xf984
        .org 0x519f
        .int 0x7d06
        .org 0x51a0
        .int 0x9441
        .org 0x51a1
        .int 0x9119
        .org 0x51a2
        .int 0x545
        .org 0x51a3
        .int 0x6515
        .org 0xb68d
        .int 0x9675
        .org 0x98a3
        .int 0x279e
        .org 0x9029
        .int 0x258a
        .org 0x902a
        .int 0xe8c8
        .org 0x6b55
        .int 0x47f
        .org 0x9441
        .int 0x6395
        .org 0x8275
        .int 0xe3da
        .org 0xd5ac
        .int 0x2d40
        .org 0x6515
        .int 0x9fbd
        .org 0x59b8
        .int 0x31b8
        .org 0x8e25
        .int 0x14e2
        .org 0x8e26
        .int 0x6f2a
        .org 0x8e27
        .int 0xf5f5
        .org 0x8e28
        .int 0x41f0
        .org 0x8e29
        .int 0xa87a
        .org 0x8e2a
        .int 0x4526
        .org 0x8e2b
        .int 0xf3b6
        .org 0x8e2c
        .int 0x3331
        .org 0x8e2d
        .int 0xef3f
        .org 0x8e2e
        .int 0x926a
        .org 0x8e2f
        .int 0xf7fb
        .org 0x8e30
        .int 0x2beb
        .org 0xf5f5
        .int 0x19d3
        .org 0xf7fb
        .int 0xfdc5
        .org 0x31b7
        .int 0xf35e
        .org 0x41ef
        .int 0x67c7
        .org 0x47f
        .int 0x2c4c
        .org 0x480
        .int 0x1aac
        .org 0x481
        .int 0x46da
        .org 0x482
        .int 0x687b
        .org 0x483
        .int 0x496
        .org 0x484
        .int 0xb4df
        .org 0x485
        .int 0x6e4
        .org 0x486
        .int 0x2000
        .org 0x487
        .int 0xcb05
        .org 0x488
        .int 0x545b
        .org 0x489
        .int 0x12d1
        .org 0x48a
        .int 0xac76
        .org 0x48b
        .int 0x97bd
        .org 0x48c
        .int 0xac16
        .org 0xac76
        .int 0x7d44
        .org 0xac77
        .int 0x77d7
        .org 0xac78
        .int 0x765
        .org 0xac79
        .int 0x16d
        .org 0xac7a
        .int 0x6daa
        .org 0xac7b
        .int 0x7ffb
        .org 0xac7c
        .int 0xf82d
        .org 0xac7d
        .int 0x86d3
        .org 0xac7e
        .int 0xb6b8
        .org 0xac7f
        .int 0x6c2c
        .org 0xac80
        .int 0xcc8a
        .org 0xac81
        .int 0xcbb0
        .org 0xac82
        .int 0x248c
        .org 0xac83
        .int 0x9963
        .org 0xac84
        .int 0xb79a
        .org 0xac85
        .int 0x289
        .org 0x248c
        .int 0x3df4
        .org 0x248d
        .int 0x6642
        .org 0x248e
        .int 0xef7c
        .org 0x248f
        .int 0xf5dc
        .org 0x2490
        .int 0x4645
        .org 0x2491
        .int 0x36
        .org 0x2492
        .int 0xf2cc
        .org 0x2493
        .int 0xeb80
        .org 0x2494
        .int 0x359c
        .org 0x2495
        .int 0x8b5e
        .org 0xf5dc
        .int 0xc50c
        .org 0xeb80
        .int 0x58a8
        .org 0xa88e
        .int 0x38d8
        .org 0xcbb0
        .int 0x16e4
        .org 0xcbb1
        .int 0x5cd4
        .org 0xcbb2
        .int 0xf010
        .org 0x2757
        .int 0x89b
        .org 0xca1c
        .int 0x96c4
        .org 0xeb7e
        .int 0x9329
        .org 0xc50b
        .int 0x5223
        .org 0x2ff0
        .int 0x5066
        .org 0x5067
        .int 0xe7c4
        .org 0x36
        .int 0x9516
        .org 0x58a8
        .int 0x3139
        .org 0xe7c3
        .int 0x6638
        .org 0x5903
        .int 0xdecc
        .org 0x4645
        .int 0xc3a0
        .org 0x6ed3
        .int 0x3bac
        .org 0x6638
        .int 0x9010
        .org 0xdc41
        .int 0xfc67
        .org 0x9516
        .int 0x2760
        .org 0x9515
        .int 0x26e8
        .org 0xd664
        .int 0x5f68
        .org 0x275f
        .int 0x690d
        .org 0x5223
        .int 0xe782
        .org 0x8942
        .int 0xabe5
        .org 0xabe6
        .int 0x54d7
        .org 0x89a9
        .int 0x2417
        .org 0x8d19
        .int 0x7bb8
        .org 0x3615
        .int 0x92db
        .org 0x800e
        .int 0x4f83
        .org 0xf9ac
        .int 0x88fd
        .org 0x62c4
        .int 0xcf4d
        .org 0xc5f0
        .int 0x391f
        .org 0x54d6
        .int 0xc3ef
        .org 0x9525
        .int 0x9be9
        .org 0x4f83
        .int 0xe56d
        .org 0x4f82
        .int 0xab0
        .org 0xdece
        .int 0x2a6f
        .org 0x2527
        .int 0xfec5
        .org 0x83ac
        .int 0xc327
        .org 0x7ab7
        .int 0x1d70
        .org 0x1d6f
        .int 0xad06
        .org 0x1464
        .int 0xc320
        .org 0xe4a2
        .int 0x3333
        .org 0x93d4
        .int 0x2535
        .org 0xb21c
        .int 0x6b35
        .org 0x7d91
        .int 0xde8a
        .org 0x6b34
        .int 0xdecf
        .org 0xde89
        .int 0xe831
        .org 0x9be9
        .int 0x619e
        .org 0x2536
        .int 0x2ce4
        .org 0x9dac
        .int 0xac25
        .org 0x89a
        .int 0x1f70
        .org 0xed32
        .int 0x7d3c
        .org 0x2a6f
        .int 0x7680
        .org 0x2a70
        .int 0xc483
        .org 0x2a71
        .int 0x5d17
        .org 0x7d3d
        .int 0xb485
        .org 0x619f
        .int 0xd5c1
        .org 0x4e6f
        .int 0x91c1
        .org 0xe9b9
        .int 0x685
        .org 0x85d7
        .int 0x6c82
        .org 0x95ae
        .int 0xa113
        .org 0x2ce4
        .int 0xa498
        .org 0xded0
        .int 0x8573
        .org 0xa112
        .int 0x8314
        .org 0xa498
        .int 0xf1bc
        .org 0xa499
        .int 0xa893
        .org 0xa49a
        .int 0x191
        .org 0xa49b
        .int 0x9e56
        .org 0x7363
        .int 0x57c1
        .org 0x8313
        .int 0xcbd3
        .org 0x9fe7
        .int 0x9ebf
        .org 0x9ebf
        .int 0xf608
        .org 0xf981
        .int 0x74e1
        .org 0x7c8b
        .int 0x5a67
        .org 0x685
        .int 0x62e9
        .org 0x7417
        .int 0xa4d5
        .org 0x5a67
        .int 0xcfda
        .org 0x5a68
        .int 0x2d48
        .org 0x5a69
        .int 0xe2c2
        .org 0x5a6a
        .int 0x131b
        .org 0x5a6b
        .int 0xbc66
        .org 0x5a6c
        .int 0xd4d9
        .org 0x2d47
        .int 0x3a99
        .org 0xd58e
        .int 0x5780
        .org 0x4db4
        .int 0x6800
        .org 0xdd8
        .int 0x4d9b
        .org 0x8311
        .int 0x7667
        .org 0x243a
        .int 0xac0
        .org 0x98a5
        .int 0xf4ad
        .org 0x9566
        .int 0x1d3d
        .org 0xac0
        .int 0xa8a3
        .org 0xac1
        .int 0xa646
        .org 0xac2
        .int 0x267d
        .org 0xac3
        .int 0x2fa6
        .org 0xac4
        .int 0xed0a
        .org 0xac5
        .int 0x7433
        .org 0xac6
        .int 0x7200
        .org 0xac7
        .int 0xa001
        .org 0xac8
        .int 0x471c
        .org 0xac9
        .int 0x7577
        .org 0xaca
        .int 0x1b48
        .org 0xacb
        .int 0xb15
        .org 0x471c
        .int 0x60cf
        .org 0x4478
        .int 0x3cfc
        .org 0x471b
        .int 0x3ce5
        .org 0xa002
        .int 0x6cb8
        .org 0x6cb9
        .int 0xe842
        .org 0x3ed
        .int 0xf422
        .org 0xa096
        .int 0x6b4
        .org 0x3cfd
        .int 0x30b5
        .org 0x897c
        .int 0xf7ca
        .org 0x24ee
        .int 0x73eb
        .org 0x4dd
        .int 0x811f
        .org 0xa646
        .int 0x810b
        .org 0x9c73
        .int 0xe43f
        .org 0x2ebd
        .int 0xd354
        .org 0x5f4a
        .int 0x3bcf
        .org 0xd860
        .int 0x1667
        .org 0xe440
        .int 0xfae5
        .org 0x6852
        .int 0x938d
        .org 0x810c
        .int 0xc8cb
        .org 0x9196
        .int 0xcf9c
        .org 0xf422
        .int 0x938f
        .org 0x2fa3
        .int 0x43b9
        .org 0x1668
        .int 0xf897
        .org 0x6efb
        .int 0xf32f
        .org 0x5a75
        .int 0xfc7c
        .org 0xb4ee
        .int 0x6a91
        .org 0xe840
        .int 0x43a7
        .org 0xfc7c
        .int 0x4338
        .org 0xfc7d
        .int 0x9697
        .org 0xfc7e
        .int 0xa1ed
        .org 0xfc7f
        .int 0x55a5
        .org 0xfc80
        .int 0xe531
        .org 0xfc81
        .int 0xa072
        .org 0xfc82
        .int 0xbc94
        .org 0xfc83
        .int 0x52a8
        .org 0xfc84
        .int 0x83ee
        .org 0xfc85
        .int 0x6ccc
        .org 0xfc86
        .int 0xbb1c
        .org 0xfc87
        .int 0xb91f
        .org 0xfc88
        .int 0xe52e
        .org 0xfc89
        .int 0x4303
        .org 0xfc8a
        .int 0x49dc
        .org 0xe531
        .int 0xc441
        .org 0xa1ee
        .int 0x7fd3
        .org 0xd73a
        .int 0x504
        .org 0x7fd3
        .int 0xad7c
        .org 0x7fd4
        .int 0x77c9
        .org 0x7fd5
        .int 0x1320
        .org 0x7fd6
        .int 0x1ab2
        .org 0x7fd7
        .int 0x7731
        .org 0x7fd8
        .int 0xac58
        .org 0x7fd9
        .int 0x427c
        .org 0x7fda
        .int 0x9ad4
        .org 0x7fdb
        .int 0x3148
        .org 0x72d1
        .int 0xcffe
        .org 0x3148
        .int 0xb611
        .org 0x3149
        .int 0x9783
        .org 0x314a
        .int 0xbdf5
        .org 0x314b
        .int 0xc673
        .org 0x314c
        .int 0x3028
        .org 0x314d
        .int 0xcd9a
        .org 0x314e
        .int 0xbb50
        .org 0x314f
        .int 0xc933
        .org 0x3150
        .int 0xa569
        .org 0xc674
        .int 0xedae
        .org 0xcffd
        .int 0x195e
        .org 0xbb4f
        .int 0x1aa
        .org 0xad7b
        .int 0xd078
        .org 0xa568
        .int 0x3aae
        .org 0x27d0
        .int 0xee2e
        .org 0xb52b
        .int 0x4f5c
        .org 0x3437
        .int 0xb608
        .org 0x8a96
        .int 0x69bb
        .org 0x2192
        .int 0x6b68
        .org 0xffe8
        .int 0xa1c7
        .org 0xb07d
        .int 0x4b3
        .org 0x69bc
        .int 0x5644
        .org 0x7020
        .int 0xf784
        .org 0xd079
        .int 0x706b
        .org 0xb2f6
        .int 0x2dff
        .org 0xebc7
        .int 0x8b31
        .org 0xd96b
        .int 0xf155
        .org 0xe8da
        .int 0x8931
        .org 0x4f5d
        .int 0x2f10
        .org 0xf785
        .int 0xd73
        .org 0x5410
        .int 0x65f6
        .org 0x4f5c
        .int 0x6cdd
        .org 0x4f5b
        .int 0x23cf
        .org 0xd88c
        .int 0x93c9
        .org 0xe786
        .int 0x7759
        .org 0x65f6
        .int 0xc073
        .org 0x65f7
        .int 0xe87
        .org 0xd939
        .int 0x6676
        .org 0x78f9
        .int 0xaa1d
        .org 0x6cdd
        .int 0x239d
        .org 0x960
        .int 0x7fbc
        .org 0x7fbc
        .int 0xade2
        .org 0x4801
        .int 0xbca1
        .org 0x6cde
        .int 0x9052
        .org 0x6cdf
        .int 0x9629
        .org 0x6ce0
        .int 0xa422
        .org 0x6ce1
        .int 0x9a37
        .org 0x6ce2
        .int 0x1964
        .org 0x6ce3
        .int 0x951c
        .org 0x6ce4
        .int 0x8f06
        .org 0x6ce5
        .int 0x7146
        .org 0x6ce6
        .int 0xb736
        .org 0x6ce7
        .int 0x3125
        .org 0x6ce8
        .int 0xa25f
        .org 0x6ce9
        .int 0x8ced
        .org 0x8f07
        .int 0x67a4
        .org 0xb737
        .int 0x78f6
        .org 0xd499
        .int 0x7357
        .org 0xbf0b
        .int 0xab57
        .org 0xebc9
        .int 0xb3aa
        .org 0xa260
        .int 0x7d61
        .org 0x93af
        .int 0xb353
        .org 0x1d3f
        .int 0xa9c
        .org 0xa25d
        .int 0x75
        .org 0xb3ab
        .int 0x13ac
        .org 0xb352
        .int 0x8428
        .org 0x7145
        .int 0x828a
        .org 0xd80
        .int 0x64a0
        .org 0xa25c
        .int 0xfdc7
        .org 0xa9d
        .int 0xb922
        .org 0x66a5
        .int 0xd850
        .org 0xdb9d
        .int 0x3e87
        .org 0x78f7
        .int 0xde46
        .org 0x12dd
        .int 0x7d1f
        .org 0x5636
        .int 0xa00f
        .org 0x956a
        .int 0x5698
        .org 0xde46
        .int 0xc6a9
        .org 0x73a5
        .int 0x35ef
        .org 0x408c
        .int 0x4e6b
        .org 0xc6a8
        .int 0x3401
        .org 0xa25b
        .int 0xda0e
        .org 0xe501
        .int 0xd923
        .org 0xd64e
        .int 0x31b
        .org 0x35f0
        .int 0x3a35
        .org 0xf926
        .int 0x1ff7
        .org 0x7d20
        .int 0x54fb
        .org 0xd923
        .int 0x7d0e
        .org 0x9eed
        .int 0xca19
        .org 0x31b
        .int 0x3c8c
        .org 0x3c8c
        .int 0xcac4
        .org 0xb3a9
        .int 0x94f1
        .org 0x5630
        .int 0x847
        .org 0x3865
        .int 0xef84
        .org 0x35f1
        .int 0xf49a
        .org 0xef82
        .int 0x8f26
        .org 0x5bb6
        .int 0x5a6f
        .org 0x7d0f
        .int 0xf90c
        .org 0xfe90
        .int 0xb490
        .org 0xc2cd
        .int 0x356f
        .org 0x34f9
        .int 0x90d1
        .org 0x43e8
        .int 0xf92b
        .org 0x35f2
        .int 0x32ec
        .org 0xef83
        .int 0x2e20
        .org 0x5eb4
        .int 0x5953
        .org 0x4306
        .int 0xbd4
        .org 0x4307
        .int 0x484c
        .org 0x4308
        .int 0x3613
        .org 0x4309
        .int 0x33bd
        .org 0x430a
        .int 0x9650
        .org 0x430b
        .int 0x162a
        .org 0x430c
        .int 0x21
        .org 0xad18
        .int 0xe353
        .org 0xbd4
        .int 0x5ee2
        .org 0xf49b
        .int 0xb83f
        .org 0xd709
        .int 0x6b08
        .org 0xf7a3
        .int 0x49a0
        .org 0x356e
        .int 0x9fe
        .org 0x6b07
        .int 0xa031
        .org 0x6414
        .int 0x5015
        .org 0x6601
        .int 0x7dfd
        .org 0xdf12
        .int 0x8377
        .org 0x484b
        .int 0xf721
        .org 0xe7f
        .int 0x770a
        .org 0xd1fd
        .int 0xb996
        .org 0xb995
        .int 0x7f78
        .org 0x4737
        .int 0x2b85
        .org 0xa030
        .int 0x5b6d
        .org 0xb38
        .int 0x73b3
        .org 0x6815
        .int 0x934c
        .org 0xe310
        .int 0x831b
        .org 0xc255
        .int 0x7f23
        .org 0x770a
        .int 0x43c8
        .org 0x6ac8
        .int 0x5cff
        .org 0x8377
        .int 0x4023
        .org 0x9b90
        .int 0xc59a
        .org 0x3899
        .int 0xfca2
        .org 0xeca4
        .int 0xfd0b
        .org 0xd94
        .int 0x7661
        .org 0x8019
        .int 0x8e10
        .org 0xe258
        .int 0xa1f5
        .org 0x2f88
        .int 0x5cf1
        .org 0x9cd3
        .int 0x307d
        .org 0x307d
        .int 0x23aa
        .org 0xe7a8
        .int 0x43d5
        .org 0xa1f6
        .int 0xff24
        .org 0xb1ba
        .int 0x475a
        .org 0xfd0b
        .int 0x71ea
        .org 0xe609
        .int 0x1bf4
        .org 0x71ea
        .int 0x1aa6
        .org 0xe942
        .int 0x9b3c
        .org 0x5a70
        .int 0xe6ab
        .org 0x5a71
        .int 0xbaab
        .org 0x5a72
        .int 0x14ba
        .org 0x5a73
        .int 0xaf91
        .org 0xb508
        .int 0x67df
        .org 0xe0dd
        .int 0xcd03
        .org 0xc34b
        .int 0x3e7a
        .org 0x3b09
        .int 0x51d7
        .org 0x1aa9
        .int 0xf0d9
        .org 0xadb4
        .int 0x2075
        .org 0x6f09
        .int 0x31ae
        .org 0x720
        .int 0x62f7
        .org 0x14b9
        .int 0x7bcb
        .org 0x7b03
        .int 0x46a
        .org 0x46a
        .int 0x8ccf
        .org 0x8d6
        .int 0x2341
        .org 0xe57f
        .int 0x5c76
        .org 0x7722
        .int 0xe389
        .org 0x2074
        .int 0x9ecd
        .org 0x2075
        .int 0x5dfc
        .org 0xdac
        .int 0x3662
        .org 0x46b
        .int 0x619f
        .org 0x46c
        .int 0xfe4f
        .org 0x46d
        .int 0x580b
        .org 0x46e
        .int 0x4507
        .org 0x46f
        .int 0x76b7
        .org 0x470
        .int 0xe40c
        .org 0x471
        .int 0x5619
        .org 0x472
        .int 0x585b
        .org 0x473
        .int 0x350d
        .org 0x474
        .int 0x2210
        .org 0x475
        .int 0xed61
        .org 0x476
        .int 0x3d25
        .org 0x477
        .int 0x1549
        .org 0x478
        .int 0x87fe
        .org 0x479
        .int 0x6c71
        .org 0x5618
        .int 0x2b05
        .org 0x154a
        .int 0x480c
        .org 0x8411
        .int 0xf70f
        .org 0x822c
        .int 0xe7f
        .org 0xf710
        .int 0xbad5
        .org 0x480b
        .int 0xac50
        .org 0x480a
        .int 0x5ed
        .org 0x8360
        .int 0xa9eb
        .org 0xbd7e
        .int 0xc170
        .org 0x3d27
        .int 0x135a
        .org 0x220e
        .int 0x889e
        .org 0xac4f
        .int 0xa742
        .org 0xa742
        .int 0xe657
        .org 0x496f
        .int 0xfe1c
        .org 0xa743
        .int 0xc390
        .org 0xc8e5
        .int 0x8fc
        .org 0x86bb
        .int 0x22b4
        .org 0x5e21
        .int 0x95ae
        .org 0x2827
        .int 0x2ce8
        .org 0xe681
        .int 0xeb5c
        .org 0x23ac
        .int 0x7c9e
        .org 0x8fb
        .int 0xbefa
        .org 0x7cb0
        .int 0xbd48
        .org 0x5a83
        .int 0xb297
        .org 0x6fc7
        .int 0x28ab
        .org 0xf892
        .int 0xaac2
        .org 0xbaf
        .int 0x2f74
        .org 0x2f75
        .int 0xff6
        .org 0x2e98
        .int 0x3c03
        .org 0xf8aa
        .int 0xabfc
        .org 0xff6
        .int 0x9c40
        .org 0x95ad
        .int 0x6b51
        .org 0xbd49
        .int 0xae20
        .org 0x272f
        .int 0x876d
        .org 0xa744
        .int 0xa5de
        .org 0x42d0
        .int 0x23c0
        .org 0x9c40
        .int 0xd5b5
        .org 0xbd4a
        .int 0xf969
        .org 0x3c02
        .int 0x505
        .org 0x9bf3
        .int 0xd3db
        .org 0xc5aa
        .int 0x7185
        .org 0x408e
        .int 0x7410
        .org 0x29f3
        .int 0x89d0
        .org 0x28ae
        .int 0x1999
        .org 0x3a39
        .int 0xac36
        .org 0x2f54
        .int 0x5249
        .org 0xac36
        .int 0xe06c
        .org 0xac37
        .int 0xbef0
        .org 0xac38
        .int 0xf8f1
        .org 0xac39
        .int 0xbc06
        .org 0xac3a
        .int 0x4bfc
        .org 0x424b
        .int 0x7904
        .org 0x23c0
        .int 0x5478
        .org 0x7185
        .int 0x66d2
        .org 0x6f3d
        .int 0x2436
        .org 0x25c2
        .int 0xa08f
        .org 0xbef0
        .int 0xc28e
        .org 0xbef1
        .int 0x4b14
        .org 0xbef2
        .int 0x7f37
        .org 0x7184
        .int 0xb28a
        .org 0x7e95
        .int 0x90a8
        .org 0xd1b4
        .int 0x7c02
        .org 0x7411
        .int 0x5eb5
        .org 0xdc2
        .int 0x2fbb
        .org 0x4b14
        .int 0xf20b
        .org 0x8433
        .int 0xd2d3
        .org 0x6fb1
        .int 0xc305
        .org 0x4b15
        .int 0x350d
        .org 0xa092
        .int 0x89d5
