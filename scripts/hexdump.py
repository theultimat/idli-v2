import argparse
import pathlib
import struct


# Split the input into the two low and high memories in hex format.
def split(path):
    lo = []
    hi = []

    with open(path, 'rb') as f:
        while data := f.read(2):
            data, = struct.unpack('>H', data)

            lo.append(((data & 0x0f) >> 0) | ((data & 0x0f00) >> 4))
            hi.append(((data & 0xf0) >> 4) | ((data & 0xf000) >> 8))

    return lo, hi


# Dump to file in hex format for loading in verilog.
def dump(path, items):
    items = '\n'.join(f'{x:02x}' for x in items)
    with open(path, 'w') as f:
        f.write(items)


# Parse input arguments.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'input',
        metavar='INPUT',
        type=pathlib.Path,
        help='Path to input binary.',
    )

    parser.add_argument(
        '-l',
        '--lo',
        type=pathlib.Path,
        required=True,
        help='Path to low memory output file.',
    )

    parser.add_argument(
        '-H',
        '--hi',
        type=pathlib.Path,
        required=True,
        help='Path to high memory output file.',
    )

    args = parser.parse_args()

    if not args.input.is_file():
        raise Exception(f'Bad input file: {args.input}')

    return args


if __name__ == '__main__':
    args = parse_args()
    lo, hi = split(args.input)
    dump(args.lo, lo)
    dump(args.hi, hi)
