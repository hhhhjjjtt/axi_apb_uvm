axil_apb_uvm/
├── rtl/
│   └── axil2apb.v
├── tb/
│   ├── axil_if.sv
│   ├── apb_if.sv
│   ├── axil_item.sv
│   ├── axil_sequence.sv
│   ├── axil_driver.sv
│   ├── axil_monitor.sv
│   ├── axil_sequencer.sv
│   ├── axil_agent.sv
│   ├── apb_driver.sv
│   ├── apb_monitor.sv
│   ├── bridge_scoreboard.sv
│   ├── bridge_env.sv
│   ├── bridge_test.sv
│   ├── bridge_pkg.sv
│   └── tb_top.sv
├── sim/
│   ├── filelist.f
│   └── Makefile
└── README.md



First, inspect the RTL and specification and produce:

- A summary of the DUT interfaces, clocks, resets, parameters, and behavior
- A verification plan covering normal behavior, corner cases, errors, reset, and backpressure
- A proposed UVM topology identifying active and passive agents
- The transaction abstraction for each interface
- The scoreboard and reference-model strategy
- The assertion and functional-coverage strategy
- A proposed file and package structure
- A list of assumptions and unresolved questions

Wait for me to approve the architecture before generating implementation code.

