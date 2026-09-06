class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;
    uvm_analysis_port #(apb_item) analysis_port;

    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("APB_MONITOR", "Could not get apb_if from config DB")
        end
    endfunction

    task run_phase(uvm_phase phase);
        apb_item tr;
        bit transfer_active = 1'b0;

        forever begin
            @(vif.monitor_cb);

            if (vif.monitor_cb.PRESETN !== 1'b1) begin
                transfer_active = 1'b0;
                tr = null;
            end
            else begin
                if (vif.monitor_cb.M_APB_PSEL
                    && !vif.monitor_cb.M_APB_PENABLE) begin
                    tr = apb_item::type_id::create("tr");
                    tr.write       = vif.monitor_cb.M_APB_PWRITE;
                    tr.addr        = vif.monitor_cb.M_APB_PADDR;
                    tr.wdata       = vif.monitor_cb.M_APB_PWDATA;
                    tr.wstrb       = vif.monitor_cb.M_APB_PWSTRB;
                    tr.prot        = vif.monitor_cb.M_APB_PPROT;
                    tr.wait_cycles = 0;
                    transfer_active = 1'b1;
                end

                if (transfer_active
                    && vif.monitor_cb.M_APB_PSEL
                    && vif.monitor_cb.M_APB_PENABLE) begin
                    if (vif.monitor_cb.M_APB_PREADY) begin
                        tr.rdata  = vif.monitor_cb.M_APB_PRDATA;
                        tr.slverr = vif.monitor_cb.M_APB_PSLVERR;
                        analysis_port.write(tr);
                        transfer_active = 1'b0;
                        tr = null;
                    end
                    else begin
                        tr.wait_cycles++;
                    end
                end
            end
        end
    endtask

endclass
