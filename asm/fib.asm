    .include "test-wrapper.asm"


fib:                    # r1 = n
    ltux    r1, 2       # if n < 2:
    ret.t               #   return n
    mov     r3, r1      # n = n
    inc     r1, zr      # cur = 1
    inc     r2, zr      # prev = 1
1:  ltux    r3, 3       # if n < 3:
    ret.t               #   return cur
    mov     r4, r1      # tmp = cur
    add     r1, r1, r2  # cur += prev
    mov     r2, r4      # prev = tmp
    dec     r3, r3      # n--
    b       @1b         # goto 1b


test_main:
    urx     r1          # n = uart()
    mov     r13, lr     # tmp = lr
    bl      @fib        # i = fib()
    utx     r1          # uart(i)
    mov     r1, zr      # out = 0
    jl      r13         # return out
