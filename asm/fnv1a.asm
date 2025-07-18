    .include "test-wrapper.asm"


data:   .space  128             # uint16_t data[128]


fnv1a:                          # data = r1, n = r2
    mov     r3, r1              # data = data
    add     r4, r1, r2          # end = data + n
    mov     r1, 0x9dc5          # hash0 = FNV_offset_basis[0]
    mov     r2, 0x811c          # hash1 = FNV_offset_basis[1]
1:  geux    r3, r4              # if data >= end:
    ret.t                       #   return (hash0, hash1)
    ld+     r5, r3              # tmp = *data++
    xor     r1, r1, r5          # hash0 ^= tmp
    mov     r5, 0x0193          # prime0 = FNV_prime[0]
    mov     r6, 0x0100          # prime1 = FNV_prime[1]
    mov     r8, zr              # mul0 = 0
    mov     r9, zr              # mul1 = 0
2:  eq      r5, zr              # done = prime0 == 0
    andp    1                   # (and next compare)
    eq      r6, zr              # done &= prime1 == 0
    cex     3                   # if p:
    mov.t   r1, r8              #   hash0 = mul0
    mov.t   r2, r9              #   hash1 = mul1
    b.t     @1b                 #   goto 1b
    any     r5, 0x1             # p = (prime0 & 1) != 0
    cex     3                   # if p:
    carry.t 2                   #   (sticky carry)
    add.t   r8, r8, r1          #   c, mul0 = mul0 + hash0
    add.t   r9, r9, r2          #   mul1 = mul1 + hash1 + c
    carry   2                   # (shift through carry)
    srl     r6, r6              # c, prime1 >>= 1
    srl     r5, r5              # prime0 = (c << 15) | (prime0 >> 1)
    carry   2                   # (shift through carry)
    sll     r1, r1              # c, hash0 <<= 1
    sll     r2, r2              # hash1 = (hash1 << 1) | c
    b       @2b                 # goto 2b


test_main:
    push    lr                  # push(lr)
    addpc   r1, @data           # ptr = &data[0]
    mov     r2, 128             # n = sizeof data
    bl      @test_recv_array    # n = test_recv_array(ptr, n)
    lt      r1, zr              # p = n < 0
    cex     2                   # if p:
    pop.t   lr                  #   lr = pop()
    ret.t                       #   return n
    mov     r2, r1              # n = n
    addpc   r1, @data           # ptr = &data[0]
    bl      @fnv1a              # fnv1a(ptr, n)
    utx     r1                  # uart(hash0)
    utx     r2                  # uart(hash1)
    pop     lr                  # lr = pop()
    mov     r1, zr              # out = 0
    ret                         # return out
