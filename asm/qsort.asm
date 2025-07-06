    .include "test-wrapper.asm"


data:   .space 16               # int16_t data[16]


qsort:                          # r1 = A, r2 = lo, r3 = hi
    geux    r2, r3              # if lo >= hi:
    ret.t                       #   return
    ltux    r2, r1              # if lo < A:
    ret.t                       #   return
    push    lr                  # push(lr)
    ld      r6, r2, zr          # pivot = *lo
    dec     r5, r2              # i = lo - 1
    inc     r4, r3              # j = hi + 1
1:  +ld     r7, r5              # x = *++i
    ltx     r7, r6              # if x < pivot:
    b.t     @1b                 #   goto 1b
2:  -ld     r8, r4              # y = *--j
    ltx     r6, r8              # if pivot < y:
    b.t     @2b                 #   goto 2b
    geux    r5, r4              # if i >= j:
    b.t     @3f                 #   goto 3f
    st      r7, r4, zr          # *j = x
    st      r8, r5, zr          # *i = y
    b       @1b                 # goto 1b
3:  sub     sp, sp, 2           # sp -= 2
    stm     r3..r4, sp          # sp[0] = hi, sp[1] = j
    mov     r3, r4              # p = j
    bl      @qsort              # qsort(A, lo, p)
    ldm     r3..r4, sp          # hi = sp[0], j = sp[1]
    add     sp, sp, 2           # sp += 2
    inc     r2, r4              # p = j + 1
    bl      @qsort              # qsort(A, p, hi)
    pop     lr                  # lr = pop()
    ret                         # return


test_main:
    push    lr                  # push(lr)
    addpc   r1, @data           # ptr = &data[0]
    mov     r2, 16              # n = sizeof data
    bl      @test_recv_array    # n = test_recv_array(ptr, n)
    lt      r1, zr              # p = n < 0
    cex     2                   # if p:
    pop.t   lr                  #   lr = pop()
    ret.t                       #   return n
    push    r1                  # push(n)
    dec     r3, r1              # hi = n - 1
    addpc   r1, @data           # A = &data[0]
    mov     r2, r1              # lo = A
    add     r3, r1, r3          # hi += A
    bl      @qsort              # qsort(A, lo, hi)
    addpc   r1, @data           # ptr = &data[0]
    pop     r2                  # n = pop()
    bl      @test_send_array    # test_send_array(ptr, n)
    pop     lr                  # lr = pop()
    mov     r1, zr              # out = 0
    ret                         # return out
