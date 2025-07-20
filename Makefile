BUILD_ROOT  := build
SOURCE_ROOT := src
SCRIPT_ROOT := scripts
ASM_ROOT    := asm
TEST_ROOT   := test


PYTHON := python
PIP    := pip


# Set to enable debug logging where available.
DEBUG ?=


all: asm

clean:
	rm -rf $(BUILD_ROOT)

.PHONY: all clean


# Create virtual environment for running scripts.
VENV_DIR      := $(BUILD_ROOT)/venv
VENV_ACTIVATE := $(VENV_DIR)/bin/activate
VENV_REQ      := $(SCRIPT_ROOT)/requirements.txt
VENV          := $(VENV_DIR)/.ready

venv: $(VENV)

$(VENV_DIR):
	@mkdir -p $(@D)
	$(PYTHON) -m venv $@

$(VENV): $(VENV_REQ) $(VENV_DIR)
	source $(VENV_ACTIVATE) && $(PIP) install -r $<
	touch $@

.PHONY: venv


# Build tests using the assembler.
ASM_WRAPPER := $(ASM_ROOT)/test-wrapper.asm
ASM_SOURCES := $(filter-out $(ASM_WRAPPER),$(wildcard $(ASM_ROOT)/*.asm))
ASM_BINS    := $(patsubst %.asm,$(BUILD_ROOT)/%.out,$(ASM_SOURCES))

AS_DEBUG := $(if $(DEBUG),--verbose,)

AS      := source $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/asm.py $(AS_DEBUG)
OBJDUMP := source $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/objdump.py

asm: venv $(ASM_BINS)

$(BUILD_ROOT)/%.out: %.asm $(ASM_WRAPPER) $(VENV)
	@mkdir -p $(@D)
	$(AS) -o $@ $<
	$(OBJDUMP) $@ > $@.txt

.PHONY: asm


# Lint the design using verilator.
SV_SOURCES := $(wildcard $(SOURCE_ROOT)/*.sv $(TEST_ROOT)/*.sv)
SV_HEADERS := $(wildcard $(SOURCE_ROOT)/*.svh $(TEST_ROOT)/*.svh)

lint: $(SV_SOURCES) $(SV_HEADERS)
	verilator -Wall --lint-only -I$(SOURCE_ROOT) $(SV_SOURCES)

.PHONY: lint


# Convert SystemVerilog to Verilog.
SV2V_ROOT := $(BUILD_ROOT)/sv2v
V_SOURCES := $(patsubst %.sv,$(SV2V_ROOT)/%.v,$(SV_SOURCES))

SV2V := sv2v -I$(SOURCE_ROOT)

sv2v: lint $(V_SOURCES)

$(SV2V_ROOT)/%.v: %.sv $(SV_HEADERS)
	@mkdir -p $(@D)
	$(SV2V) $< > $@

.PHONY: sv2v


# Run test on the simulator.
export SIM_TEST    ?= $(BUILD_ROOT)/$(ASM_ROOT)/smoke.out
export SIM_TIMEOUT ?= 50000
export SIM_DEBUG   ?= $(if $(DEBUG),--verbose,)
export SIM_YAML    ?= $(ASM_ROOT)/$(notdir $(basename $(SIM_TEST))).yaml

SIM := source $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/sim.py $(SIM_DEBUG)

run_sim: $(SIM_TEST) $(VENV)
	$(SIM) $< --timeout $(SIM_TIMEOUT) --yaml $(SIM_YAML)

.PHONY: run_sim


# Run test on verilator or iverilog.
VERI_DEBUG   := $(if $(DEBUG),gtkwave $(TEST_ROOT)/*.fst,)
ICARUS_DEBUG := $(if $(DEBUG),gtkwave $(BUILD_ROOT)/test/sim_build/*.fst,)

run_veri: $(SIM_TEST) $(VENV) lint
	source $(VENV_ACTIVATE) && make -C $(TEST_ROOT) RTL_SIM=verilator
	$(VERI_DEBUG)

run_icarus: $(SIM_TEST) $(VENV) sv2v
	source $(VENV_ACTIVATE) && make -C $(TEST_ROOT) RTL_SIM=icarus
	$(ICARUS_DEBUG)

.PHONY: run_veri run_icarus
