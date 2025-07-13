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
        cocotb.start_soon(Clock(self.dut.gck, 2, 'ns').start())

        cocotb.start_soon(self._run_mem(self.mem_lo))
        cocotb.start_soon(self._run_mem(self.mem_hi))

        self.log('BENCH: RESET BEGIN')

        # Reset sequence pulls the reset pin low for two cycles.
        self.dut.rst_n.setimmediatevalue(1)
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 1

        self.log('BENCH: RESET COMPLETE')

        await ClockCycles(self.dut.gck, 50)

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
