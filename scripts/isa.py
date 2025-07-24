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
#   - j     4b unsigned immediate.
# Underscores are only used to make the encoding strings more readable.
ENCODINGS = {
    # Add/subtract.
    'add':      '0000_aaaa_bbbb_cccc',      # a = b + c
    'sub':      '0001_aaaa_bbbb_cccc',      # a = b - c

    # Logical.
    'and':      '0010_aaaa_bbbb_cccc',      # a = b & c
    'andn':     '0011_aaaa_bbbb_cccc',      # a = b & ~c
    'or':       '0100_aaaa_bbbb_cccc',      # a = b | c
    'xor':      '0101_aaaa_bbbb_cccc',      # a = b ^ c

    # Indexed load/store register.
    'ld':       '0110_aaaa_bbbb_cccc',      # a = [b + c]
    'st':       '0111_aaaa_bbbb_cccc',      # [b + c] = a

    # Load/store register range.
    'ldm':      '1000_rrrr_ssss_bbbb',      # r..s = [b, b + 1, ...]
    'stm':      '1001_rrrr_ssss_bbbb',      # [b, b + 1, ...] = r..s

    # Load/store with post/pre-increment writeback.
    'ld+':      '1010_aaaa_bbbb_0000',      # a = [b++]
    'st+':      '1010_aaaa_bbbb_0001',      # [b++] = a
    '+ld':      '1010_aaaa_bbbb_0010',      # a = [++b]
    '+st':      '1010_aaaa_bbbb_0011',      # [++b] = a

    # Load/store with post/pre-decrement writeback.
    'ld-':      '1010_aaaa_bbbb_0100',      # a = [b--]
    'st-':      '1010_aaaa_bbbb_0101',      # [b--] = a
    '-ld':      '1010_aaaa_bbbb_0110',      # a = [--b]
    '-st':      '1010_aaaa_bbbb_0111',      # [--b] = a

    # Increment/decrement register.
    'inc':      '1010_aaaa_bbbb_1000',      # a = b + 1
    'dec':      '1010_aaaa_bbbb_1001',      # a = b - 1

    # Shift/rotate.
    'srl':      '1010_aaaa_bbbb_1010',      # a = {1'b0, b[15:1]}
    'sra':      '1010_aaaa_bbbb_1011',      # a = {b[15], b[15:1]}
    'ror':      '1010_aaaa_bbbb_1100',      # a = {b[0], b[15:1]}
    'rol':      '1010_aaaa_bbbb_1101',      # a = {b[14:0], b[15]}

    # Bitwise invert.
    'not':      '1010_aaaa_bbbb_1110',      # a = ~b

    # Compare or read pin into predicate.
    'eq':       '1011_0000_bbbb_cccc',      # p = b == c
    'ne':       '1011_0001_bbbb_cccc',      # p = b != c
    'lt':       '1011_0010_bbbb_cccc',      # p = b < c
    'ltu':      '1011_0011_bbbb_cccc',      # p = b < c
    'ge':       '1011_0100_bbbb_cccc',      # p = b >= c
    'geu':      '1011_0101_bbbb_cccc',      # p = b >= c
    'any':      '1011_0110_bbbb_cccc',      # p = |(b & c)
    'inp':      '1011_0111_??nn_0000',      # p = pin(n)

    # Comparison as above, but only run the following instruction if the value
    # written to p is true.
    'eqx':      '1011_1000_bbbb_cccc',      # p = eq(b, c); cond(t)
    'nex':      '1011_1001_bbbb_cccc',      # p = ne(b, c); cond(t)
    'ltx':      '1011_1010_bbbb_cccc',      # p = lt(b, c); cond(t)
    'ltux':     '1011_1011_bbbb_cccc',      # p = ltu(b, c); cond(t)
    'gex':      '1011_1100_bbbb_cccc',      # p = ge(b, c); cond(t)
    'geux':     '1011_1101_bbbb_cccc',      # p = geu(b, c); cond(t)
    'anyx':     '1011_1110_bbbb_cccc',      # p = any(b, c); cond(t)
    'inpx':     '1011_1111_??nn_0000',      # p = inp(n); cond(t)

    # Add value to program counter.
    'addpc':    '1100_aaaa_???0_cccc',      # a = pc + c

    # Branch and jump, optionally with link.
    'b':        '1100_??00_???1_cccc',      # pc += c
    'j':        '1100_??01_???1_cccc',      # pc = c
    'bl':       '1100_??10_???1_cccc',      # lr = pc + 1; b(c)
    'jl':       '1100_??11_???1_cccc',      # lr = pc + 1; j(c)

    # Read/write input and output pins.
    'in':       '1101_???0_00nn_aaaa',      # a = pin(n)
    'out':      '1101_???0_01nn_cccc',      # pin(n, c)
    'outn':     '1101_???0_10nn_cccc',      # pin(n, ~c)
    'outp':     '1101_???0_11nn_0000',      # pin(n, p)

    # Send/receive over UART.
    'urx':      '1101_???1_??00_aaaa',      # a = uart()
    'utx':      '1101_???1_??01_cccc',      # uart(c)

    # Get/put predicate register.
    'getp':     '1101_???1_??10_aaaa',      # a = p
    'putp':     '1101_???1_??11_cccc',      # p = c & 1

    # Set conditional execution state for the following instructions.
    'cex':      '1110_???0_mmmm_mmmm',      # cond(*m)

    # Set sticky carry flag.
    'carry':    '1110_???1_??00_jjjj',      # C_in = C_out for C instructions

    # Set compare instructions to AND/OR into P rather than replacing.
    'andp':     '1110_???1_??01_jjjj',      # p &= q for c instructions
    'orp':      '1110_???1_??10_jjjj',      # p |= q for c instructions
}

ENCODINGS = {k: v.replace('_', '') for k, v in ENCODINGS.items()}

OPCODES = {
    k: int(''.join(x if x in '01' else '0' for x in v), 2)
    for k, v in ENCODINGS.items()
}

OPCODE_MASKS = {
    k: int(''.join('1' if x in '01' else '0' for x in v), 2)
    for k, v in ENCODINGS.items()
}


# Sanity check that we have no encoding collisions.
def _check_encodings():
    for mnem, opcode in OPCODES.items():
        mask = OPCODE_MASKS[mnem]

        for other_mnem, other_opcode in OPCODES.items():
            if mnem == other_mnem:
                continue

            assert opcode & mask != other_opcode & mask, f'{mnem} {other_mnem}'

_check_encodings()


# Mapping from synonym mnemonic to real instruction and operand substitutions.
# Operands that aren't listed are assumed to be copied over directly.
SYNONYMS = {
    'mov':  ('add', {'b': REGS['zr']}),
    'ret':  ('j', {'c': REGS['lr']}),
    'nop':  ('add', {'a': REGS['zr'], 'b': REGS['zr'], 'c': REGS['zr']}),
    'push': ('-st', {'b': REGS['sp']}),
    'pop':  ('ld+', {'b': REGS['sp']}),
    'sll':  ('add', {'c': 'b'}),
}


# Order of operands in syntax strings. Used by disassembler for displaying in
# the correct order.
OPERAND_ORDER = 'rsabncmj'


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
            elif k in 'nmj':
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
        CMPX = set(['eqx', 'nex', 'ltx', 'ltux', 'gex', 'geux', 'anyx', 'inpx'])

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


# Represents raw data in the instruction stream i.e. any encoding that doesn't
# decode to a valid instruction.
class RawData:
    def __init__(self, data):
        self.data = data

        self.mnem = None
        self.ops = {}
        self.cond = None
        self.cex_mask = None

    def __str__(self):
        return f'.int 0x{self.data:04X}'

    def num_cond(self):
        return 0

    def size(self):
        return 1

    def encode(self, followers=[]):
        return struct.pack('>h', self.data)
