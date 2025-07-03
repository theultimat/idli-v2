BUILD_ROOT  := build
SOURCE_ROOT := src
SCRIPT_ROOT := scripts
ASM_ROOT    := asm


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
