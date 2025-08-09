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
import uart


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

    # Save UART data for checking.
    def write_uart(self, value):
        self.log(f'SIM_UTX: value={value:#06x}')
        self.tb.sim_utx.append(value)

    # Read the next value from the UART.
    def read_uart(self):
        value = self.tb.sim_urx.pop(0)
        self.log(f'SIM_URX: value={value:#06x}')
        return value

    # Record value stored to memory.
    def write_mem(self, addr, value):
        self.log(f'SIM_MEM_WR: addr={addr:#06x} value={value:#06x}')
        self.tb.sim_st_data[addr] = value
        self.mem[addr] = struct.pack('>H', value)

    # Load value from memory.
    def read_mem(self, addr):
        value, = struct.unpack('>H', self.mem[addr])
        self.log(f'SIM_MEM_RD: addr={addr:#06x} value={value:#06x}')
        return value

    # Write an output pin.
    def write_pin(self, pin, value):
        self.log(f'SIM_OUT: pin={pin:d} value={value}')
        self.tb.sim_out_pin[pin] = value


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

        # Received UART from sim and RTL.
        self.sim_utx = []
        self.rtl_utx = []

        # Expected values from the UART with the end of test appended.
        self.ref_utx = [x & 0xffff for x in self.config.get('output', [])]
        self.ref_utx += [ord(x) for x in '@@END@@']

        # Values to be sent into the UART.
        self.sim_urx = list(self.config.get('input', []))
        self.rtl_urx = list(self.sim_urx)

        # Store data to check for an instruction.
        self.sim_st_data = {}
        self.rtl_st_data_lo = {}
        self.rtl_st_data_hi = {}

        # Exit code from the test.
        self.exit_code = None

        # Create UART handlers for connecting to the RTL. Bench is receiving TX
        # data hence why URX pushes to UTX.
        self.urx = uart.URX(lambda x: self.rtl_utx.append(x))
        self.utx = uart.UTX(self.rtl_urx)

        # Output pins written this cycle.
        self.sim_out_pin = {}
        self.rtl_out_pin = {}

        # Signal set when we've seen the test end condition.
        self.end_of_test = Event()

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
        cocotb.start_soon(self._check_uart())
        cocotb.start_soon(self._send_uart())

        self.log('BENCH: RESET BEGIN')

        # Reset sequence pulls the reset pin low for two cycles.
        self.dut.rst_n.setimmediatevalue(1)
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.gck, 2)
        self.dut.rst_n.value = 1

        self.log('BENCH: RESET COMPLETE')

        # Wait for test to end.
        await with_timeout(self.end_of_test.wait(), self.timeout, 'ns')
        self.log(f'BENCH: TEST COMPLETE exit_code={self.exit_code:#06x}')

        # Perform final end-of-test checks.
        self._check_uart_data(final=True)

        # Check exit code is zero.
        assert self.exit_code == 0, 'exit code'

    # Simulates one of the two attached memories.
    async def _run_mem(self, mem):
        # Select appropriate signals in the test bench to use for the memory.
        if mem == self.mem_lo:
            sck = self.dut.mem_lo_sck
            cs = self.dut.mem_lo_cs
            sio_in = self.dut.mem_lo_in
            sio_out = self.dut.mem_lo_out
            st_data = self.rtl_st_data_lo
        else:
            sck = self.dut.mem_hi_sck
            cs = self.dut.mem_hi_cs
            sio_in = self.dut.mem_hi_in
            sio_out = self.dut.mem_hi_out
            st_data = self.rtl_st_data_hi

        # Wait for chip to come out of reset.
        await RisingEdge(self.dut.rst_n)

        while True:
            await RisingEdge(sck)
            if writes := mem.rising_edge(cs.value, sio_out.value):
                st_data.update(writes)

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

            # Check PC was correct.
            self._check_pc()

            # Run instruction on the behavioural model and check the RTL did the
            # same thing.
            self.sim.tick()
            self._check_reg_writes()
            self._check_pred_writes()
            self._check_mem_writes()
            self._check_pin_writes()

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

    # Check PC matches.
    def _check_pc(self):
        sim = f'{self.sim.pc:016b}'
        rtl = self.dut.pc.value.binstr
        assert sim == rtl, 'pc'

    # Check data received from the UART.
    def _check_uart_data(self, final=False):
        while self.sim_utx and self.rtl_utx:
            sim = self.sim_utx.pop(0)
            rtl = self.rtl_utx.pop(0)

            self.log(f'UART: sim={sim:#06x} rtl={rtl:#06x}')
            assert sim == rtl, 'utx data'

            # If we have more reference data then process it, otherwise we're
            # receiving the exit code.
            if self.ref_utx:
                ref = self.ref_utx.pop(0)
                assert ref == rtl, 'utx ref'
            else:
                self.exit_code = rtl
                self.end_of_test.set()

        if not final:
            return

        # If we're at the end of the test then we shouldn't have any more data
        # left in the buffers.
        assert not self.sim_utx, 'outstanding sim utx'
        assert not self.rtl_utx, 'outstanding rtl utx'
        assert not self.sim_urx, 'outstanding sim urx'
        assert not self.rtl_urx, 'outstanding rtl urx'

    # Continuously check UART data.
    async def _check_uart(self):
        tx = self.dut.uart_tx

        # Wait for reset.
        await RisingEdge(self.dut.rst_n)

        while True:
            await RisingEdge(self.dut.gck)

            self.urx.rising_edge(tx.value)
            self._check_uart_data()

    # Send new data into the chip via UART as requested by the ready signal.
    async def _send_uart(self):
        ready = self.dut.uart_rx_rdy
        data = self.dut.uart_rx

        # Make sure data starts as IDLE before reset.
        data.setimmediatevalue(1)

        # Wait for reset then stream in data as requested.
        await RisingEdge(self.dut.rst_n)

        while True:
            await RisingEdge(self.dut.gck)
            data.value = self.utx.rising_edge(ready.value)

    # Check store data is correct.
    def _check_mem_writes(self):
        # Merge the writes to high and low memory into single values.
        addrs = set(self.rtl_st_data_lo.keys())
        addrs |= set(self.rtl_st_data_hi.keys())

        rtl_data = {}
        for addr in addrs:
            lo = self.rtl_st_data_lo.get(addr, self.mem_lo.data[addr])
            hi = self.rtl_st_data_hi.get(addr, self.mem_hi.data[addr])

            data = 0
            data |= (lo & 0x0f) << 0
            data |= (hi & 0x0f) << 4
            data |= (lo & 0xf0) << 4
            data |= (hi & 0xf0) << 8

            rtl_data[addr] = data

        # Sort both sim and RTL into ascending order so they should match.
        rtl_data = {k: rtl_data[k] for k in sorted(rtl_data)}
        sim_data = {k: self.sim_st_data[k] for k in sorted(self.sim_st_data)}

        # Make sure the data matched between the two.
        assert sim_data == rtl_data, f'store data'

        # Reset for next instruction.
        self.rtl_st_data_lo.clear()
        self.rtl_st_data_hi.clear()
        self.sim_st_data.clear()

    # Check sim and RTL both wrote the same pins with the same values.
    def _check_pin_writes(self):
        rtl_sb = self.dut.pins_out_sb

        # Check both thought a write had occurred.
        sim = (1 << next(iter(self.sim_out_pin))) if self.sim_out_pin else 0
        rtl = rtl_sb.value
        assert sim == rtl, 'out pin written'

        if not rtl:
            return

        # Check values are the same.
        sim = f'{next(iter(self.sim_out_pin.values())):01b}'
        rtl = (rtl.integer & -rtl.integer).bit_length() - 1
        rtl = self.dut.pins_out[rtl].value.binstr
        assert sim == rtl, 'out pin value'

        # Clear for next cycle.
        self.sim_out_pin.clear()
        rtl_sb.setimmediatevalue(0)
