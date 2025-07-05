import struct


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
    'urx':      '1010aaaa00001111',     # a = uart()

    # Get predicate register.
    'getp':     '1010aaaa00011111',     # a = p

    # Compare or read pin into predicate.
    'eq':       '10110000bbbbcccc',     # p = b == c
    'ne':       '10110001bbbbcccc',     # p = b != c
    'lt':       '10110010bbbbcccc',     # p = b < c
    'ltu':      '10110011bbbbcccc',     # p = b < c
    'ge':       '10110100bbbbcccc',     # p = b >= c
    'geu':      '10110101bbbbcccc',     # p = b >= c
    'bit':      '10110110bbbbcccc',     # p = (b >> c) & 1
    'inp':      '10110111??nn????',     # p = pin(n)

    # Comparison as above, but only run the following instruction if the value
    # written to p is true.
    'eqx':      '10111000bbbbcccc',     # p = eq(b, c); cond(t)
    'nex':      '10111001bbbbcccc',     # p = ne(b, c); cond(t)
    'ltx':      '10111010bbbbcccc',     # p = lt(b, c); cond(t)
    'ltux':     '10111011bbbbcccc',     # p = ltu(b, c); cond(t)
    'gex':      '10111100bbbbcccc',     # p = ge(b, c); cond(t)
    'geux':     '10111101bbbbcccc',     # p = geu(b, c); cond(t)
    'bitx':     '10111110bbbbcccc',     # p = bit(b, c); cond(t)
    'inpx':     '10111111??nn????',     # p = inp(n); cond(t)

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

OPCODES = {
    k: int(''.join(x if x in '01' else '0' for x in v), 2)
    for k, v in ENCODINGS.items()
}

OPCODE_MASKS = {
    k: int(''.join('1' if x in '01' else '0' for x in v), 2)
    for k, v in ENCODINGS.items()
}


# Mapping from synonym mnemonic to real instruction and operand substitutions.
# Operands that aren't listed are assumed to be copied over directly.
SYNONYMS = {
    'mov':  ('add', {'b': REGS['zr']}),
    'ret':  ('j', {'c': REGS['lr']}),
    'nop':  ('add', {'a': REGS['zr'], 'b': REGS['zr'], 'c': REGS['zr']}),
}


# Represents a single instruction.
class Instruction:
    def __init__(self, mnem, ops, cond=None, cex_mask=None):
        self.mnem = mnem
        self.ops = ops
        self.cond = cond

        # Stored only for running on the simulator so we don't need to
        # recalculate when decoding via objdump.
        self.cex_mask = cex_mask

    def __str__(self):
        name = self.mnem

        if self.cond is not None:
            name += self.cond

        # Operands will have been added to the dict in order so we can just
        # iterate through them for printing.
        ops = []
        for k, v in self.ops.items():
            if k in 'abrs':
                ops.append(REGS_INV[v])
            elif k in 'nm':
                ops.append(str(v))
            elif k == 'imm':
                ops.append(hex(v) if isinstance(v, int) else v)
            elif k == 'c':
                if v != REGS['sp']:
                    ops.append(REGS_INV[v])
            else:
                raise Exception(f'Invalid operand: {k}={v}')

        # Operands are typically separated by commas except for the register
        # ranges, so handle this case before the join.
        if 'r' in self.ops:
            ops = [f'{ops[0]}..{ops[1]}'] + ops[2:]

        return f'{name} {", ".join(ops)}'

    # How many instructions following this one that will be predicated after
    # running this instruction. The only instructions that set this are cmpx
    # and cex, with the former always being 1 and the latter being the value of
    # the m operand.
    def num_cond(self):
        CMPX = set(['eqx', 'nex', 'ltx', 'ltux', 'gex', 'geux', 'bitx', 'inpx'])

        if self.mnem in CMPX:
            return 1
        return self.ops.get('m', 0)

    # Number of 16b chunks the instruction takes up. This will be 1 in all cases
    # except when an immediate is present.
    def size(self):
        return 1 + int('imm' in self.ops)

    # Encode the instruction into raw bytes. Followers is a list of instructions
    # following this one that is used to calculate the mask to encode for M.
    def encode(self, followers=[]):
        bits = ENCODINGS[self.mnem].replace('?', '0')

        # Replace bits of the encoding with the operand values.
        for k, v in self.ops.items():
            # Immediates are encoded as the 16b following the instruction so
            # there's nothing to encode at this stage.
            if k == 'imm':
                continue

            # M must be calculated using the followers by checking their conds.
            # It is encoded as a sequence of 1 and 0 indicating T and F followed
            # by a final 1 value indicating the end of the mask.
            if k == 'm':
                if len(followers) < v:
                    raise Exception(f'Not enough followers to calculate M')

                mask = 1 << v
                for i in range(v):
                    if followers[i].cond is None:
                        raise Exception(f'Missing cond: {followers[i]}')
                    bit = int(followers[i].cond == '.t')
                    mask |= bit << i

                v = mask

            # Convert the value into a bit string and insert it.
            space = bits.count(k)
            v_enc = f'{v:0{space}b}'

            if len(v_enc) != space:
                raise Exception(f'Encoding operand {k} failed: {v}')

            v_enc = iter(v_enc)
            bits = ''.join(next(v_enc) if x == k else x for x in bits)

        # Generate the raw bytes, appending immediate if required.
        out = struct.pack('>H', int(bits, 2))
        if 'imm' in self.ops:
            out += struct.pack('>h', self.ops['imm'])

        return out
