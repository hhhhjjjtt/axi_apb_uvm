class apb_agent extends uvm_agent;

    `uvm_component_utils(apb_agent)

    apb_responder responder;
    apb_monitor   monitor;

    function new(string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor = apb_monitor::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE)
            responder = apb_responder::type_id::create("responder", this);
    endfunction

endclass
