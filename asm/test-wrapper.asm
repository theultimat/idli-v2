test_init:
    mov     r1, zr          # zero initialise registers
    mov     r2, zr
    mov     r3, zr
    mov     r4, zr
    mov     r5, zr
    mov     r6, zr
    mov     r7, zr
    mov     r8, zr
    mov     r9, zr
    mov     r10, zr
    mov     r11, zr
    mov     r12, zr
    mov     r13, zr
    mov     lr, zr
    mov     sp, zr
    ne      zr, zr          # clear predicate
    out     0, zr           # clear output pins
    out     1, zr
    out     2, zr
    out     3, zr
    jl      $test_main      # jump to main test program
    utx     '@'             # send end of test message
    utx     '@'
    utx     'E'
    utx     'N'
    utx     'D'
    utx     '@'
    utx     '@'
    utx     r1              # send test exit code
1:  b       @1b             # wait for test to exit


test_recv_array:            # r1 = data, r2 = max_n
    urx     r3              # n = uart()
    ltu     r2, r3          # p = max_n < n
    cex     2               # if p:
    not.t   r1, zr          #   out = -1
    j.t     lr              #   return out
    add     r2, r1, r3      # end = data + n
    mov     r1, r3          # out = n
    sub     r3, r2, r1      # data = end - n
1:  geux    r3, r2          # if data >= end:
    j.t     lr              #   return out
    urx     r4              # tmp = uart()
    st+     r4, r3          # *data++ = tmp
    b       @1b             # goto 1b


test_send_array:            # r1 = data, r2 = n
    utx     r2              # uart(n)
    add     r2, r1, r2      # end = data + n
1:  geux    r1, r2          # if data >= end:
    j.t     lr              #   return
    ld+     r3, r1          # tmp = *data++
    utx     r3              # uart(tmp)
    b       @1b             # goto 1b
