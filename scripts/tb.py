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

import sqi


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
        cocotb.start_soon(Clock(self.dut.gck, 40, 'us').start())

        self.log('BENCH: RESET BEGIN')

        # Reset sequence pulls the reset pin low for two cycles.
        self.dut.rst_n.value = 1
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 1

        self.log('BENCH: RESET COMPLETE')

        await ClockCycles(self.dut.gck, 10)
