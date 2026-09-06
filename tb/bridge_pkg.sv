package bridge_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "seq_item/axil_item.sv"
    `include "seq_item/apb_item.sv"

    `include "agent/axil_agent/axil_sequencer.sv"
    `include "agent/axil_agent/axil_driver.sv"
    `include "agent/axil_agent/axil_monitor.sv"
    `include "agent/axil_agent/axil_agent.sv"

    `include "agent/apb_agent/apb_responder.sv"
    `include "agent/apb_agent/apb_monitor.sv"
    `include "agent/apb_agent/apb_agent.sv"

    `include "env/bridge_scoreboard.sv"
    `include "env/bridge_coverage.sv"
    `include "env/bridge_env.sv"

    `include "seq/axil_sequence.sv"

    `include "test/bridge_base_test.sv"
    `include "test/bridge_basic_test.sv"
    `include "test/bridge_channel_test.sv"
    `include "test/bridge_mapping_test.sv"
    `include "test/bridge_wait_test.sv"
    `include "test/bridge_error_test.sv"
    `include "test/bridge_random_test.sv"

endpackage
