# AXI-Lite to APB UVM Testbench

This project verifies the ZipCPU `axil2apb` bridge using a UVM AXI-Lite master,
a reactive APB slave model, protocol assertions, functional coverage, and an
end-to-end translation scoreboard.

## Running with Questa

From the `sim` directory:

```sh
make TEST=bridge_basic_test
make TEST=bridge_random_test SEED=12345
```

If the precompiled UVM library has a different name, override it, for example:

```sh
make TEST=bridge_basic_test UVM_LIB=mtiUvm
```

Available tests are:

- `bridge_basic_test`
- `bridge_channel_test`
- `bridge_mapping_test`
- `bridge_wait_test`
- `bridge_error_test`
- `bridge_random_test`

The simulator must provide a compiled UVM package. The supplied Makefile uses
the Questa commands `vlib`, `vlog`, and `vsim`.

## Running with VCS and Verdi

Run these commands from the `sim` directory on a Linux machine with Synopsys
VCS and Verdi installed:

```sh
export VERDI_HOME=/path/to/verdi
make -f Makefile.vcs TEST=bridge_basic_test SEED=12345
make -f Makefile.vcs verdi
```

The first command compiles the testbench, runs the selected UVM test, and
writes `sim/build/vcs/waves.fsdb`. The second command opens that waveform and
the VCS design database in Verdi.

The VCS flow uses the simulator's built-in UVM 1.2 library. Override the
version if required by the installed VCS release:

```sh
make -f Makefile.vcs UVM_VERSION=uvm-1.1 TEST=bridge_basic_test
```

To run without FSDB/Verdi integration:

```sh
make -f Makefile.vcs FSDB=0 TEST=bridge_random_test SEED=random
```

Useful VCS variables are `TEST`, `SEED`, `UVM_VERBOSITY`, `BUILD_DIR`, `WAVE`,
and `VERDI_PLI_DIR`. If the Verdi PLI files are not under the default
`$VERDI_HOME/share/PLI/VCS/LINUX64` location, set `VERDI_PLI_DIR` explicitly.

## Current scope

The DUT is configured for 32-bit data, 32-bit addresses, and
`OPT_OUTGOING_SKIDBUFFER=0`. The AXI driver issues one complete operation at a
time. See `outline.md` for the verification architecture and planned future
extensions.
