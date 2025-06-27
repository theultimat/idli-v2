import argparse
import pathlib


# Parse command line arguments.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-v',
        '--verbose',
        action='store_true',
        help='Enable verbose output.',
    )

    parser.add_argument(
        'input',
        metavar='INPUT',
        type=pathlib.Path,
        help='Path to input file to assemble.',
    )

    parser.add_argument(
        '-o',
        '--output',
        type=pathlib.Path,
        required=True,
        help='Path to output file.',
    )

    args = parser.parse_args()

    if not args.input.is_file():
        raise Exception(f'Bad input file: {args.input}')

    if not args.output.parent.is_dir():
        raise Exception(f'Bad output directory: {args.output}')

    return args


if __name__ == '__main__':
    args = parse_args()
    print(args)
