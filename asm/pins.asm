    .include "test-wrapper.asm"


test_main:
    out     0, zr       # pin0 = 0
    outn    0, zr       # pin0 = 1
    outp    1           # pin1 = 0
    eq      zr, zr      # p = 1
    outp    1           # pin1 = 1
1:  inp     3           # p = pin3
    andp    2           # (and next 2 instrs)
    inp     2           # p &= pin2
    inpx    0           # p &= pin0
    b.t     @1b         # if p: goto 1b
    ret                 # return
