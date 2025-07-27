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

