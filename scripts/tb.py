import cocotb

from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge,
    FallingEdge,
    ClockCycles,
    Event,
    with_timeout,
)


# Bench used with cocotb to run tests on the RTL.
class TestBench:
    def __init__(self, dut, path, config, timeout):
        self.dut = dut
        self.config = config
        self.timeout = timeout
        self.log = dut._log.info

        self.log('BENCH: INIT BEGIN')

        # TODO

        self.log('BENCH: INIT COMPLETE')

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
