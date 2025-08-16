import argparse
import pathlib
import re
import struct

import isa


# Decode predicate mask into a string of T/F.
def _parse_op_m(enc):
    if not enc:
        raise Exception(f'No one bit in M: {bin(enc)}')

    out = ''

    while enc != 1:
        out += 't' if enc & 1 else 'f'
        enc >>= 1

    return out


# Parse binary into instruction stream, optionally stopping after the specified
# number of instructions have been parsed.
def decode(data, max_items=None):
    items = []

    if len(data) % 2:
        raise Exception(f'Cannot disassemble non multiple of 16b: {len(data)}')

    # Condition state for adding T/F flags.
    cond_state = ''

    # Process bytes while there's more to handle.
    while data:
        # Search through all the instructions to find a matching opcode.
        enc, = struct.unpack('>H', data[:2])
        data = data[2:]

        matches = []
        for mnem, opcode in isa.OPCODES.items():
            if (enc & isa.OPCODE_MASKS[mnem]) == opcode:
                matches.append(mnem)

        if not matches:
            # TODO Could be some int data but just explode for now.
            raise Exception(f'No matches for encoding: 0x{enc:04x}')
        if len(matches) > 1:
            raise Exception(
                f'Multiple candidates for encoding 0x{enc:04x}: '
                f'{", ".join(matches)}'
            )

        mnem = matches[0]

        # Extract operand values from the encoding string.
        enc_str = isa.ENCODINGS[mnem]
        ops = {k: None for k in enc_str if k not in '01?'}

        for k in ops:
            mask = int(''.join('1' if x == k else '0' for x in enc_str), 2)
            value = (enc & mask) >> ((mask & -mask).bit_length() - 1)
            ops[k] = value

        # Sort operands into order based on the expected precedence in the
        # syntax string.
        ops = {
            k: ops[k]
            for k in sorted(ops, key=lambda x: isa.OPERAND_ORDER.index(x))
        }

        # If C is SP then the next 16b is an immediate so parse this too.
        if ops.get('c') == isa.REGS['sp']:
            ops['imm'], = struct.unpack('>h', data[:2])
            data = data[2:]

        # If M is an op we need to parse the predicate state.
        cex_mask = None
        if ops.get('m'):
            cex_mask = ops['m']
            new_cond_state = _parse_op_m(ops['m'])
            ops['m'] = len(new_cond_state)

        # Determine whether this instruction was conditional and set the flag
        # appropriately based on the current state.
        cond = None
        if cond_state:
            cond = f'.{cond_state[0]}'
            cond_state = cond_state[1:]

        # Add the instruction to the items list.
        items.append(isa.Instruction(mnem, ops, cond, cex_mask))

        # If the instruction sets conditional state save it.
        if items[-1].num_cond():
            # CEX takes the value from the encoding, while CMPX instructions
            # always set it to a single true instruction.
            if mnem == 'cex':
                cond_state = new_cond_state
            else:
                cond_state = 't'

        # If we've parsed the maximum number of instructions then stop.
        if max_items is not None and len(items) >= max_items:
            break

    return items


# Return objdump as a list of strings and sizes of each entry.
def objdump(path):
    with open(path, 'rb') as f:
        data = f.read()

    # Decode the binary into a list of items.
    items = decode(data)

    # Pretty print the binary.
    lines = []
    sizes = []
    pc = 0
    for item in items:
        # Prefix with raw data.
        raw = f'{struct.unpack_from(">H", data[pc * 2:])[0]:04x}'
        if item.size() > 1:
            raw += f' {struct.unpack_from(">H", data[pc * 2 + 2:])[0]:04x}'

        lines.append(f'{pc:04x}:  {raw:12}  {item}')
        sizes.append(item.size())
        pc += item.size()

    return lines, sizes


# Merge lines that have the same data except for the address to avoid excessive
# output.
def merge_same(lines, sizes):
    pattern = re.compile(r'^(?P<addr>[0-9a-f]+):(?P<value>.*)$')

    addr = None
    value = None

    # Count occurrences of values in order.
    counts = []
    count = 1
    for line, size in zip(lines, sizes):
        m = pattern.match(line)
        assert m, line

        # If value is the same just bump the counter and keep going.
        if m.group('value') == value:
            count += 1
            continue

        # New value so push existing value/count and update search.
        if addr is not None:
            counts.append((addr, value, size, count))

        addr = int(m.group('addr'), 16)
        value = m.group('value')
        count = 1

    # Close off open group.
    if count:
        counts.append((addr, value, size, count))

    # Regenerate lines, merging sequential entries that have more than
    lines = []
    for addr, value, size, count in counts:
        if count < 3:
            for _ in range(count):
                lines.append(f'{addr:04x}:{value}')
                addr += size
            continue

        lines.append(f'{addr:04x}:{value}')
        addr += size

        lines.append(' *')
        addr += size * (count - 2)

        lines.append(f'{addr:04x}:{value}')

    return lines


# Parse command line arguments.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'input',
        metavar='INPUT',
        type=pathlib.Path,
        help='Path to binary to disassemble.',
    )

    args = parser.parse_args()

    if not args.input.is_file():
        raise Exception(f'Bad input file: {args.input}')

    return args


if __name__ == '__main__':
    args = parse_args()
    lines, sizes = objdump(args.input)
    lines = merge_same(lines, sizes)
    print('\n'.join(lines))
