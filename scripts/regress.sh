#!/usr/bin/env bash

set -e

unset SIM_TEST
unset SIM_TIMEOUT
unset SIM_DEBUG
unset SIM_YAML

make clean
make -j8 asm
make -j8 sv2v

export COCOTB_LOG_LEVEL=WARNING

TESTS=$(find build/asm -type f -name '*.out')

for TEST in $TESTS; do
    echo "===================="
    echo "$TEST"
    echo "===================="

    make -j8 run_sim SIM_TEST="$TEST"
    make -j8 run_veri SIM_TEST="$TEST"
    make -j8 run_icarus SIM_TEST="$TEST"
done

echo "===================="
echo "    ALL PASSED      "
echo "===================="

