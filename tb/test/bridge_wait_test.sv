class bridge_wait_test extends bridge_base_test;

    `uvm_component_utils(bridge_wait_test)

    function new(string name = "bridge_wait_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        uvm_config_db#(int unsigned)::set(
            this, "env.apb_agent.responder", "max_wait_cycles", 5);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        axil_random_sequence seq;

        phase.raise_objection(this);
        seq = axil_random_sequence::type_id::create("seq");
        seq.num_items = 50;
        seq.start(env.axil_agent_h.sequencer);
        phase.drop_objection(this);
    endtask

endclass
