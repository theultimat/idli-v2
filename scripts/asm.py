import argparse
import pathlib

from enum import Enum
from dataclasses import dataclass


# Tokens have a type and value.
class TokenType(Enum):
    LABEL = 0
    COMMA = 1
    NUMBER = 2
    CHAR = 3
    STRING = 4
    PLUS = 5
    MINUS = 6
    COND = 7
    ABS_TARGET = 8
    REL_TARGET = 9
    IDENTIFIER = 10
    DIRECTIVE = 11

@dataclass
class Token:
    dtype: TokenType
    value: str


# Print with specified indentation if verbose enabled.
def log(args, *vals):
    if args.verbose:
        print(' ' * args.indent, end='')
        print(*vals)


# Lex a single line into tokens.
def lex_line(args, line, path_dir, prefix):
    log(args, '- Lexing line:', line)
    args.indent += 1

    tokens = []

    next_token = ''
    next_type = None

    # Add a new token to the list.
    def push(dtype, value):
        log(args, f'* {dtype}: {value}')
        tokens.append(Token(dtype, value))

    # Add a token to the list if it's defined.
    def try_push(dtype, value):
        if dtype != None:
            push(dtype, value)

    for c in line:
        # Continue parsing a string, adding characters and accounting for an
        # escaped quote.
        if next_type == TokenType.STRING:
            if c == '"' and (not next_token or next_token[-1] != '\\'):
                push(next_type, next_token)
                next_type = None
                continue

            next_token += c
            continue

        # Continue parsing character, expecting only a single item accounting
        # for escapes.
        if next_type == TokenType.CHAR:
            if c == '\'' and (not next_token or next_token[-1] != '\\'):
                if not next_token:
                    raise Exception(f'{prefix}: Empty char')

                escaped = next_token[0] == '\\' and len(next_token) == 2
                if not escaped and len(next_token) != 1:
                    raise Exception(f'{prefix}: Char too long: {next_token}')

                push(next_type, next_token)
                next_type = None
                continue

            next_token += c
            continue

        # Continue parsing a condition code for predicated execution.
        if next_type == TokenType.COND:
            if c not in 'tf':
                raise Exception(f'{prefix}: Invalid condition code: {c}')

            push(next_type, c)
            next_type = None
            continue

        # Start of a comment -> no more tokens.
        if c == '#':
            try_push(next_type, next_token)
            next_type = None
            break

        # Start of a reference to a label.
        if c in '$@':
            try_push(next_type, next_token)
            next_type = {
                '$': TokenType.ABS_TARGET,
                '@': TokenType.REL_TARGET,
            }[c]
            next_token = ''
            continue

        # Start of a string.
        if c == '"':
            try_push(next_type, next_token)
            next_type = TokenType.STRING
            next_token = ''
            continue

        # Start of a character.
        if c == '\'':
            try_push(next_type, next_token)
            next_type = TokenType.CHAR
            next_token = ''
            continue

        # Comma, plus, and minus characters.
        if c in ',+-':
            try_push(next_type, next_token)
            next_type = {
                ',': TokenType.COMMA,
                '+': TokenType.PLUS,
                '-': TokenType.MINUS,
            }[c]
            push(next_type, c)
            next_type = None
            continue

        # Colon indicates end of a label name if after a number of identifier.
        if c == ':':
            if next_type not in (TokenType.NUMBER, TokenType.IDENTIFIER):
                raise Exception(f'{prefix}: Label missing name')

            push(TokenType.LABEL, next_token)
            next_type = None
            continue

        # Dot indicates start of directive or a condition depending on whether
        # we're in an identifier or not.
        if c == '.':
            try_push(next_type, next_token)

            if next_type == TokenType.IDENTIFIER:
                next_type = TokenType.COND
                next_token = ''
                continue

            if next_type is not None:
                raise Exception(f'{prefix}: Unexpected dot character')

            next_type = TokenType.DIRECTIVE
            next_token = ''
            continue

        # Skip whitespace.
        if c.isspace():
            try_push(next_type, next_token)
            next_type = None
            continue

        # An alphanumeric value or underscore could be either the start of an
        # identifier/number or part way through something else.
        if c.isalnum() or c == '_':
            if next_type is None:
                if c.isdigit():
                    next_type = TokenType.NUMBER
                else:
                    next_type = TokenType.IDENTIFIER

                next_token = c
                continue

            # Only accept valid hex characters (and for the 0x prefix) if the
            # token is a number.
            if next_type == TokenType.NUMBER:
                if not c.isdigit() and c.lower() not in 'abcdefx':
                    raise Exception(f'{prefix}: Cannot add "{c}" to number')

                next_token += c
                continue

            # If we're not in an appropriate token type then complain, but if
            # we are then just add it to the value.
            if next_type not in (
                TokenType.IDENTIFIER,
                TokenType.DIRECTIVE,
                TokenType.ABS_TARGET,
                TokenType.REL_TARGET,
            ):
                raise Exception(
                    f'{prefix}: Cannot add "{c}" to token of '
                    f'type {next_type}: "{next_token}"'
                )

            next_token += c
            continue

        # Nothing matched so we have an unexpected character.
        raise Exception(f'{prefix}: Unexpected character: "{c}"')

    # If we're mid string or character at the end of the line then we're
    # missing a close quote so complain.
    if next_type in (TokenType.STRING, TokenType.CHAR):
        raise Exception(
            f'{prefix}: Unfinshed token at end of line: '
            f'type={next_type} value="{next_token}"'
        )

    # Close off any unfinished token.
    try_push(next_type, next_token)

    # We should have found at least one token.
    if not tokens:
        raise Exception(f'{prefix}: Failed to find any tokens!')

    # Special check for an include file directive as we'll want to replace the
    # current line's tokens with the contents of the file.
    if tokens[0].dtype == TokenType.DIRECTIVE and tokens[0].value == 'include':
        if tokens[1].dtype != TokenType.STRING:
            raise Exception(f'{prefix}: Missing path for include.')
        if len(tokens) != 2:
            raise Exception(f'{prefix}: Junk at end of include.')

        inc_path = path_dir/tokens[1].value
        log(args, '- Including file:', inc_path)

        tokens = lex(args, inc_path, prefix)
    else:
        tokens = {prefix: tokens}

    args.indent -= 1
    return tokens


# Lex the input file line by line into tokens. Returns tokens per-line.
def lex(args, path, prefix=''):
    log(args, '- Lexing file:', path)
    args.indent += 1

    tokens = {}
    with open(path, 'r') as f:
        for i, line in enumerate(f):
            if not (line := line.strip()):
                continue

            new_tokens = lex_line(
                args,
                line,
                path.parent,
                f'{prefix}{path}:{i + 1}: ',
            )

            assert all(k not in tokens for k in new_tokens), new_tokens
            tokens.update(new_tokens)

    args.indent -= 1

    return tokens


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

    # Stuff the logging indentation into args so we don't have to deal with
    # passing it around everywhere manually.
    args.indent = 0

    return args


if __name__ == '__main__':
    args = parse_args()
    tokens = lex(args, args.input)
