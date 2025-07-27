# Run a single test as specified by the environment variables. These should
# have been set up by the Makefile!

import cocotb
import os
import pathlib
import yaml

from tb import TestBench


@cocotb.test()
async def run_test(dut):
    # Parse arguments from environment, accounting for the paths being relative
    # to the parent directory.
    path = '..'/pathlib.Path(os.environ['SIM_TEST'])
    timeout = int(os.environ['SIM_TIMEOUT'])
    config = pathlib.Path(os.environ['SIM_YAML'])

    with open('..'/config, 'r') as f:
        config = yaml.safe_load(f)

    if config is None:
        config = {}

    await TestBench(dut, path, config, timeout).run()
