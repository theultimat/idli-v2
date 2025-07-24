    .include "test-wrapper.asm"


data:   .space  32              # int16_t data[32]


bsearch:                        # r1 = A, r2 = n, r3 = T
    mov     r4, zr              # L = 0
    dec     r2, r2              # R = n - 1
1:  eqx     r2, r4              # if L == R:
    b.t     @2f                 #   goto 2f
    sub     r5, r2, r4          # m = R - L
    anyx    r5, 1               # if m & 1:
    inc.t   r5, r5              #   m += 1
    srl     r5, r5              # m /= 2
    add     r5, r4, r5          # m += L
    ld      r6, r1, r5          # tmp = A[m]
    lt      r3, r6              # p = T < tmp
    cex     2
    dec.t   r2, r5              # if p: R = m - 1
    mov.f   r4, r5              # else: L = m
    b       @1b                 # goto 1b
2:  ld      r5, r1, r2          # tmp = A[L]
    dec     r1, zr              # out = -1
    eqx     r5, r3              # if tmp == T:
    mov.t   r1, r2              #   out = L
    ret                         # return out


test_main:
    push    lr
    addpc   r1, @data           # ptr = &data[0]
    mov     r2, 32              # n = sizeof data
    bl      @test_recv_array    # n = test_recv_array(ptr, n)
    lt      r1, zr              # p = n < 0
    cex     2                   # if p:
    pop.t   lr                  #   lr = pop()
    ret.t                       #   return n
    mov     r2, r1              # n = n
    addpc   r1, @data           # A = &data[0]
    urx     r3                  # T = uart()
    bl      @bsearch            # m = bsearch(A, n, T)
    utx     r1                  # uart(m)
    mov     r1, zr              # out = 0
    pop     lr                  # lr = pop()
    ret                         # return out
