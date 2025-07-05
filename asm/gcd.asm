    .include "test-wrapper.asm"


gcd:                    # r1 = a, r2 = b
    eqx     r1, r2      # if a == b:
    ret.t               #   return a
    ltu     r1, r2      # p = a < b
    cex     2
    sub.t   r2, r2, r1  # if (p) b -= a
    sub.f   r1, r1, r2  # if (!p) a -= b
    b       @gcd        # goto gcd


test_main:
    urx     r1          # a = uart()
    urx     r2          # b = uart()
    mov     r13, lr     # tmp = lr
    bl      @gcd        # goto gcd
    utx     r1          # uart(a)
    mov     r1, zr      # out = 0
    jl      r13         # return out
