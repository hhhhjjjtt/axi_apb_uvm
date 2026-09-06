class bridge_env extends uvm_env;

    `uvm_component_utils(bridge_env)

    axil_agent        axil_agent_h;
    apb_agent         apb_agent_h;
    bridge_scoreboard scoreboard;
    bridge_coverage   coverage;

    function new(string name = "bridge_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axil_agent_h = axil_agent::type_id::create("axil_agent", this);
        apb_agent_h  = apb_agent::type_id::create("apb_agent", this);
        scoreboard   = bridge_scoreboard::type_id::create("scoreboard", this);
        coverage     = bridge_coverage::type_id::create("coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        axil_agent_h.monitor.analysis_port.connect(
            scoreboard.axil_fifo.analysis_export);
        apb_agent_h.monitor.analysis_port.connect(
            scoreboard.apb_fifo.analysis_export);

        axil_agent_h.driver.analysis_port.connect(coverage.axil_imp);
        apb_agent_h.monitor.analysis_port.connect(coverage.apb_imp);
    endfunction

endclass
