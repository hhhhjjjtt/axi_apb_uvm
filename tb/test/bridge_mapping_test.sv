class bridge_mapping_test extends bridge_base_test;

    `uvm_component_utils(bridge_mapping_test)

    function new(string name = "bridge_mapping_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axil_mapping_sequence seq;

        phase.raise_objection(this);
        seq = axil_mapping_sequence::type_id::create("seq");
        seq.start(env.axil_agent_h.sequencer);
        phase.drop_objection(this);
    endtask

endclass
