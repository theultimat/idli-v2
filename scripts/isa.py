# 16x16b general purpose registers, some with special meanings:
#   - r0 is also known as zr, the zero regiters. Writes are ignored and reads
#     always return zero.
#   - r14 is the link register, lr.
#   - r15 is the stack pointer, sp.
REGS = {
    'r0': 0,
    'r1': 1,
    'r2': 2,
    'r3': 3,
    'r4': 4,
    'r5': 5,
    'r6': 6,
    'r7': 7,
    'r8': 8,
    'r9': 9,
    'r10': 10,
    'r11': 11,
    'r12': 12,
    'r13': 13,
    'r14': 14,
    'r15': 15,

    'zr': 0,
    'lr': 14,
    'sp': 15,
}

REGS_INV = {v: k for k, v in REGS.items()}


# Encodings for the instructions. Zero and one bits indicate the opcode,
# question marks indicate don't cares, and letters indicate bits used for
# storing operands. There are a few types of operand supported:
#   - a, b  Standard register operand.
#   - c     Register excluding r15, which indicates the following 16b contains
#           immediate data.
#   - n     Unsigned integer representing an input or output pin.
#   - m     Conditional execution mask, where all but one bit indicate whether
#           one of the following instructions should execute if the current
#           predicate state is true or false.
#   - r, s  Register range from r to s inclusive.
ENCODINGS = {
    # Add/subtract.
    'add':      '0000aaaabbbbcccc',     # a = b + c
    'sub':      '0001aaaabbbbcccc',     # a = b - c

    # Logical.
    'and':      '0010aaaabbbbcccc',     # a = b & c
    'andn':     '0011aaaabbbbcccc',     # a = b & ~c
    'or':       '0100aaaabbbbcccc',     # a = b | c
    'xor':      '0101aaaabbbbcccc',     # a = b ^ c

    # Indexed load/store register.
    'ld':       '0110aaaabbbbcccc',     # a = [b + c]
    'st':       '0111aaaabbbbcccc',     # [b + c] = a

    # Load/store register range.
    'ldm':      '1000rrrrbbbbssss',     # r..s = [b, b + 1, ...]
    'stm':      '1001rrrrbbbbssss',     # [b, b + 1, ...] = r..s

    # Load/store with post/pre-increment writeback.
    'ld+':      '1010aaaabbbb0000',     # a = [b++]
    'st+':      '1010aaaabbbb0001',     # [b++] = a
    '+ld':      '1010aaaabbbb0010',     # a = [++b]
    '+st':      '1010aaaabbbb0011',     # [++b] = a

    # Load/store with post/pre-decrement writeback.
    'ld-':      '1010aaaabbbb0100',     # a = [b--]
    'st-':      '1010aaaabbbb0101',     # [b--] = a
    '-ld':      '1010aaaabbbb0110',     # a = [--b]
    '-st':      '1010aaaabbbb0111',     # [--b] = a

    # Increment/decrement register.
    'inc':      '1010aaaabbbb1000',     # a = b + 1
    'dec':      '1010aaaabbbb1001',     # a = b - 1

    # Shift/rotate.
    'srl':      '1010aaaabbbb1010',     # a = {1'b0, b[15:1]}
    'sra':      '1010aaaabbbb1011',     # a = {b[15], b[15:1]}
    'ror':      '1010aaaabbbb1100',     # a = {b[0], b[15:1]}
    'rol':      '1010aaaabbbb1101',     # a = {b[14:0], b[15]}

    # Bitwise invert.
    'not':      '1010aaaabbbb1110',     # a = ~b

    # Receive from UART.
    'urx':      '1010aaaa00001110',     # a = uart()

    # Get predicate register.
    'getp':     '1010aaaa00011110',     # a = p

    # Compare or read pin into predicate.
    'eq':       '10110000bbbbcccc',     # p = b == c
    'ne':       '10110001bbbbcccc',     # p = b != c
    'lt':       '10100010bbbbcccc',     # p = b < c
    'ltu':      '10100011bbbbcccc',     # p = b < c
    'ge':       '10100100bbbbcccc',     # p = b >= c
    'geu':      '10100101bbbbcccc',     # p = b >= c
    'bit':      '10100110bbbbcccc',     # p = (b >> c) & 1
    'inp':      '10100111??nn????',     # p = pin(n)

    # Comparison as above, but only run the following instruction if the value
    # written to p is true.
    'eqx':      '10111000bbbbcccc',     # p = eq(b, c); cond(t)
    'nex':      '10111001bbbbcccc',     # p = ne(b, c); cond(t)
    'ltx':      '10101010bbbbcccc',     # p = lt(b, c); cond(t)
    'ltux':     '10101011bbbbcccc',     # p = ltu(b, c); cond(t)
    'gex':      '10101100bbbbcccc',     # p = ge(b, c); cond(t)
    'geux':     '10101101bbbbcccc',     # p = geu(b, c); cond(t)
    'bitx':     '10101110bbbbcccc',     # p = bit(b, c); cond(t)
    'inpx':     '10101111??nn????',     # p = inp(n); cond(t)

    # Add value to program counter.
    'addpc':    '1100aaaa0000cccc',     # a = pc + c

    # Branch and jump, optionally with link.
    'b':        '110000001111cccc',     # pc += c
    'j':        '110000011111cccc',     # pc = c
    'bl':       '110000101111cccc',     # lr = pc + 1; b(c)
    'jl':       '110000111111cccc',     # lr = pc + 1; j(c)

    # Read/write input and output pins.
    'in':       '1101aaaa00nn????',     # a = pin(n)
    'out':      '1101000001nncccc',     # pin(n, c)
    'out1':     '1101000101nn???1',     # pin(n, 1)
    'outp':     '1101001010nn????',     # pin(n, p)

    # Send over UART.
    'utx':      '1101000011??cccc',     # uart(c)

    # Set sticky carry flag.
    'carry':    '1101000111??cccc',     # C_in = C_out for C instructions

    # Put value into predicate register.
    'putp':     '1101001011??cccc',     # p = c & 1

    # Set conditional execution state for the following instructions.
    'cex':      '11100000mmmmmmmm',     # cond(*m)
}
