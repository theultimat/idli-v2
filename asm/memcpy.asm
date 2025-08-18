    .include "test-wrapper.asm"


dst:    .space  128
src:    .int    0xb26b
        .int    0x6e32
        .int    0xb6df
        .int    0x86ba
        .int    0x1fb3
        .int    0x0f19
        .int    0xd679
        .int    0x4a8b
        .int    0x3e3e
        .int    0x0c4a
        .int    0xacb9
        .int    0x73bd
        .int    0x744a
        .int    0x0ddc
        .int    0x2b24
        .int    0x7d1a
        .int    0x0fce
        .int    0x3718
        .int    0x8b25
        .int    0x9a1c
        .int    0x4f42
        .int    0x411f
        .int    0xd3f2
        .int    0xfbc7
        .int    0x1c3b
        .int    0xe5be
        .int    0x8af4
        .int    0xf643
        .int    0x3910
        .int    0xf3ae
        .int    0x78cf
        .int    0x5ea6
        .int    0xcb80
        .int    0xc514
        .int    0x5830
        .int    0x2363
        .int    0x6cfc
        .int    0x052d
        .int    0xf425
        .int    0x8935
        .int    0x759f
        .int    0xe4b4
        .int    0x1531
        .int    0x880c
        .int    0x734a
        .int    0x74d9
        .int    0xa884
        .int    0x881e
        .int    0xca0f
        .int    0xa0e9
        .int    0xbcad
        .int    0x7514
        .int    0xb699
        .int    0x7c60
        .int    0xf3df
        .int    0xf362
        .int    0x9acf
        .int    0xb5cd
        .int    0xa30f
        .int    0x75e8
        .int    0x5544


memcpy:                     # r1 = dst, r2 = src, r3 = n
    mov     r12, 8          # width = 8
1:  ltux    r3, r12         # if n < width:
    b.t     @2f             #   goto 2f
    ldm     r4..r11, r2     # tmp0..7 = src[0..7]
    stm     r4..r11, r1     # dst[0..7] = tmp0..7
    add     r1, r1, r12     # dst += width
    add     r2, r2, r12     # src += width
    sub     r3, r3, r12     # n -= width
    b       @1b             # goto 1b
2:  geu     r3, 4           # p = n >= 4
    cex     5               # if p:
    ldm.t   r4..r7, r2      #   tmp0..3 = src[0..3]
    stm.t   r4..r7, r1      #   dst[0..3] = tmp0..3
    add.t   r1, r1, 4       #   dst += 4
    add.t   r2, r2, 4       #   src += 4
    sub.t   r3, r3, 4       #   n -= 4
    geu     r3, 2           # p = n >= 2
    cex     5               # if p:
    ldm.t   r4..r5, r2      #   tmp0..1 = src[0..1]
    stm.t   r4..r5, r1      #   dst[0..1] = tmp0..1
    add.t   r1, r1, 2       #   dst += 2
    add.t   r2, r2, 2       #   src += 2
    sub.t   r3, r3, 2       #   n -= 2
    ne      r3, zr          # p = n != 0
    cex     2               # if p:
    ld.t    r4, r2, zr      #   tmp = src[0]
    st.t    r4, r1, zr      #   dst[0] = tmp
    ret                     # return


test_main:
    addpc   r1, @dst        # dst = &dst[0]
    addpc   r2, @src        # src = &src[0]
    mov     r3, 61          # n = sizeof src
    mov     r13, lr         # tmp = lr
    bl      @memcpy         # memcpy(dst, src, n)
    mov     r1, zr          # diff = 0
    addpc   r2, @dst        # dst = &dst[0]
    addpc   r3, @dst        # src = &src[0]
    mov     r4, 61          # n = sizeof src
1:  ld+     r5, r2          # x = *dst++
    ld+     r6, r3          # y = *src++
    nex     r5, r6          # if x != y:
    inc.t   r1, r1          #   diff++
    dec     r4, r4          # n--
    nex     r4, zr          # if n:
    b.t     @1b             #   goto 1b
    j       r13             # return diff
