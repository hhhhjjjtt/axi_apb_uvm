class axil_agent extends uvm_agent;

    `uvm_component_utils(axil_agent)

    axil_sequencer sequencer;
    axil_driver    driver;
    axil_monitor   monitor;

    function new(string name = "axil_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor = axil_monitor::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE) begin
            sequencer = axil_sequencer::type_id::create("sequencer", this);
            driver    = axil_driver::type_id::create("driver", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
