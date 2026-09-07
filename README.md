# AXI-Lite to APB UVM Testbench

This project verifies the ZipCPU `axil2apb` bridge using a UVM AXI-Lite master,
a reactive APB slave model, protocol assertions, functional coverage, and an
end-to-end translation scoreboard.

Available tests are:

- `bridge_basic_test`
- `bridge_channel_test`
- `bridge_mapping_test`
- `bridge_wait_test`
- `bridge_error_test`
- `bridge_random_test`

## Running with VCS and Verdi

Run these commands from the `sim` directory on a Linux machine with Synopsys
VCS and Verdi installed:

```sh
export VERDI_HOME=/path/to/verdi
make TEST=bridge_basic_test SEED=12345
make verdi
```

The first command compiles the testbench, runs the selected UVM test, and
writes `sim/build/vcs/waves.fsdb`. The second command opens that waveform and
the VCS design database in Verdi.

The VCS flow uses the simulator's built-in UVM 1.2 library. Override the
version if required by the installed VCS release:

```sh
make UVM_VERSION=uvm-1.1 TEST=bridge_basic_test
```

To run without FSDB/Verdi integration:

```sh
make FSDB=0 TEST=bridge_random_test SEED=random
```

Useful VCS variables are `TEST`, `SEED`, `UVM_VERBOSITY`, `BUILD_DIR`, `WAVE`,
`COVERAGE`, `CM`, and `VERDI_PLI_DIR`. If the Verdi PLI files are not under the default
`$VERDI_HOME/share/PLI/VCS/LINUX64` location, set `VERDI_PLI_DIR` explicitly.

## Coverage reports

Every run prints the AXI and APB functional-coverage percentages in the UVM
log under the `BRIDGE_COV` report ID. To generate a persistent VCS coverage
database and an HTML/text report, run:

```sh
cd sim
make coverage TEST=bridge_random_test SEED=12345
```

The HTML report is written under
`build/vcs/coverage/report_bridge_random_test_12345/dashboard.html`. It
contains the SystemVerilog covergroups as well as line, condition, branch,
toggle, and FSM code coverage. Code coverage is restricted to `tb_top.dut` by
`sim/coverage_hier.cfg`, so UVM testbench implementation code does not inflate
the DUT result.

Open the same results in Verdi Coverage with:

```sh
make verdi-cov TEST=bridge_random_test SEED=12345
```

Use a fixed numeric seed when comparing or archiving reports. Setting
`SEED=random` reuses a directory containing `random` in its name on every run.

## Current scope

The DUT is configured for 32-bit data, 32-bit addresses, and
`OPT_OUTGOING_SKIDBUFFER=0`. The AXI driver issues one complete operation at a
time. Concurrent AXI read/write arbitration, reset during active transfers,
and the `OPT_OUTGOING_SKIDBUFFER=1` configuration remain future extensions.
