# Functions in this file are used to control an RP2040 attached to the two
# SPI memories. This is performed via serial port from the host machine sending
# micropython commands.

import argparse
import pathlib
import re
import serial
import struct


# Pins for connecting to the SPI memories. The RP2040 will only access each
# memory indivdually so they share the same pins except for CS.
CS_LO = 0
CS_HI = 1
SCK   = 2
TX    = 3
RX    = 4
PWR   = 6
NC    = 7
HOLD  = 8

# Commands supported by the 23LC512 memories.
CMD_READ  = 0x03
CMD_WRITE = 0x02
CMD_EQIO  = 0x38


# Class for running commands on the RP2040 via the serial port.
class Pico:
    def __init__(self, port, baud):
        # Open the serial port connection.
        self.tty = serial.Serial(port, baudrate=baud)

        # Run the initilisation commands to import any required modules and
        # initialise the ports.

        # Reset to ensure we start in the default initial state.
        self.reset()

    # Run a single command on the serial port and wait for completion. Returns
    # any output from the command decoded to a UTF-8 string.
    def run(self, cmd):
        # Append "@@DONE@@" to the command as a comment so that we can wait
        # until this appears in the output stream and as a result know the
        # actual command we sent has finished.
        cmd += '\r\n#@@DONE@@\r\n'

        # Send the command to the serial port.
        self.tty.write(cmd.encode('utf-8'))
        self.tty.flush()

        output = ''

        # Wait until we see the end string in the output.
        while True:
            output += self.tty.read(self.tty.in_waiting).decode('utf-8')

            try:
                idx = output.index('#@@DONE@@')
                break
            except ValueError:
                continue

        # Strip off the extra dummy command and return the output.
        return output[:idx]

    # Write data to the memory using the specified CS pin.
    def mem_write(self, cs, addr, data, check=True):
        # Pull CS for the memory low to select it.
        self.run(f'cs[{cs}](0)')

        # Build up data buffer composed of the WRITE command and the data.
        buf = struct.pack('>BH', CMD_WRITE, addr) + data

        # Run the SPI command.
        self.run(f'spi.write({buf})')

        # Set CS high again to end transaction.
        self.run(f'cs[{cs}](1)')

        # If checking read back the data and assert that it's correct.
        if check:
            read = self.mem_read(cs, addr, len(data))
            if read != data:
                raise Exception(
                    f'Data mismatch data != read:\n'
                    f'{data} != {read}'
                )

    # Read data from the specified memory.
    def mem_read(self, cs, addr, n):
        # Start new transaction.
        self.run(f'cs[{cs}](0)')

        # Send READ command and address to the memory.
        data = struct.pack('>BH', CMD_READ, addr)
        self.run(f'spi.write({data})')

        # Read back the data into a temporary buffer.
        self.run(f'__tmp_mem_read = spi.read({n})')

        # End the transaction.
        self.run(f'cs[{cs}](1)')

        # Print out the data and extract the value from the output.
        output = self.run(f'print("DATA:", __tmp_mem_read.hex())')
        m = re.search(r'DATA: (?P<data>[0-9a-f]+)', output)
        assert m

        return bytes.fromhex(m.group('data'))

    # Enter SQI mode in both memories.
    def sqi(self):
        cmd = struct.pack('>B', CMD_EQIO)

        for cs in (CS_LO, CS_HI):
            self.run(f'cs[{cs}](0)')
            self.run(f'spi.write({cmd})')
            self.run(f'cs[{cs}](1)')

    # Reset the memory by powering everything off then returning to the initial
    # state.
    def reset(self):
        init_cmds = (
            'from machine import Pin, SPI',
            f'cs_lo = Pin({CS_LO}, Pin.OUT, value=0)',
            f'cs_hi = Pin({CS_HI}, Pin.OUT, value=0)',
            f'cs = [cs_lo, cs_hi]',
            f'sck = Pin({SCK}, Pin.OUT, value=0)',
            f'tx = Pin({TX}, Pin.OUT, value=0)',
            f'rx = Pin({RX}, Pin.IN)',
            f'pwr = Pin({PWR}, Pin.OUT, value=0)',
            f'nc = Pin({NC}, Pin.OUT, value=0)',
            f'hold = Pin({HOLD}, Pin.OUT, value=0)',
            f'spi = SPI(0, sck=sck, mosi=tx, miso=rx)',
            'hold(1)',
            'cs_lo(1)',
            'cs_hi(1)',
            'pwr(1)',
        )

        for cmd in init_cmds:
            self.run(cmd)

    # Run through the boot sequence and enter the state such that the processor
    # can take over.
    def boot(self, path):
        # Load binary from file and split by low and high nibbles.
        data_lo = b''
        data_hi = b''

        with open(path, 'rb') as f:
            while data := f.read(2):
                data, = struct.unpack('>H', data)

                lo = ((data & 0x0f) >> 0) | ((data & 0x0f00) >> 4)
                hi = ((data & 0xf0) >> 4) | ((data & 0xf000) >> 8)

                data_lo += struct.pack('>B', lo)
                data_hi += struct.pack('>B', hi)

        # Write the data into the two memories.
        self.mem_write(CS_LO, 0, data_lo, check=True)
        self.mem_write(CS_HI, 0, data_hi, check=True)

        # Switch into SQI mode.
        self.sqi()

        # Set all of the pins to floating so the CPU can set the values, with
        # the one exception being PWR as we want the memories to stay powered.
        # We can set the pin to 'z by changing them to inputs.
        for pin in (CS_LO, CS_HI, SCK, TX, RX, NC, HOLD):
            self.run(f'Pin({pin}, Pin.IN)')


# Parse argument when running this script.
def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'bin',
        metavar='BIN',
        type=pathlib.Path,
        help='Path to binary.',
    )

    parser.add_argument(
        '-p',
        '--port',
        default='/dev/tty.usbmodem1301',
        help='Path to RP2040 serial port.',
    )

    parser.add_argument(
        '-b',
        '--baud',
        default=115200,
        type=int,
        help='Baud rate for serial port to RP2040.',
    )

    args = parser.parse_args()

    if not args.bin.is_file():
        raise Exception(f'Bad input binary: {args.bin}')

    return args


# When running this script directly write the binary to the two memories.
if __name__ == '__main__':
    args = parse_args()
    pico = Pico(args.port, args.baud)
    pico.boot(args.bin)
    print('BOOT OKAY')
