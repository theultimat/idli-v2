import argparse
import pathlib
import random
import yaml

from dataclasses import dataclass

import isa


# Instructions that set conditional state.
SET_COND = set([
    'eqx',
    'nex',
    'ltx',
    'ltux',
    'gex',
    'geux',
    'anyx',
    'inpx',
    'cex',
])


# State for the generator.
@dataclass
class State:
    # Condition codes remaining to be used.
    cond: str = ''

    # Number of count operations remaining.
    count: int = 0


# Generate a random immediate.
def rand_imm(imin=0, imax=0xffff):
    return random.randint(imin, imax)


# Generate test prefix -- randomly initialises registers to non-zero values.
def rand_init():
    instrs = []

    for i in range(1, 16):
        ops = {'a': i, 'b': isa.REGS['zr'], 'c': isa.REGS['sp']}
        ops['imm'] = rand_imm()
        instrs.append(isa.Instruction('add', ops))

    return instrs


# Generate a random instruction based on the bias.
def rand_instr(args, state):
    # Choose a random instruction mnemonic.
    while True:
        mnem = random.choices(args.mnems, args.weights)[0]

        # Can't generate a conditional instruction in the shadow of another
        # conditional instruction.
        if state.cond and mnem in SET_COND:
            continue

        # All restrictions have been met so we can use this instruction.
        break

    # Decrement count op state.
    if state.count > 0:
        state.count -= 1

    # Generate random operand values.
    op_names = set(k for k in isa.ENCODINGS[mnem] if k not in '01?')
    op_names = sorted(op_names, key=lambda x: isa.OPERAND_ORDER.index(x))
    ops = {}
    for op in op_names:
        if op in 'abcrs':
            ops[op] = rand_imm(0, 15)

            if op == 'c' and ops[op] == isa.REGS['sp']:
                ops['imm'] = rand_imm()
        elif op == 'm':
            ops[op] = rand_imm(1, 7)
        elif op == 'j':
            ops[op] = rand_imm(0, 15)
            state.count = ops[op]
        else:
            raise NotImplementedError(f'{op}')

    # Pick up the next condition code and assign to the instruction if required.
    cond = None
    if state.cond:
        cond = f'.{state.cond[0]}'
        state.cond = state.cond[1:]
    if mnem in SET_COND:
        if mnem == 'cex':
            state.cond = ''.join(random.choices('tf', k=ops['m']))
        else:
            state.cond = 't'

    return isa.Instruction(mnem, ops, cond)


# Generate end of test -- clear return register and branch back to the wrapper.
def end_test(state):
    instrs = []

    def nop(cond=None):
        return isa.Instruction('add', {'a': 0, 'b': 0, 'c': 0}, cond)

    # Pad out with conditional instructions to consume what remains.
    for cond in state.cond:
        instrs.append(nop(f'.{cond}'))
        if state.count > 0:
            state.count -= 1

    # Pad out further to get through all of the count op state.
    while state.count > 0:
        instrs.append(nop())
        state.count -= 1

    # Clear exit code and jump back to wrapper.
    instrs += [
        isa.Instruction('add', {'a': 1, 'b': 0, 'c': 0}),
        isa.Instruction('j', {'c': isa.REGS['sp'], 'imm': '$test_ret'}),
    ]

    return instrs


# Generate output file.
def save(args, path, instrs):
    # Write out the assembly.
    with open(path, 'w') as f:
        f.write('    .include "../test-wrapper.asm"\n\ntest_main:\n')

        for instr in instrs:
            f.write(f'    {instr}\n')

    # Write out the YAML descriptor.
    # TODO Actually do something with the YAML.
    with open(path.with_suffix('.yaml'), 'w') as f:
        f.write('\n')


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
        '-b',
        '--bias',
        required=True,
        type=pathlib.Path,
        help='Path to input bias file.',
    )

    parser.add_argument(
        '-o',
        '--output',
        required=True,
        type=pathlib.Path,
        help='Path to output test to generate.',
    )

    parser.add_argument(
        '-s',
        '--seed',
        type=lambda x: int(x, 0),
        default=0xdeadbeef,
        help='Random number generator seed.',
    )

    parser.add_argument(
        '-n',
        '--num-instr',
        type=int,
        default=1000,
        help='Number of instructions to generate.',
    )

    args = parser.parse_args()

    if not args.bias.is_file():
        raise Exception(f'Bad input file: {args.input}')

    if args.num_instr <= 0:
        raise Exception(f'Bad instruction count: {args.num_instr}')

    with open(args.bias, 'r') as f:
        args.bias = yaml.safe_load(f)
        args.mnems = list(args.bias.keys())
        args.weights = list(args.bias.values())

    random.seed(args.seed)

    return args


if __name__ == '__main__':
    args = parse_args()

    # Generate the test.
    state = State()
    instrs = rand_init()
    for _ in range(args.num_instr):
        instr = rand_instr(args, state)
        instrs.append(instr)
    instrs += end_test(state)

    # Write to file.
    save(args, args.output, instrs)
