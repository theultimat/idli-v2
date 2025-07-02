import argparse
import pathlib
import sys

from lark import Lark, Token
from lark.exceptions import (
    UnexpectedCharacters,
    UnexpectedInput,
    UnexpectedToken,
)

import isa


# Print with specified indentation if verbose enabled.
def log(args, *vals):
    if args.verbose:
        print(' ' * args.indent, end='')
        print(*vals)


# Print an error and exit.
def abort(prefix, *args):
    print('\033[1;91merror\033[0m: ', end='', file=sys.stderr)
    print(f'{prefix}:', *args, file=sys.stderr)
    sys.exit(1)


# Parse a directive.
def parse_directive(args, tree, dir_path, prefix, labels, items):
    if tree.data == 'directive_include':
        inc_path = dir_path/tree.children[0].children[0]
        return parse(args, inc_path, prefix, labels, items)

    abort(prefix, f'Unsupported directive: {tree.data}')


# Parse a label declaration. If the label is local (i.e. only numeric) then
# we can have multiple definitions, otherwise we must be unique.
def parse_label(args, name, items, labels, prefix):
    # Determine the address.
    addr = 0
    for i in items.values():
        addr += i.size()

    log(args, f'* Adding label "{name}" at address {addr}.')

    # If this is the first time we've seen a label with this name then create
    # it and return.
    if name not in labels:
        labels[name] = [addr]
        return

    # Otherwise we need to check that this is a local label as these can be
    # defined multiple times.
    if not name.isdigit():
        abort(prefix, 'Multiple instances of global label:', name)

    labels[name].append(addr)


# Convert a single character into an integer.
def parse_char(prefix, c):
    # If the first character is a backslash then we have an escape code and
    # otherwise we should take the value literally.
    if c[0] == '\\':
        if c[1] == '0':
            c = '\0'
        elif c[1] == 't':
            c = '\t'
        elif c[1] == 'n':
            c = '\n'
        elif c[1] in '\"\'':
            c = c[1]
        else:
            abort(prefix, f'Invalid escape code for character: {c}')

    return ord(c)


# Parse a single instruction.
def parse_instr(args, tree, prefix, need_conds, items):
    mnem = tree.children[0].value
    op_pattern = tree.data.split('_', 1)[-1]
    ops = {}

    # Parse optional condition suffix.
    tokens = tree.children[1:]
    cond_state = None
    if tokens and isinstance(tokens[0], Token) and tokens[0].type == 'COND':
        if not need_conds:
            abort(prefix, 'Found unexpected condition.')

        cond_state = int(tokens[0].value == '.t')
        tokens = tokens[1:]
    elif need_conds:
        abort(prefix, 'Expected condition suffix but none found.')

    # Parse the operands.
    if op_pattern != 'none':
        for op, token in zip(op_pattern, tokens):
            if op in 'abrs':
                ops[op] = isa.REGS[token.value]
            elif op == 'c':
                # Get the underlying token from the rule(s).
                token = token.children[0]
                if not isinstance(token, Token):
                    token = token.children[0]

                if token.type == 'REGISTER':
                    ops[op] = isa.REGS[token.value]

                    if ops[op] == isa.REGS['sp']:
                        abort(prefix, 'Cannot use SP in C operand.')
                elif token.type == 'LABEL_REF':
                    # Labels will be resolved later after parsing is done.
                    ops[op] = isa.REGS['sp']
                    ops['imm'] = token.value
                elif token.type == 'CHAR_LETTER':
                    ops[op] = isa.REGS['sp']
                    ops['imm'] = parse_char(prefix, token.value)
                else:
                    abort(prefix, f'Unexpected token for C: {token.type}')
            elif op == 'm':
                ops[op] = int(token.value)
                if ops[op] < 1 or ops[op] > 7:
                    abort(prefix, f'Bad value for CEX count: {ops[op]}')
            else:
                abort(prefix, f'Unexpected operand type: {op}')

    # Detect and substitute synonym with the real instruction.
    if mnem in isa.SYNONYMS:
        mnem, extra_ops = isa.SYNONYMS[mnem]
        ops.update(extra_ops)

    instr = isa.Instruction(mnem, ops)
    log(args, f'* Adding instruction: {instr.print(cond_state)}')

    # Check if we need to check for conditionals following this instruction.
    new_conds = instr.num_cond()
    if new_conds:
        log(args, f'* Next {new_conds} instruction(s) should be predicated.')

        # Can't nest conditionals.
        if need_conds:
            abort(prefix, 'Cannot nest conditional state.')

    items[prefix] = instr
    return new_conds


# Parse a single line of an input file.
def parse_line(args, line, dir_path, prefix, need_conds, labels, items):
    log(args, '*', line)
    args.indent += 1

    # Generate syntax tree using parser.
    parse_error = None
    try:
        tree = args.parser.parse(line)
    except UnexpectedInput as e:
        parse_error = str(e)

    if parse_error:
        abort(prefix, parse_error)

    # Remove the start and line rules to get to the actual contents of the line
    # that we're interested in parsing.
    trees = next(tree.find_data('line')).children

    # Iterate through the trees for the line and parse based on the rule.
    for tree in trees:
        if tree.data == 'directive':
            parse_directive(
                args,
                tree.children[0],
                dir_path,
                prefix,
                labels,
                items,
            )
        elif tree.data == 'label':
            # Updates labels inline rather than returning.
            parse_label(args, tree.children[0].value, items, labels, prefix)
        elif tree.data == 'instr':
            new_conds  = parse_instr(
                args,
                tree.children[0],
                prefix,
                need_conds,
                items,
            )

            # Remove conditional or set new one if found.
            if need_conds:
                need_conds -= 1
            if new_conds:
                need_conds = new_conds
        else:
            abort(prefix, f'Unrecognised rule: {tree.data}')

    args.indent -= 1
    return need_conds


# Parse input file.
def parse(args, path, prefix='', labels={}, items={}):
    log(args, '* Parse file:', path)
    args.indent += 1

    if not path.is_file():
        abort(prefix, 'Cannot open file:', path)

    need_conds = 0
    with open(path, 'r') as f:
        for i, line in enumerate(f):
            if not (line := line.strip()):
                continue

            need_conds = parse_line(
                args,
                line,
                path.parent,
                f'{prefix}{path}:{i + 1}',
                need_conds,
                labels,
                items,
            )

    args.indent -= 1
    return items, labels


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

    parser.add_argument(
        '-g',
        '--grammar',
        type=pathlib.Path,
        default='scripts/idli.lark',
        help='Path to grammar file.',
    )

    args = parser.parse_args()

    if not args.input.is_file():
        raise Exception(f'Bad input file: {args.input}')

    if not args.output.parent.is_dir():
        raise Exception(f'Bad output directory: {args.output}')

    if not args.grammar.is_file():
        raise Exception(f'Bad grammar file: {args.grammar}')

    # Load grammar file to create parser.
    with open(args.grammar, 'r') as f:
        args.parser = Lark(f.read())

    # Stuff the logging indentation into args so we don't have to deal with
    # passing it around everywhere manually.
    args.indent = 0

    return args


if __name__ == '__main__':
    args = parse_args()
    parse(args, args.input)
