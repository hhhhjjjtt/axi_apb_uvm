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
COVERAGE      ?= 1
CM            ?= line+cond+branch+tgl+fsm

VCS           ?= vcs
VERDI         ?= verdi
URG           ?= urg

COMPILE_COV_DIR := $(BUILD_DIR)/coverage/compile.vdb
RUN_COV_DIR     := $(BUILD_DIR)/coverage/$(TEST)_$(SEED).vdb
MERGED_COV_DIR  := $(BUILD_DIR)/coverage/merged_$(TEST)_$(SEED).vdb
COV_REPORT_DIR  := $(BUILD_DIR)/coverage/report_$(TEST)_$(SEED)
RUN_LOG         := $(BUILD_DIR)/run_$(TEST).log

VCS_FLAGS := -full64 -sverilog -ntb_opts $(UVM_VERSION) \
	-timescale=1ns/1ps -top $(TOP) -f filelist.f \
	-Mdir=$(BUILD_DIR)/csrc -o $(SIMV) -l $(BUILD_DIR)/compile.log

ifeq ($(FSDB),1)
VCS_FLAGS += +define+FSDB -debug_access+all -kdb
RUN_FLAGS += +FSDB_FILE=$(BUILD_DIR)/$(WAVE)
endif

ifeq ($(COVERAGE),1)
VCS_FLAGS += -cm $(CM) -cm_dir $(COMPILE_COV_DIR) \
	-cm_hier coverage_hier.cfg
RUN_FLAGS += -cm $(CM) -cm_dir $(RUN_COV_DIR) \
	-cm_name $(TEST)_$(SEED)
endif

ifeq ($(SEED),random)
SEED_FLAG := +ntb_random_seed_automatic
else
SEED_FLAG := +ntb_random_seed=$(SEED)
endif

.PHONY: all compile run coverage verdi verdi-cov clean help check-verdi

all: run

help:
	@echo "make run TEST=bridge_basic_test SEED=123"
	@echo "make coverage TEST=bridge_random_test SEED=123"
	@echo "make verdi       # waveform debug"
	@echo "make verdi-cov   # coverage viewer"
	@echo "make clean"
	@echo "Set FSDB=0 to compile and run without Verdi waveform dumping."
	@echo "Set COVERAGE=0 to disable VCS coverage collection."

check-verdi:
ifeq ($(FSDB),1)
	@test -n "$(VERDI_HOME)" || \
		(echo "ERROR: VERDI_HOME is not set. Set it or use FSDB=0."; exit 1)
endif

compile: check-verdi
	@mkdir -p $(BUILD_DIR)/coverage
ifeq ($(COVERAGE),1)
	@rm -rf $(COMPILE_COV_DIR)
endif
	$(VCS) $(VCS_FLAGS)

run: compile
ifeq ($(COVERAGE),1)
	@rm -rf $(RUN_COV_DIR)
endif
	$(SIMV) \
		+UVM_TESTNAME=$(TEST) $(SEED_FLAG) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) $(RUN_FLAGS) \
		-l $(RUN_LOG)

coverage: run
ifeq ($(COVERAGE),1)
	@rm -rf $(MERGED_COV_DIR) $(COV_REPORT_DIR)
	$(URG) -dir $(COMPILE_COV_DIR) -dir $(RUN_COV_DIR) \
		-dbname $(MERGED_COV_DIR) -report $(COV_REPORT_DIR) \
		-format both -show tests -show ratios
	@echo "Coverage report: $(COV_REPORT_DIR)/dashboard.html"
else
	@echo "ERROR: coverage target requires COVERAGE=1."
	@exit 1
endif

verdi: check-verdi
	@test -d "$(BUILD_DIR)/simv.daidir" || \
		(echo "ERROR: compile the design first with 'make -f Makefile.vcs compile'."; exit 1)
	@test -f "$(BUILD_DIR)/$(WAVE)" || \
		(echo "ERROR: run the simulation first; $(BUILD_DIR)/$(WAVE) is missing."; exit 1)
	$(VERDI) -dbdir $(BUILD_DIR)/simv.daidir \
		-ssf $(BUILD_DIR)/$(WAVE) -top $(TOP)

verdi-cov: coverage
	$(VERDI) -cov -covdir $(MERGED_COV_DIR)

clean:
	rm -rf $(BUILD_DIR) csrc simv simv.daidir ucli.key vc_hdrs.h \
		DVEfiles novas.conf novas.rc verdiLog
