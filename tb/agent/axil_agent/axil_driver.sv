class axil_driver extends uvm_driver #(axil_item);
    
    `uvm_component_utils(axil_driver)
    
    virtual axil_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axil_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Didn't get handle to virtual interface")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axil_item req;

        drive_idle();
        wait_for_reset();

        forever begin
            seq_item_port.get_next_item(req);
            
            case (req.op)
                AXIL_WRITE: drive_write(req);
                AXIL_READ:  drive_read(req);
            endcase
            
            seq_item_port.item_done();
        end
    endtask

    task drive_idle();
        vif.driver_cb.S_AXI_AWVALID <= 1'b0;
        vif.driver_cb.S_AXI_AWADDR  <= '0;
        vif.driver_cb.S_AXI_AWPROT  <= '0;
        vif.driver_cb.S_AXI_WVALID  <= 1'b0;
        vif.driver_cb.S_AXI_WDATA   <= '0;
        vif.driver_cb.S_AXI_WSTRB   <= '0;
        vif.driver_cb.S_AXI_BREADY  <= 1'b0;
        vif.driver_cb.S_AXI_ARVALID <= 1'b0;
        vif.driver_cb.S_AXI_ARADDR  <= '0;
        vif.driver_cb.S_AXI_ARPROT  <= '0;
        vif.driver_cb.S_AXI_RREADY  <= 1'b0;
    endtask
    
    task wait_for_reset();
        while (vif.driver_cb.S_AXI_ARESETN !== 1'b1) begin
            @(vif.driver_cb);
        end
    endtask

    task drive_write(axil_item req);
        @(vif.driver_cb);

        fork
            begin: aw_channel
                repeat (req.aw_delay) begin
                    @(vif.driver_cb);
                end

                vif.driver_cb.S_AXI_AWVALID  <= 1'b1;
                vif.driver_cb.S_AXI_AWADDR  <= req.addr;
                vif.driver_cb.S_AXI_AWPROT  <= req.prot;

                do
                    @(vif.driver_cb);
                while (vif.driver_cb.S_AXI_AWREADY !== 1'b1);

                vif.driver_cb.S_AXI_AWVALID <= 1'b0;
            end
            begin: w_channel
                repeat (req.w_delay) begin
                    @(vif.driver_cb);
                end

                vif.driver_cb.S_AXI_WVALID  <= 1'b1;
                vif.driver_cb.S_AXI_WDATA   <= req.wdata;
                vif.driver_cb.S_AXI_WSTRB   <= req.wstrb;

                do
                    @(vif.driver_cb);
                while (vif.driver_cb.S_AXI_WREADY !== 1'b1);

                vif.driver_cb.S_AXI_WVALID  <= 1'b0;
            end
        join
        
        // wait for write to respond (b channel)
        while (vif.driver_cb.S_AXI_BVALID !== 1'b1) begin
            @(vif.driver_cb);
        end

        // random backpressure
        repeat (req.response_ready_delay) begin
            @(vif.driver_cb);
        end
        vif.driver_cb.S_AXI_BREADY <= 1'b1;

        @(vif.driver_cb);
        req.resp = vif.driver_cb.S_AXI_BRESP;
        vif.driver_cb.S_AXI_BREADY <= 1'b0;
    endtask

    task drive_read(axil_item req);
        @(vif.driver_cb);

        repeat (req.ar_delay) begin
            @(vif.driver_cb);
        end

        vif.driver_cb.S_AXI_ARVALID <= 1'b1;
        vif.driver_cb.S_AXI_ARADDR  <= req.addr;
        vif.driver_cb.S_AXI_ARPROT  <= req.prot;

        do
            @(vif.driver_cb);
        while (vif.driver_cb.S_AXI_ARREADY !== 1'b1);

        vif.driver_cb.S_AXI_ARVALID <= 1'b0;

        // wait for read data
        while (vif.driver_cb.S_AXI_RVALID !== 1'b1) begin
            @(vif.driver_cb);
        end

        // random backpressure
        repeat (req.response_ready_delay) begin
            @(vif.driver_cb);
        end
        vif.driver_cb.S_AXI_RREADY <= 1'b1;

        @(vif.driver_cb);
        req.rdata = vif.driver_cb.S_AXI_RDATA;
        req.resp  = vif.driver_cb.S_AXI_RRESP;
        vif.driver_cb.S_AXI_RREADY <= 1'b0;
    endtask

endclass
