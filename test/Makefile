# CocoTb is used for running RTL tests so we need a separate Makefile.

BUILD_ROOT  := ../build
SOURCE_ROOT := ../src
TEST_ROOT   := ../test
SCRIPT_ROOT := ../scripts
SV2V_ROOT   := ../build/sv2v

# This Makefile shouldn't be called directly so do a quick sanity check that
# the simulator has been set externally by the main Makefile.
ifeq ($(RTL_SIM),)
$(error No RTL simulator specified! Are you running from the root Makefile?)
endif

# Gather all the sources and indicate we're using (System)Verilog.
TOPLEVEL_LANG   := verilog
BENCH_SOURCE    := $(TEST_ROOT)/idli_tb_m.sv

VERILOG_SOURCES := $(wildcard $(SOURCE_ROOT)/*.sv)
VERILOG_SOURCES += $(wildcard $(SOURCE_ROOT)/*.svh)
VERILOG_SOURCES += $(BENCH_SOURCE)

# Configure simulator flags, specialising for simulator if required.
COMPILE_ARGS := -I$(SOURCE_ROOT)
PLUSARGS     :=
EXTRA_ARGS   :=

ifeq ($(RTL_SIM),verilator)

COMPILE_ARGS += -Wall
PLUSARGS     += +verilator+rand+reset+2
EXTRA_ARGS   += --trace --trace-fst --trace-structs
EXTRA_ARGS   += --x-assign unique --x-initial unique

else ifeq ($(RTL_SIM),icarus)

WAVES := 1

# iverilog doesn't support SystemVerilog so point at Verilog instead.
VERILOG_SOURCES := $(patsubst ../%.sv,$(SV2V_ROOT)/%.v,$(VERILOG_SOURCES))

else

$(error Unknown value for RTL_SIM: $(RTL_SIM))

endif

# Configure test to run.
COCOTB_RESULTS_FILE := $(BUILD_ROOT)/test/results.xml
SIM_BUILD           := $(BUILD_ROOT)/test/sim_build
TOPLEVEL            := $(notdir $(basename $(BENCH_SOURCE)))
MODULE              ?= run_test
SIM                 := $(RTL_SIM)

# Make sure python path includes the scripts area.
export PYTHONPATH := $(SCRIPT_ROOT):$(PYTHONPATH)

# Include root CocoTb Makefile.
include $(shell cocotb-config --makefiles)/Makefile.sim
