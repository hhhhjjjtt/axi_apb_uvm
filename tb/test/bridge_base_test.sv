class bridge_base_test extends uvm_test;

    `uvm_component_utils(bridge_base_test)

    bridge_env env;

    function new(string name = "bridge_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = bridge_env::type_id::create("env", this);
    endfunction

endclass
