BUILD_ROOT  := build
SOURCE_ROOT := src
SCRIPT_ROOT := scripts
ASM_ROOT    := asm
TEST_ROOT   := test
PODI_ROOT   := podi


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
HEXDUMP := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/hexdump.py

asm: venv $(ASM_BINS)

$(BUILD_ROOT)/%.out: %.asm $(ASM_WRAPPER) $(VENV)
	@mkdir -p $(@D)
	$(AS) -o $@ $<
	$(OBJDUMP) $@ > $@.txt
	$(HEXDUMP) --lo $@.lo.hex --hi $@.hi.hex $@

.PHONY: asm


# Lint the design using verilator.
SV_SOURCES := $(wildcard $(SOURCE_ROOT)/*.sv $(TEST_ROOT)/*.sv)
SV_HEADERS := $(wildcard $(SOURCE_ROOT)/*.svh $(TEST_ROOT)/*.svh)

lint: $(SV_SOURCES) $(SV_HEADERS)
	verilator -Wall --lint-only -Wno-MULTITOP -I$(SOURCE_ROOT) $(SV_SOURCES)

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


# Build the podi executable for controlling the chip from a Pi Pico.
PODI_BUILD := $(BUILD_ROOT)/$(PODI_ROOT)
PODI_UF2   := $(PODI_BUILD)/$(PODI).uf2

PODI_PORT ?= /dev/tty.usbmodem1301
PODI_BAUD ?= 115200

PODI := . $(VENV_ACTIVATE) && $(PYTHON) $(SCRIPT_ROOT)/podi.py

$(PODI_UF2):
	@mkdir -p $(PODI_BUILD)
	cmake -S $(PODI_ROOT) -B $(PODI_BUILD) -DPICO_BOARD=pico
	cmake --build $(PODI_BUILD) --target podi

podi: $(PODI_UF2)

run_podi: $(SIM_TEST) podi
	$(PODI) $< --port $(PODI_PORT) --baud $(PODI_BAUD)

.PHONY: podi run_podi


# FPGA testing. Memories are initialised using $readmemh with the paths
# specified by preprocessor defines. For icarus and quartus we need to pass the
# define to sv2v and generate a separate bench file with the appropriate path,
# while verilator can just take a +define arg.
FPGA_BENCH_SV := $(TEST_ROOT)/idli_tb_fpga_m.sv
FPGA_BENCH_V  := $(BUILD_ROOT)/sv2v/test/idli_tb_fpga_m.spec.v

FPGA_MEM_LO ?= $(SIM_TEST).lo.hex
FPGA_MEM_HI ?= $(SIM_TEST).hi.hex

FPGA_SV2V_ARGS := -Didli_tb_mem_lo_d=\"$(abspath $(FPGA_MEM_LO))\"
FPGA_SV2V_ARGS += -Didli_tb_mem_hi_d=\"$(abspath $(FPGA_MEM_HI))\"

FPGA_EXTRA_SOURCES := ../$(TEST_ROOT)/idli_sqi_mem_m.sv

FPGA_VERI_EXTRA_ARGS := +define+idli_tb_mem_lo_d=\"$(abspath $(FPGA_MEM_LO))\"
FPGA_VERI_EXTRA_ARGS += +define+idli_tb_mem_hi_d=\"$(abspath $(FPGA_MEM_HI))\"

FPGA_VERI_ARGS := RTL_SIM=verilator
FPGA_VERI_ARGS += BENCH_SOURCE=../$(FPGA_BENCH_SV)
FPGA_VERI_ARGS += EXTRA_EXTRA_ARGS='$(FPGA_VERI_EXTRA_ARGS)'
FPGA_VERI_ARGS += EXTRA_SOURCES=$(FPGA_EXTRA_SOURCES)

FPGA_ICARUS_ARGS := RTL_SIM=icarus
FPGA_ICARUS_ARGS += BENCH_SOURCE=../$(FPGA_BENCH_V)
FPGA_ICARUS_ARGS += TOPLEVEL=idli_tb_fpga_m
FPGA_ICARUS_ARGS += EXTRA_SOURCES=$(FPGA_EXTRA_SOURCES)

$(FPGA_MEM_LO): $(SIM_TEST)
$(FPGA_MEM_HI): $(SIM_TEST)

$(FPGA_BENCH_V): $(FPGA_BENCH_SV) $(FPGA_MEM_LO) $(FPGA_MEM_HI) FORCE
	@mkdir -p $(@D)
	$(SV2V) $< $(FPGA_SV2V_ARGS) > $@

FORCE:

run_fpga_veri: $(SIM_TEST) $(VENV) lint $(FPGA_BENCH_SV)
	. $(VENV_ACTIVATE) && make -C $(TEST_ROOT) $(FPGA_VERI_ARGS)
	$(VERI_DEBUG)

run_fpga_icarus: $(SIM_TEST) $(VENV) sv2v $(FPGA_BENCH_V)
	. $(VENV_ACTIVATE) && make -C $(TEST_ROOT) $(FPGA_ICARUS_ARGS)
	$(ICARUS_DEBUG)

.PHONY: run_fpga_veri run_fpga_icarus
