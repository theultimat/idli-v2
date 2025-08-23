# Functions in this file are used to control an RP2040 attached to the two
# SPI memories. This is performed via serial port from the host machine sending
# micropython commands.

import argparse
import pathlib
import re
import serial
import struct


# Pins used for each of the SPI modules. These are given in terms of the RP2040
# GPIO numberings.
CS  = 0
SCK = [2, 14]
TX  = [3, 15]
RX  = [4, 12]


# Functions to create commands return a list of micropython commands that will
# be sent to the RP2040 via the serial port.

# Initialise the two memories. Creates the various pins and SPI interfaces.
# We use a pair of 23LC512 which start in SPI sequential mode.
def cmd_init():
    out = [
        'from machine import Pin, SPI',
        f'cs = Pin({CS}, Pin.OUT)',
        'cs(1)',
    ]

    for i in range(2):
        out += [
            f'sck{i} = Pin({SCK[i]}, Pin.OUT)',
            f'tx{i} = Pin({TX[i]}, Pin.OUT)',
            f'rx{i} = Pin({RX[i]}, Pin.IN)',
            f'spi{i} = SPI({i}, sck=sck{i}, mosi=tx{i}, miso=rx{i})',
        ]

    return out


# Write data to both memories by splitting low and high nibbles of each byte
# between the two.
def cmd_write(addr, data):
    if len(data) % 2:
        raise Exception(f'Length not divisble by two: {len(data)}')

    # Start new transaction.
    out = ['cs(0)']

    addr_hi = (addr >> 8) & 0xff
    addr_lo = (addr >> 0) & 0xff

    # Start WRITE command at specified address.
    for i in range(2):
        out += [f'spi{i}.write(b"\\x02\\x{addr_hi:02x}\\x{addr_lo:02x}")']

    # Iterate through data in 16b chunks and split high and low nibbles.
    for chunk, in struct.iter_unpack('>H', data):
        lo = ((chunk & 0x0f) >> 0) | ((chunk & 0x0f00) >> 4)
        hi = ((chunk & 0xf0) >> 4) | ((chunk & 0xf000) >> 8)

        out += [
            f'spi0.write(b"\\x{lo:02x}")',
            f'spi1.write(b"\\x{hi:02x}")',
        ]

    # Finish transaction.
    out += ['cs(1)']

    return out


# Read data back from the two memories at the specified address and save data
# into variables with the specified names.
def cmd_read(addr, n, var_lo, var_hi):
    out = ['cs(0)']

    addr_hi = (addr >> 8) & 0xff
    addr_lo = (addr >> 0) & 0xff

    var_names = [var_lo, var_hi]

    # Read back the data.
    for i, name in enumerate(var_names):
        out += [
            f'spi{i}.write(b"\\x03\\x{addr_hi:02x}\\x{addr_lo:02x}")',
            f'{name} = spi{i}.read({n})',
        ]

    out += ['cs(1)']

    return out


# Dump the specified variable to stdout. Assumes the variable is bytes().
def cmd_dump(var_name):
    return [f'print("DUMP__{var_name}:", {var_name}.hex())']


# Connect to the serial port at the specified baud rate.
def connect(port, baud):
    return serial.Serial(port, baudrate=baud)


# Run list of commands over the serial port.
def run(tty, cmds):
    output = ''

    # Run commands provided by the user.
    for cmd in cmds:
        tty.write(f'{cmd}\r\n'.encode('utf-8'))
        tty.flush()
        output += tty.read(tty.in_waiting).decode('utf-8')

    # Run a dummy command to wait for the final command to finish.
    tty.write('#@@DONE@@\r\n'.encode('utf-8'))
    tty.flush()

    while True:
        output += tty.read(tty.in_waiting).decode('utf-8')

        if '@@DONE@@' in output:
            break

    return output


# Get dump of a specified variable. Assumes each variable was only dumped once
# in the output stream!
def get_dump_bytes(output, var_name):
    m = re.search(f'DUMP__{var_name}: (?P<data>[0-9a-f]+)', output)

    if not m:
        raise Exception(f'No dump for variable: {var_name}')

    return bytes.fromhex(m.group('data'))


# Write binary into the two memories and check it's correct via the serial port.
def boot(path, port, baud):
    # Load binary from file.
    with open(path, 'rb') as f:
        data = f.read()

    # Build up the command stream for the RP2040.
    cmd = cmd_init()
    cmd += cmd_write(0, data)
    cmd += cmd_read(0, len(data) // 2, 'bin_lo', 'bin_hi')
    cmd += cmd_dump('bin_lo')
    cmd += cmd_dump('bin_hi')

    # Connect via the serial port and run the commands.
    tty = connect(port, baud)
    output = run(tty, cmd)

    # Get the bytes read back from each memory.
    bin_lo = get_dump_bytes(output, 'bin_lo')
    bin_hi = get_dump_bytes(output, 'bin_hi')

    # Check the data that was read back from the memory matches what was
    # originally written.
    for i, (lo, hi) in enumerate(zip(bin_lo, bin_hi)):
        read = 0
        read |= (lo & 0x0f) << 0
        read |= (hi & 0x0f) << 4
        read |= (lo & 0xf0) << 4
        read |= (hi & 0xf0) << 8

        ref, = struct.unpack('>H', data[i*2:i*2+2])

        if ref != read:
            raise Exception(
                f'Read back data does not match at offset {i}: '
                f'0x{read:04x} != 0x{ref:04x}'
            )


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
    boot(args.bin, args.port, args.baud)

    print('BOOT OKAY')
