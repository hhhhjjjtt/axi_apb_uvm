SHELL := /bin/bash

TEST          ?= bridge_basic_test
SEED          ?= random
UVM_VERSION   ?= uvm-1.2
UVM_VERBOSITY ?= UVM_MEDIUM
TOP           ?= tb_top
BUILD_DIR     ?= build/vcs
SIMV          := $(BUILD_DIR)/simv
WAVE          ?= waves.fsdb
FSDB          ?= 1

VCS           ?= vcs
VERDI         ?= verdi
VERDI_PLI_DIR ?= $(VERDI_HOME)/share/PLI/VCS/LINUX64

VCS_FLAGS := -full64 -sverilog -ntb_opts $(UVM_VERSION) \
	-timescale=1ns/1ps -top $(TOP) -f filelist.f \
	-Mdir=$(BUILD_DIR)/csrc -o $(SIMV) -l $(BUILD_DIR)/compile.log

ifeq ($(FSDB),1)
VCS_FLAGS += +define+FSDB -debug_access+all -kdb \
	-P $(VERDI_PLI_DIR)/novas.tab $(VERDI_PLI_DIR)/pli.a
RUN_FLAGS += +FSDB_FILE=$(WAVE)
endif

ifeq ($(SEED),random)
SEED_FLAG := +ntb_random_seed_automatic
else
SEED_FLAG := +ntb_random_seed=$(SEED)
endif

.PHONY: all compile run verdi clean help check-verdi

all: run

help:
	@echo "make -f Makefile.vcs run TEST=bridge_basic_test SEED=123"
	@echo "make -f Makefile.vcs verdi"
	@echo "make -f Makefile.vcs clean"
	@echo "Set FSDB=0 to compile and run without Verdi waveform dumping."

check-verdi:
ifeq ($(FSDB),1)
	@test -n "$(VERDI_HOME)" || \
		(echo "ERROR: VERDI_HOME is not set. Set it or use FSDB=0."; exit 1)
	@test -f "$(VERDI_PLI_DIR)/novas.tab" || \
		(echo "ERROR: novas.tab not found in $(VERDI_PLI_DIR)."; exit 1)
	@test -f "$(VERDI_PLI_DIR)/pli.a" || \
		(echo "ERROR: pli.a not found in $(VERDI_PLI_DIR)."; exit 1)
endif

compile: check-verdi
	@mkdir -p $(BUILD_DIR)
	$(VCS) $(VCS_FLAGS)

run: compile
	cd $(BUILD_DIR) && ./simv \
		+UVM_TESTNAME=$(TEST) $(SEED_FLAG) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) $(RUN_FLAGS) \
		-l run_$(TEST).log

verdi: check-verdi
	@test -d "$(BUILD_DIR)/simv.daidir" || \
		(echo "ERROR: compile the design first with 'make -f Makefile.vcs compile'."; exit 1)
	@test -f "$(BUILD_DIR)/$(WAVE)" || \
		(echo "ERROR: run the simulation first; $(BUILD_DIR)/$(WAVE) is missing."; exit 1)
	$(VERDI) -dbdir $(BUILD_DIR)/simv.daidir \
		-ssf $(BUILD_DIR)/$(WAVE) -top $(TOP)

clean:
	rm -rf $(BUILD_DIR) csrc simv simv.daidir ucli.key vc_hdrs.h \
		DVEfiles novas.conf novas.rc verdiLog
