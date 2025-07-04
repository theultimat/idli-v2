import argparse
import pathlib
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

        # If C is SP then the next 16b is an immediate so parse this too.
        if ops.get('c') == isa.REGS['sp']:
            ops['imm'], = struct.unpack('>h', data[:2])
            data = data[2:]

        # If M is an op we need to parse the predicate state.
        if ops.get('m'):
            new_cond_state = _parse_op_m(ops['m'])
            ops['m'] = len(new_cond_state)

        # Determine whether this instruction was conditional and set the flag
        # appropriately based on the current state.
        cond = None
        if cond_state:
            cond = f'.{cond_state[0]}'
            cond_state = cond_state[1:]

        # Add the instruction to the items list.
        items.append(isa.Instruction(mnem, ops, cond))

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


# Return objdump as a list of strings.
def objdump(path):
    with open(path, 'rb') as f:
        data = f.read()

    # Decode the binary into a list of items.
    items = decode(data)

    # Pretty print the binary.
    lines = []
    pc = 0
    for item in items:
        # Prefix with raw data.
        raw = f'{struct.unpack_from(">H", data[pc * 2:])[0]:04x}'
        if item.size() > 1:
            raw += f' {struct.unpack_from(">H", data[pc * 2 + 2:])[0]:04x}'

        lines.append(f'{pc:04x}:  {raw:12}  {item}')
        pc += item.size()

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
    print('\n'.join(objdump(args.input)))
