class bridge_channel_test extends bridge_base_test;

    `uvm_component_utils(bridge_channel_test)

    function new(string name = "bridge_channel_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axil_channel_order_sequence seq;

        phase.raise_objection(this);
        seq = axil_channel_order_sequence::type_id::create("seq");
        seq.start(env.axil_agent_h.sequencer);
        phase.drop_objection(this);
    endtask

endclass
