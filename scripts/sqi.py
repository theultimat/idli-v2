# Supported modes of the memory.
WRITE = 0x2
READ = 0x3


# Cycle-accurate model of the Microchip 23A512/23LC512 when configured in SQI
# sequential mode. Intended for use with the test bench.
class Memory:
    def __init__(self, log=print):
        # Memory is always 64K bytes.
        self.size = 1 << 16

        # Actual data in the memory. Reset this to None so we can easily detect
        # accesses to uninitialised data.
        self.data = [None] * self.size

        # Address register and wrapping mask for sequential updates.
        self.addr = None
        self.addr_mask = self.size - 1

        # Current state and mode of the memory. We start in an undefined state
        # which will be cleared to reset when chip select is pulled low.
        self.state = None
        self.mode = None

        # Logging function to use for reporting output. Assumed to be able to
        # take at least a single string argument.
        self.log = log

    # Load data into the memory via the backdoor i.e. immediately without
    # consuming any simulation time. Typically used for setting the initial
    # binary before simulation begins.
    def backdoor_load(self, addr, data):
        self.log(f'Backdoor load 0x{addr:04x}: 0x{data:02x}')
        self.data[addr & self.addr_mask] = data & 0xff

    # Called on the rising edge of the clock. The inputs CS and SIO are expected
    # to be 1b and 4b integer values resepectively.
    def rising_edge(self, cs, sio):
        if cs is None or sio is None:
            raise Exception('CS or SIO not connected!')

        # If CS is high then the memory is not currently active so we should
        # go back to the initial uninitialised state and do nothing else.
        if cs:
            if self.mode is not None:
                self.log('Resetting SQI memory.')

            self.addr = None
            self.state = None
            self.mode = None

            return

        # By default return nothing, but if a write was performed then return
        # the address and value.
        write = {}

        # CS is low so the memory is active and the next action to take depends
        # on the current state.
        if self.state is None:
            # This is the first cycle out of reset so we expect the incoming
            # nibble to contain the top 4b of the mode.
            self.mode = sio & 0xf
            self.state = 'mode'
        elif self.state == 'mode':
            # Now we receive the low 4b of the mode.
            self.mode = (self.mode << 4) | (sio & 0xf)

            if self.mode == WRITE:
                self.log('Mode set to WRITE.')
            elif self.mode == READ:
                self.log('Mode set to READ.')
            else:
                raise Exception(f'Unknown mode: {self.mode}')

            self.state = 'addr0'
            self.addr = 0
        elif self.state.startswith('addr'):
            # A 16b address is sent in 4b chunks over four cycles in big-endian.
            self.addr = ((self.addr << 4) | (sio & 0xf)) & self.addr_mask

            # Move to the next cycle or into the read/write phase.
            cycle = int(self.state[-1])
            if cycle == 3:
                self.log(f'Address set to 0x{self.addr:04x}')
                self.state = 'dummy0' if self.mode == READ else 'write0'
            else:
                self.state = f'addr{cycle + 1}'
        elif self.state.startswith('dummy'):
            # There are two dummy cycles before read data becomes available.
            self.state = 'dummy1' if self.state[-1] == '0' else 'read0'
        elif self.state == 'write0':
            # On the first write cycle the top 4b of the byte are received and
            # stored into the memory.
            value = self.data[self.addr] or 0
            value = ((sio & 0xf) << 4) | (value & 0xf)

            self.data[self.addr] = value
            self.state = 'write1'
        elif self.state == 'write1':
            # On the second write cycle the low 4b of the byte are received and
            # the address is incremented for the next byte of data.
            value = (self.data[self.addr] & 0xf0) | (sio & 0xf)

            self.log(f'Write 0x{self.addr:04x}: 0x{value:02x}')
            self.data[self.addr] = value
            write[self.addr] = value
            self.addr = (self.addr + 1) & self.addr_mask

            # In sequential mode we continually receive bytes so go back to the
            # previous state.
            self.state = 'write0'
        elif self.state.startswith('read'):
            # The actual data for a read is only presented on the falling edge
            # of the clock so all that needs to be done on the rising edge is
            # the toggling between the two states.
            self.state = 'read1' if self.state[-1] == '0' else 'read0'
        else:
            raise Exception(f'Unknown state: {self.state}')

        return write

    # Called on the falling edge of the clock, returning the 4b data that was
    # read from the memory.
    def falling_edge(self):
        # If we're not in a read state then there's nothing to return.
        if not self.state or not self.state.startswith('read'):
            return None

        # Get the byte from the memory and complain if we're attempting to read
        # an uninitialised value.
        value = self.data[self.addr]
        if value is None:
            raise Exception(f'Uninitialised read at 0x{self.addr:04x}')

        # Mask off and return the appropriate nibble based on the state.
        if self.state[-1] == '0':
            self.log(f'Read 0x{self.addr:04x}: 0x{value:02x}')
            value = (value >> 4) & 0xf
        else:
            value &= 0xf

            # On second read cycle increment address for next sequential byte.
            self.addr = (self.addr + 1) & self.addr_mask

        return value
