import argparse
import pathlib
import serial
import struct


# Commands for sending to podi.
CMD_PING  = b'\x00'
CMD_FLASH = b'\x01'
CMD_RUN   = b'\x02'


# Connects to the podi instance running on a pico and sends commands.
class Podi:
    def __init__(self, port, baud):
        # Open serial connection.
        self.tty = serial.Serial(port, baudrate=baud)

    # Send command bytes to the board and wait for the response.
    def _run(self, cmd, stream=False):
        self.tty.write(cmd)
        self.tty.flush()

        output = ''
        while True:
            tmp = self.tty.read(self.tty.in_waiting).decode('utf-8')
            output += tmp

            if stream and tmp:
                print(tmp, end='')

            if '=== DONE ===' in output:
                break

        return output

    # Run ping command to check we're connected.
    def ping(self):
        output = self._run(CMD_PING)
        print(output)

    # Run flash command to write data from file into memory.
    def flash(self, path):
        cmd = CMD_FLASH
        n = 0
        data_lo = b''
        data_hi = b''

        with open(path, 'rb') as f:
            while data := f.read(2):
                data, = struct.unpack('>H', data)

                lo = ((data & 0x0f) >> 0) | ((data & 0x0f00) >> 4)
                hi = ((data & 0xf0) >> 4) | ((data & 0xf000) >> 8)

                data_lo += struct.pack('>B', lo)
                data_hi += struct.pack('>B', hi)

                n += 1

        cmd += struct.pack('<H', n)
        cmd += data_lo
        cmd += data_hi

        output = self._run(cmd)
        print(output)

    # Run whatever is in the memory.
    def run(self):
        self._run(CMD_RUN, stream=True)


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
        help='Path to Pico serial port.',
    )

    parser.add_argument(
        '-b',
        '--baud',
        default=115200,
        type=int,
        help='Baud rate for serial port to Pico.',
    )

    args = parser.parse_args()

    if not args.bin.is_file():
        raise Exception(f'Bad input binary: {args.bin}')

    return args


if __name__ == '__main__':
    args = parse_args()
    podi = Podi(args.port, args.baud)

    podi.ping()
    podi.flash(args.bin)
    podi.run()
