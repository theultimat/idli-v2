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
	. $(VENV_ACTIVATE) && $(PIP) install -r $<
	touch $@

.PHONY: venv


# Build tests using the assembler.
ASM_WRAPPER := $(ASM_ROOT)/test-wrapper.asm
ASM_SOURCES := $(shell find $(ASM_ROOT) -type f -name '*.asm')
ASM_SOURCES := $(filter-out $(ASM_WRAPPER),$(ASM_SOURCES))
ASM_BINS    := $(patsubst %.asm,$(BUILD_ROOT)/%.out,$(ASM_SOURCES))

AS_DEBUG := $(if $(DEBUG),--verbose,)

AS      := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/asm.py $(AS_DEBUG)
OBJDUMP := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/objdump.py

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
export SIM_TIMEOUT ?= 500000
export SIM_DEBUG   ?= $(if $(DEBUG),--verbose,)
export SIM_YAML    ?= $(patsubst $(BUILD_ROOT)/%.out,%.yaml,$(SIM_TEST))

SIM := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/sim.py $(SIM_DEBUG)

run_sim: $(SIM_TEST) $(VENV)
	$(SIM) $< --timeout $(SIM_TIMEOUT) --yaml $(SIM_YAML)

.PHONY: run_sim


# Run test on verilator or iverilog.
VERI_DEBUG   := $(if $(DEBUG),gtkwave $(TEST_ROOT)/*.fst,)
ICARUS_DEBUG := $(if $(DEBUG),gtkwave $(BUILD_ROOT)/test/sim_build/*.fst,)

run_veri: $(SIM_TEST) $(VENV) lint
	. $(VENV_ACTIVATE) && make -C $(TEST_ROOT) RTL_SIM=verilator
	$(VERI_DEBUG)

run_icarus: $(SIM_TEST) $(VENV) sv2v
	. $(VENV_ACTIVATE) && make -C $(TEST_ROOT) RTL_SIM=icarus
	$(ICARUS_DEBUG)

.PHONY: run_veri run_icarus


# Regenerate random tests.
TGEN_DEBUG := $(if $(DEBUG),--verbose,)
TGEN       := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/tgen.py

TEST_BIAS := $(wildcard $(TEST_ROOT)/bias/*.yaml)
TEST_ASM  := $(patsubst $(TEST_ROOT)/bias/%.yaml,$(ASM_ROOT)/tgen/%.asm,$(TEST_BIAS))

$(ASM_ROOT)/tgen/%.asm: $(TEST_ROOT)/bias/%.yaml
	@mkdir -p $(@D)
	$(TGEN) $(TGEN_DEBUG) --bias $< --output $@ --seed 0x$(shell cat $(patsubst %.yaml,%.seed,$<))

tgen: $(TEST_ASM)

.PHONY: tgen


# Run full regression.
regress:
	./scripts/regress.sh

.PHONY: regress


# Write the specified binary to memories via connected the RP2040.
BOOTER := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/pico.py

BOOT_PORT ?= /dev/tty.usbmodem1301
BOOT_BAUD ?= 115200

pico_boot: $(SIM_TEST)
	$(BOOTER) $< --port $(BOOT_PORT) --baud $(BOOT_BAUD)

.PHONY: pico_boot
