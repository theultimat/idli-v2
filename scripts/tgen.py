import argparse
import pathlib
import random
import yaml

from copy import deepcopy
from dataclasses import dataclass, field

import isa
import sim


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

# Instruction redirects PC.
REDIRECTS = set(['b', 'j', 'bl', 'jl'])


# State for the generator.
@dataclass
class State:
    # Condition codes remaining to be used.
    cond: str = ''

    # Number of count operations remaining.
    count: int = 0

    # Simulator for getting runtime values from the test.
    sim_: sim.Sim = None

    # Allocated addresses.
    used_addrs: set = field(default_factory=set)

    # Peek into the instruction stream.
    instrs: list = None


# Simulator callback.
class Callback(sim.Callback):
    def __init__(self, state):
        self.state = state

    def redirect(self, pc):
        # Update PC to target in assembly file.
        self.state.instrs.append(f'    .org {pc:#x}')


# Generate a random immediate.
def rand_imm(imin=0, imax=0xffff):
    return random.randint(imin, imax)


# Check there's some space free after an address.
def check_space(state, addr, space=16):
    if addr + space > 0xffff:
        return False

    for i in range(space):
        if addr + i in state.used_addrs:
            return False

    return True


# Generate a random address that hasn't been used yet.
def rand_addr(state, offset):
    while True:
        addr = rand_imm()
        target = (addr + offset) & 0xffff
        if check_space(state, target):
            return addr


# Allocate instruction addresses, making sure to account for immediate.
def alloc_instr(state, instr):
    for i in range(instr.size()):
        addr = state.sim_.pc + i
        assert addr not in state.used_addrs, f'{addr} {state.used_addrs}'
        state.used_addrs.add(addr)


# Generate test prefix -- randomly initialises registers to non-zero values.
def rand_init(state):
    instrs = []

    for i in range(1, 16):
        ops = {'a': i, 'b': isa.REGS['zr'], 'c': isa.REGS['sp']}
        ops['imm'] = rand_imm()

        instrs.append(isa.Instruction('add', ops))
        alloc_instr(state, instrs[-1])

        state.sim_.tick(instrs[-1])

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

        # If we're at the end of memory then we need to redirect.
        if state.sim_.pc >= 0xffff - 3:
            mnem = random.choice(list(REDIRECTS))
            break

        # If next addresses (instr + imm) have been allocated we need to branch
        # away now.
        if any(state.sim_.pc + i in state.used_addrs for i in (1, 2, 3)):
            mnem = random.choice(list(REDIRECTS))
            break

        # All restrictions have been met so we can use this instruction.
        break

    # Decrement count op state.
    if state.count > 0:
        state.count -= 1

    # Get current PC from simulator.
    pc = state.sim_.pc

    # Generate random operand values.
    op_names = set(k for k in isa.ENCODINGS[mnem] if k not in '01?')
    op_names = sorted(op_names, key=lambda x: isa.OPERAND_ORDER.index(x))
    ops = {}
    for op in op_names:
        if op in 'abcrs':
            ops[op] = rand_imm(0, 15)

            is_imm = op == 'c' and ops[op] == isa.REGS['sp']
            is_addr = mnem in REDIRECTS

            # Address offset needs to be accounted for when choosing an
            # immediate value.
            if is_addr:
                if mnem in ('b', 'bl'):
                    addr_base = (pc + 1) & 0xffff
                elif mnem in ('j', 'jl'):
                    addr_base = 0
                else:
                    raise NotImplementedError(mnem)

            # If this is a branch and C is a register then we need to make sure
            # the target is a valid address. If it isn't then we'll have to
            # force an immediate instead.
            if not is_imm and mnem in REDIRECTS:
                base = pc if mnem in ('b', 'bl') else 0
                offset = state.sim_.regs[ops[op]]
                target = (base + offset) & 0xffff

                if not check_space(state, target) or target == pc:
                    ops[op] = isa.REGS['sp']
                    is_imm = True

            if is_imm:
                if is_addr:
                    ops['imm'] = rand_addr(state, addr_base)
                else:
                    ops['imm'] = rand_imm()
        elif op == 'm':
            ops[op] = rand_imm(1, 7)
        elif op == 'j':
            ops[op] = rand_imm(0, 15)
            state.count = ops[op]
        else:
            raise NotImplementedError(f'{op}')

    instr = isa.Instruction(mnem, ops)

    # Pick up the next condition code and assign to the instruction if required.
    if state.cond:
        instr.cond = f'.{state.cond[0]}'
        state.cond = state.cond[1:]
    if mnem in SET_COND:
        if mnem == 'cex':
            state.cond = ''.join(random.choices('tf', k=ops['m']))

            # Set cex_state for running on simulator.
            instr.cex_mask = 1 << ops['m']
            for i, x in enumerate(state.cond):
                instr.cex_mask |= int(x == 't') << i
        else:
            state.cond = 't'

    return instr


# Generate end of test -- clear return register and branch back to the wrapper.
def end_test(state):
    instrs = []

    def nop(cond=None):
        return isa.Instruction('add', {'a': 0, 'b': 0, 'c': 0}, cond)

    # Pad out with conditional instructions to consume what remains.
    for cond in state.cond:
        instrs.append(nop(f'.{cond}'))
        alloc_instr(state, instrs[-1])
        state.sim_.tick(instrs[-1])
        if state.count > 0:
            state.count -= 1

    # Pad out further to get through all of the count op state.
    while state.count > 0:
        instrs.append(nop())
        alloc_instr(state, instrs[-1])
        state.sim_.tick(instrs[-1])
        state.count -= 1

    # Send test end condition and exit code.
    for c in '@@END@@':
        instrs.append(
            isa.Instruction('utx', {'c': isa.REGS['sp'], 'imm': ord(c)})
        )
        alloc_instr(state, instrs[-1])
        state.sim_.tick(instrs[-1])

    instrs.append(isa.Instruction('utx', {'c': 0}))
    alloc_instr(state, instrs[-1])
    state.sim_.tick(instrs[-1])

    # Branch to self until exit - don't both running as we don't want to
    # generate another redirect label.
    instrs.append(isa.Instruction('b', {'c': isa.REGS['sp'], 'imm': 0xffff}))
    alloc_instr(state, instrs[-1])

    return instrs


# Generate output file.
def save(args, path, instrs):
    # Write out the assembly.
    with open(path, 'w') as f:
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
    state.sim_ = sim.Sim(Callback(state))

    instrs = rand_init(state)
    state.instrs = instrs
    for _ in range(args.num_instr):
        instr = rand_instr(args, state)
        instrs.append(instr)
        alloc_instr(state, instr)

        # Run instruction on simualtor to fire callbacks for dynamic values.
        # Use a copy as simulator modifies some instructions (e.g. CEX).
        state.sim_.tick(deepcopy(instr))

    instrs += end_test(state)

    # Write to file.
    save(args, args.output, instrs)
