import argparse
import pathlib
import yaml

import isa

from objdump import decode


# Callback for hooking into simulator events.
class Callback:
    # Called when value is written to a register.
    def write_reg(self, reg, value):
        pass

    # Called when predicate register is written.
    def write_pred(self, value):
        pass

    # Called when cond state is written.
    def write_cond(self, value):
        pass

    # Called when memory is read/written.
    def write_mem(self, addr, value):
        pass

    def read_mem(self, addr):
        return None

    # Called when UART is accessed.
    def write_uart(self, value):
        pass

    def read_uart(self):
        return None

    # Called when memory is read for an instruction fetch. Expected to return
    # an object of type isa.Instruction
    def fetch(self, pc):
        return None


# Behavioural simulator of the core. Not cycle accurate.
class Sim:
    def __init__(self, cb=Callback(), verbose=False):
        self.cb = cb
        self.verbose = verbose

        # Program counter resets to zero.
        self.pc = 0

        # Registers are not reset by the hardware so start at an unknown value,
        # except for the zero register.
        self.regs = [None] * 16
        self.regs[0] = 0

        # Predicate register and cond state reset to zero.
        self.pred = False
        self.cond = 0

        # Number of times tick() has been called.
        self.ticks = 0

        # Functions for running each instruction type.
        self.funcs = {
            'add':      self._add_sub,
            'sub':      self._add_sub,
            'and':      None,
            'andn':     None,
            'or':       None,
            'xor':      None,
            'ld':       None,
            'st':       None,
            'ldm':      None,
            'stm':      None,
            'ld+':      None,
            'st+':      None,
            '+ld':      None,
            '+st':      None,
            'ld-':      None,
            'st-':      None,
            '-ld':      None,
            '-st':      None,
            'inc':      self._inc_dec,
            'dec':      self._inc_dec,
            'srl':      None,
            'sra':      None,
            'ror':      None,
            'rol':      None,
            'not':      None,
            'urx':      self._urx,
            'getp':     None,
            'eq':       self._cmp,
            'ne':       self._cmp,
            'lt':       self._cmp,
            'ltu':      self._cmp,
            'ge':       self._cmp,
            'geu':      self._cmp,
            'bit':      self._cmp,
            'inp':      None,
            'eqx':      self._cmp,
            'nex':      self._cmp,
            'ltx':      self._cmp,
            'ltux':     self._cmp,
            'gex':      self._cmp,
            'geux':     self._cmp,
            'bitx':     self._cmp,
            'inpx':     None,
            'addpc':    None,
            'b':        self._jmp,
            'j':        self._jmp,
            'bl':       self._jmp,
            'jl':       self._jmp,
            'in':       None,
            'out':      None,
            'out1':     None,
            'outp':     None,
            'utx':      self._utx,
            'carry':    None,
            'putp':     None,
            'cex':      self._cex,
        }

    # Run a single instruction.
    def tick(self):
        redirect = None

        # Fetch instruction and get the next sequential PC, then increment the
        # PC register to account for the pipeline in the hardware.
        instr, pc = self._fetch(self.pc)
        self.pc += 1

        # Check if the instruction should run based on the predicate register
        # and cond state, and if so execute the instruction.
        if self._check_run():
            # Special case for CEX as we want the actual value rather than the
            # number of predicated followers which is used returned by the
            # decoder in the operand.
            ops = instr.ops
            if instr.mnem == 'cex':
                ops['m'] = instr.cex_mask

            redirect = self.funcs[instr.mnem](instr.mnem, **ops)

        # If the instruction redirected the PC update it to the new address,
        # otherwise continue sequentially.
        if redirect:
            self._log(f'BRANCH 0x{redirect:04x}')
            self.pc = redirect
        else:
            self.pc = pc

        # Increment tick counter for logging.
        self.ticks += 1

    # Fetch the next instruction, returning its value and the next PC.
    def _fetch(self, pc):
        instr = self.cb.fetch(pc)

        # Add cond based on current state for tracing.
        if self.cond not in (0, 1):
            instr.cond = '.t' if self.cond & 1 else '.f'

        self._log(f'RUN    0x{self.pc:04x}    {instr}')
        return instr, pc + instr.size()

    # Check for whether the next instruction should run.
    def _check_run(self):
        # If the conditional state is 0 or 1 then it's invalid so the next
        # instruction should always be run.
        if self.cond in (0, 1):
            return True

        # Take the current lowest bit of the state. If this is a 1 the
        # instruction will run if the predicate register is true, and if zero
        # it will run if the predicate register is false.
        run = (self.cond & 1) == self.pred

        # Shift out the now consumed bit of the cond state.
        self.cond >>= 1

        if not run:
            self._log(f'SKIP   {int(run)}')

        return run

    # Write a new value to a register, discarding writes to ZR.
    def _write_reg(self, reg, value):
        if not reg:
            return

        self._log(f'REG    {isa.REGS_INV[reg]:3}       0x{value:04x}')
        self.regs[reg] = value
        self.cb.write_reg(reg, value)

    # Write the predicate register.
    def _write_pred(self, value):
        self._log(f'PRED   {int(value)}')
        self.pred = bool(value)
        self.cb.write_pred(value)

    # Write cond state.
    def _write_cond(self, value):
        value_str = bin(value)[3:].replace('1', 'T').replace('0', 'F')[::-1]
        self._log(f'COND   {value_str}')
        self.cond = value
        self.cb.write_cond(value)

    # Log if verbose is enabled.
    def _log(self, *args):
        if self.verbose:
            print(f'{self.ticks:6d} ', end='')
            print(*args)

    # Convert value from u16 to i16.
    def _u2s(self, value):
        if value & (1 << 15):
            value -= (1 << 16)

        return value

    # Add/subtract implementation.
    def _add_sub(self, mnem, a=None, b=None, c=None, imm=None):
        lhs = self.regs[b]
        rhs = self.regs[c] if c != isa.REGS['sp'] else imm

        value = lhs + rhs if mnem == 'add' else lhs - rhs
        value &= 0xffff

        self._write_reg(a, value)

    # Comparison instructions.
    def _cmp(self, mnem, b=None, c=None, imm=None):
        lhs = self.regs[b]
        rhs = self.regs[c] if c != isa.REGS['sp'] else imm

        if mnem in ('eq', 'eqx'):
            value = lhs == rhs
        elif mnem in ('ne', 'nex'):
            value = lhs != rhs
        elif mnem in ('lt', 'ltx'):
            value = self._u2s(lhs) < self._u2s(rhs)
        elif mnem in ('ltu', 'ltux'):
            value = lhs < rhs
        elif mnem in ('ge', 'gex'):
            value = self._u2s(lhs) >= self._u2s(rhs)
        elif mnem in ('geu', 'geux'):
            value = lhs >= rhs
        elif mnem in ('bit', 'bitx'):
            value = bool(lhs & (1 << lhs))
        else:
            raise NotImplementedError()

        self._write_pred(value)

        if mnem[-1] == 'x':
            self._write_cond(0b11)

    # Branch and jump instructions.
    def _jmp(self, mnem, c=None, imm=None):
        lhs = None
        rhs = self.regs[c] if c != isa.REGS['sp'] else imm

        # Branches are relative to PC, jumps are absolute.
        if mnem[0] == 'b':
            lhs = self.pc
            rhs = self._u2s(rhs)
        else:
            lhs = 0

        # Write link register with next sequential instruction, accounting for
        # the immediate.
        if mnem[-1] == 'l':
            self._write_reg(isa.REGS['lr'], self.pc + int(imm is not None))

        return (lhs + rhs) & 0xffff

    # UART TX instruction.
    def _utx(self, mnem, c=None, imm=None):
        value = self.regs[c] if c != isa.REGS['sp'] else imm
        value &= 0xffff

        self._log(f'UTX    0x{value:04x}')
        self.cb.write_uart(value)

    # UART RX.
    def _urx(self, mnem, a=None):
        value = self.cb.read_uart() & 0xffff

        self._log(f'URX    0x{value:04x}')
        self.regs[a] = value

    # Cond state configuration instruction.
    def _cex(self, mnem, m=None):
        self._write_cond(m)

    # Increment and decrement make use of ADD/SUB.
    def _inc_dec(self, mnem, a=None, b=None):
        imm = -1 if mnem == 'dec' else 1
        return self._add_sub('add', a=a, b=b, c=isa.REGS['sp'], imm=imm)


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
        help='Path to input binary.',
    )

    parser.add_argument(
        '-t',
        '--timeout',
        default=5000,
        type=int,
        help='Number of ticks to run before timing out.',
    )

    parser.add_argument(
        '-y',
        '--yaml',
        required=True,
        type=pathlib.Path,
        help='YAML config for the test.',
    )

    args = parser.parse_args()

    if not args.input.is_file():
        raise Exception(f'Bad input file: {args.input}')

    if not args.yaml.is_file():
        raise Exception(f'Bad YAML file: {args.yaml}')

    with open(args.yaml, 'r') as f:
        args.yaml = yaml.safe_load(f)

    return args


# Run a binary on the simulator.
if __name__ == '__main__':
    args = parse_args()

    # UART IO buffers.
    uart_tx = []
    uart_rx = [] if not args.yaml else args.yaml.get('input', [])

    class Cb(Callback):
        # Load binary into memory.
        def __init__(self, path, uart_tx, uart_rx):
            self.mem = {}
            self.uart_tx = uart_tx
            self.uart_rx = uart_rx

            with open(path, 'rb') as f:
                data = f.read()

            # Split into 16b chunks.
            for i in range(len(data) // 2):
                self.mem[i] = data[i * 2:i * 2 + 2]

        # Fetch instruction from memory.
        def fetch(self, pc):
            data = self.mem.get(pc)
            if data is None:
                raise Exception(f'Fetch from uninitialised memory: 0x{pc:04x}')

            # Add on the next 16b if it exists in case this instruction takes an
            # immediate.
            data += self.mem.get(pc + 1, b'')

            # Decode and return the instruction.
            return decode(data, max_items=1)[0]

        # UART IO.
        def write_uart(self, value):
            self.uart_tx.append(value)

        def read_uart(self):
            if not self.uart_rx:
                raise Exception(f'No data in UART RX buffer')

            return self.uart_rx.pop(0)

    # End of test is signalled by receiving the string @@END@@ over UART
    # followed by the exit code of test_main.
    end_of_test = [ord(x) for x in '@@END@@']
    exit_code = None

    cb = Cb(args.input, uart_tx, uart_rx)
    sim = Sim(cb, args.verbose)

    for _ in range(args.timeout):
        sim.tick()

        # Look for the end of test value in the UART buffer followed by the
        # exit code.
        if uart_tx[-len(end_of_test) - 1:-1] == end_of_test:
            exit_code = uart_tx[-1]
            break

    if exit_code is None:
        raise Exception(f'Timed out after {args.timeout} ticks')

    sim._log(f'EXIT   0x{exit_code:04x}')

    if exit_code:
        raise Exception(f'Exited with non-zero code: 0x{exit_code:04x}')

    # Check data received over UART matches expected.
    if args.yaml and args.yaml['output']:
        if (data := uart_tx[:-len(end_of_test) - 1]) != args.yaml['output']:
            raise Exception(
                f'Received data incorrect:\n'
                f'  - Expected  {args.yaml["output"]}\n'
                f'  - Received  {data}'
            )
