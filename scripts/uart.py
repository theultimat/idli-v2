# Receive UART data from the RTL.
class URX:
    def __init__(self, cb):
        # Callback for when we've received 16b of data.
        self.cb = cb

        # Start in the idle state.
        self.state = 'idle'

        # Buffer for holding data until ready to pass to callback. Stored in
        # 8b chunks.
        self.buf = []

    # Called on rising edge of the clock.
    def rising_edge(self, value):
        if value is None:
            raise Exception(f'Pin is not connected!')

        if self.state == 'idle':
            # Stay in the idle state until we see a zero indicating the next 8b
            # will be data.
            if value == 0:
                self.buf.append(0)
                self.state = 'data0'
        elif self.state.startswith('data'):
            bits = int(self.state[-1])
            self.buf[-1] |= (value & 1) << bits

            # If we have 8b we've finished the payload, otherwise keep receiving
            # data.
            bits += 1
            if bits == 8:
                self.state = 'idle'

                # When we have two entries in the buffer we can combine them
                # and fire the callback.
                if len(self.buf) >= 2:
                    data = self.buf[0] | (self.buf[1] << 8)
                    self.cb(data)
                    self.buf = self.buf[2:]
            else:
                self.state = f'data{bits}'
        else:
            raise Exception(f'Unknown state: {self.state}')


# Send UART data to the RTL.
class UTX:
    def __init__(self, data):
        # Queue of data to send in 16b chunks.
        self.data = data

        # Number of bits sent out of the current 16b chunk.
        self.bits = 0

        # Start in idle state.
        self.state = 'idle_lo'

    # Called on rising edge of the clock. The "ready" argument indicates that
    # the RTL is ready to receive a new 16b chunk of data.
    def rising_edge(self, ready):
        if ready is None:
            raise Exception(f'Pin is not connected!')

        out = None

        if self.state == 'idle_lo':
            # Wait in idle state until we receive the ready. When we do send the
            # start bit and move to the data state.
            if ready:
                assert self.data, 'No more data to send!'
                out = 0
                self.state = 'data'
                self.bits = 0
            else:
                out = 1
        elif self.state == 'data':
            # Extract the low bit and increment the counter.
            out = self.data[0] & 1
            self.data[0] >>= 1
            self.bits += 1

            # If we've now sent 8b we need to transition to the next 8b
            # transaction through idle. If we've done all 16b then we can pop
            # the buffer and return to reset.
            if self.bits == 8:
                self.state = 'idle_hi'
            elif self.bits == 16:
                self.data.pop(0)
                self.state = 'idle_lo'
        elif self.state == 'idle_hi':
            # Pull high to reset.
            out = 1
            self.state = 'start_hi'
        elif self.state == 'start_hi':
            # Pull low to start new 8b transaction.
            out = 0
            self.state = 'data'
        else:
            raise Exception(f'Unknown state: {self.state}')

        assert out is not None, 'Cannot output None on UTX!'

        return out
