class axil_monitor extends uvm_monitor;

    `uvm_component_utils(axil_monitor)

    virtual axil_if vif;
    uvm_analysis_port #(axil_item) analysis_port;

    axil_item aw_queue[$];
    axil_item w_queue[$];
    axil_item write_queue[$];
    axil_item read_queue[$];

    function new(string name = "axil_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axil_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("AXIL_MONITOR", "Could not get axil_if from config DB")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axil_item tr;
        axil_item aw_part;
        axil_item w_part;

        forever begin
            @(vif.monitor_cb);

            if (vif.monitor_cb.S_AXI_ARESETN !== 1'b1) begin
                aw_queue.delete();
                w_queue.delete();
                write_queue.delete();
                read_queue.delete();
            end
            else begin
                if (vif.monitor_cb.S_AXI_AWVALID
                    && vif.monitor_cb.S_AXI_AWREADY) begin
                    aw_part = axil_item::type_id::create("aw_part");
                    aw_part.op   = AXIL_WRITE;
                    aw_part.addr = vif.monitor_cb.S_AXI_AWADDR;
                    aw_part.prot = vif.monitor_cb.S_AXI_AWPROT;
                    aw_queue.push_back(aw_part);
                end

                if (vif.monitor_cb.S_AXI_WVALID
                    && vif.monitor_cb.S_AXI_WREADY) begin
                    w_part = axil_item::type_id::create("w_part");
                    w_part.op    = AXIL_WRITE;
                    w_part.wdata = vif.monitor_cb.S_AXI_WDATA;
                    w_part.wstrb = vif.monitor_cb.S_AXI_WSTRB;
                    w_queue.push_back(w_part);
                end

                while ((aw_queue.size() != 0) && (w_queue.size() != 0)) begin
                    aw_part = aw_queue.pop_front();
                    w_part  = w_queue.pop_front();
                    tr = axil_item::type_id::create("observed_write");
                    tr.op    = AXIL_WRITE;
                    tr.addr  = aw_part.addr;
                    tr.prot  = aw_part.prot;
                    tr.wdata = w_part.wdata;
                    tr.wstrb = w_part.wstrb;
                    write_queue.push_back(tr);
                end

                if (vif.monitor_cb.S_AXI_ARVALID
                    && vif.monitor_cb.S_AXI_ARREADY) begin
                    tr = axil_item::type_id::create("observed_read");
                    tr.op   = AXIL_READ;
                    tr.addr = vif.monitor_cb.S_AXI_ARADDR;
                    tr.prot = vif.monitor_cb.S_AXI_ARPROT;
                    read_queue.push_back(tr);
                end

                if (vif.monitor_cb.S_AXI_BVALID
                    && vif.monitor_cb.S_AXI_BREADY) begin
                    if (write_queue.size() == 0) begin
                        `uvm_error("AXIL_MONITOR",
                                   "Observed B response without a complete write request")
                    end
                    else begin
                        tr = write_queue.pop_front();
                        tr.resp = vif.monitor_cb.S_AXI_BRESP;
                        analysis_port.write(tr);
                    end
                end

                if (vif.monitor_cb.S_AXI_RVALID
                    && vif.monitor_cb.S_AXI_RREADY) begin
                    if (read_queue.size() == 0) begin
                        `uvm_error("AXIL_MONITOR",
                                   "Observed R response without a read request")
                    end
                    else begin
                        tr = read_queue.pop_front();
                        tr.rdata = vif.monitor_cb.S_AXI_RDATA;
                        tr.resp  = vif.monitor_cb.S_AXI_RRESP;
                        analysis_port.write(tr);
                    end
                end
            end
        end
    endtask

endclass
