import cocotb
import struct

from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge,
    FallingEdge,
    ClockCycles,
    Event,
    with_timeout,
)

import isa
import objdump
import sim
import sqi


# Callback used for behavioural model with the bench.
class Callback(sim.Callback):
    def __init__(self, tb, path):
        super().__init__()

        self.tb = tb
        self.log = tb.log
        self.mem = {}

        # Load a local copy of the memory for the simulator.
        with open(path, 'rb') as f:
            data = f.read()

        for i in range(len(data) // 2):
            self.mem[i] = data[i*2:i*2+2]

    def fetch(self, pc):
        # Fetch 16b or 32b to cover a following immediate.
        data = self.mem.get(pc)
        assert data is not None, f'{pc:04x}'
        data += self.mem.get((pc + 1) & 0xffff, b'')

        instr = objdump.decode(data, max_items=1)[0]
        self.log(f'SIM_RUN: pc={pc:#06x} instr={instr}')

        return instr

    # Update register write scoreboard.
    def write_reg(self, reg, value):
        self.log(f'SIM_REG_WR: reg={isa.REGS_INV[reg]} value={value:#06x}')
        self.tb.sim_reg_sb[reg] = value

    # Record predicate write.
    def write_pred(self, value):
        self.log(f'SIM_PRED_WR: value={value:#x}')
        self.tb.sim_pred = value


# Bench used with cocotb to run tests on the RTL.
class TestBench:
    def __init__(self, dut, path, config, timeout):
        self.dut = dut
        self.config = config
        self.timeout = timeout
        self.log = dut._log.info

        # Create the two memories, one for low nibbles and one for high.
        self.mem_lo = sqi.Memory(log=lambda x: self.log(f'SQI_LO: {x}'))
        self.mem_hi = sqi.Memory(log=lambda x: self.log(f'SQI_HI: {x}'))

        # Create behavioural model for comparison with the RTL.
        self.cb = Callback(self, path)
        self.sim = sim.Sim(self.cb)

        # Scoreboard for register writes and the values written.
        self.sim_reg_sb = {}

        # Whether predicate register was written by sim and its value.
        self.sim_pred = None

        self.log('BENCH: INIT BEGIN')

        self._load_binary(path)

        self.log('BENCH: INIT COMPLETE')

    # Load the input binary from file into the two memories.
    def _load_binary(self, path):
        with open(path, 'rb') as f:
            addr = 0
            while data := f.read(2):
                data, = struct.unpack('>H', data)

                lo = ((data & 0x0f) >> 0) | ((data & 0x0f00) >> 4)
                hi = ((data & 0xf0) >> 4) | ((data & 0xf000) >> 8)

                self.mem_lo.backdoor_load(addr, lo)
                self.mem_hi.backdoor_load(addr, hi)

                addr += 1

    # Run the simulation and checkers.
    async def run(self):
        cocotb.start_soon(Clock(self.dut.gck, 2, 'ns').start())

        cocotb.start_soon(self._run_mem(self.mem_lo))
        cocotb.start_soon(self._run_mem(self.mem_hi))
        cocotb.start_soon(self._check_instr())

        self.log('BENCH: RESET BEGIN')

        # Reset sequence pulls the reset pin low for two cycles.
        self.dut.rst_n.setimmediatevalue(1)
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 1

        self.log('BENCH: RESET COMPLETE')

        await ClockCycles(self.dut.gck, 100)

    # Simulates one of the two attached memories.
    async def _run_mem(self, mem):
        # Select appropriate signals in the test bench to use for the memory.
        if mem == self.mem_lo:
            sck = self.dut.mem_lo_sck
            cs = self.dut.mem_lo_cs
            sio_in = self.dut.mem_lo_in
            sio_out = self.dut.mem_lo_out
        else:
            sck = self.dut.mem_hi_sck
            cs = self.dut.mem_hi_cs
            sio_in = self.dut.mem_hi_in
            sio_out = self.dut.mem_hi_out

        # Wait for chip to come out of reset.
        await RisingEdge(self.dut.rst_n)

        while True:
            await RisingEdge(sck)
            mem.rising_edge(cs.value, sio_out.value)

            await FallingEdge(sck)
            if (data := mem.falling_edge()) is not None:
                sio_in.value = data

    # Check instructions perform perform the same operations as the behavioural
    # model implementation.
    async def _check_instr(self):
        done = self.dut.instr_done_q

        # Wait for reset to finish.
        await RisingEdge(self.dut.rst_n)

        while True:
            await RisingEdge(self.dut.gck)

            # Wait for an instruction to complete in the RTL.
            if not done.value:
                continue

            # TODO Check PC was correct.

            # Run instruction on the behavioural model and check the RTL did the
            # same thing.
            self.sim.tick()
            self._check_reg_writes()
            self._check_pred_writes()

    # Check outstanding register writes match.
    def _check_reg_writes(self):
        rtl_sb = self.dut.reg_sb

        # Skip ZR as RTL never sets write enable for it.
        for i in range(1, 16):
            # Check RTL and BM agree on whether this register was written.
            sim = i in self.sim_reg_sb
            rtl = bool(rtl_sb.value & (1 << i))
            assert sim == rtl, f'{isa.REGS_INV[i]} written'

            # If we didn't write or it's ZR then skip the register.
            if not rtl or i == 0:
                continue

            # Check the value written matches.
            sim = f'{self.sim_reg_sb[i]:016b}'
            rtl = self.dut.reg_data[i].value.binstr
            assert sim == rtl, f'{isa.REGS_INV[i]} data'

        # Clear the scoreboards for the next cycle.
        self.sim_reg_sb = {}
        rtl_sb.setimmediatevalue(0)

    # Check outstanding predicate writes match.
    def _check_pred_writes(self):
        rtl_sb = self.dut.pred_sb

        # Check both agreed on whether a write was performed.
        sim = self.sim_pred is not None
        rtl = bool(rtl_sb.value)
        assert sim == rtl, 'predicate written'

        if not rtl:
            return

        # Make sure the values were the same.
        sim = f'{self.sim_pred:01b}'
        rtl = self.dut.pred.value.binstr
        assert sim == rtl, f'predicate write data'

        # Clear for next cycle.
        self.sim_pred = None
        rtl_sb.setimmediatevalue(0)
