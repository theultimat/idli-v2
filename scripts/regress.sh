#!/usr/bin/env bash

set -e

make clean
make -j8 asm
make -j8 sv2v

TESTS=$(find build/asm -type f -name '*.out')

for TEST in $TESTS; do
    make -j8 run_sim SIM_TEST="$TEST"
    make -j8 run_veri SIM_TEST="$TEST"
    make -j8 run_icarus SIM_TEST="$TEST"
done

echo "===================="
echo "    ALL PASSED      "
echo "===================="

