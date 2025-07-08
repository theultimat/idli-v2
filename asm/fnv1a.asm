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
    mov     r5, 0x0193          # prime0 = 0x0193
    mov     r6, 0x0100          # prime1 = 0x0100
    mov     r8, zr              # mul0 = 0
    mov     r9, zr              # mul1 = 0
2:  mov     r7, zr              # more = 0
    nex     r5, zr              # if prime0 == 0:
    inc.t   r7, r7              #   more += 1
    nex     r6, zr              # if prime1 == 0:
    inc.t   r7, r7              #   more += 1
    eq      r7, zr              # p = not more
    cex     3                   # if p:
    mov.t   r1, r8              #   hash0 = mul0
    mov.t   r2, r9              #   hash1 = mul1
    b.t     @1b                 #   goto 1b
    bit     r5, 0x1             # p = (prime0 & 1) != 0
    cex     3                   # if p:
    carry.t 2                   #   (sticky carry)
    add.t   r8, r8, r1          #   c, mul0 = mul0 + hash0
    add.t   r9, r9, r2          #   mul1 = mul1 + hash1 + c
    srl     r5, r5              # prime0 >>= 1
    bitx    r6, 0x1             # if prime1 & 1:
    or.t    r5, r5, 0x8000      #   prime0 |= 0x8000
    srl     r6, r6              # prime1 >>= 1
    sll     r2, r2              # hash1 <<= 1
    bitx    r1, 0x8000          # if hash0 & 0x8000:
    inc.t   r2, r2              #   hash1 += 1
    sll     r1, r1              # hash0 <<= 1
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
