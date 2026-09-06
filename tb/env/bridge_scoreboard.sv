class bridge_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bridge_scoreboard)

    uvm_tlm_analysis_fifo #(axil_item) axil_fifo;
    uvm_tlm_analysis_fifo #(apb_item)  apb_fifo;

    int unsigned checked_count;
    int unsigned error_count;

    function new(string name = "bridge_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axil_fifo = new("axil_fifo", this);
        apb_fifo  = new("apb_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
        axil_item axil_tr;
        apb_item  apb_tr;

        forever begin
            // APB completes before the corresponding AXI response.
            apb_fifo.get(apb_tr);
            axil_fifo.get(axil_tr);
            compare_transfer(axil_tr, apb_tr);
        end
    endtask

    function void compare_transfer(axil_item axil_tr, apb_item apb_tr);
        bit mismatch;
        bit [31:0] expected_addr;
        bit [1:0]  expected_resp;

        mismatch    = 1'b0;
        expected_addr = {axil_tr.addr[31:2], 2'b00};
        expected_resp = {apb_tr.slverr, 1'b0};

        if ((axil_tr.op == AXIL_WRITE) != apb_tr.write) begin
            `uvm_error("BRIDGE_SB", "AXI operation does not match APB PWRITE")
            mismatch = 1'b1;
        end

        if (apb_tr.addr != expected_addr) begin
            `uvm_error("BRIDGE_SB",
                $sformatf("Address mismatch: AXI=%08h APB=%08h expected=%08h",
                          axil_tr.addr, apb_tr.addr, expected_addr))
            mismatch = 1'b1;
        end

        if (apb_tr.prot != axil_tr.prot) begin
            `uvm_error("BRIDGE_SB",
                $sformatf("Protection mismatch: AXI=%03b APB=%03b",
                          axil_tr.prot, apb_tr.prot))
            mismatch = 1'b1;
        end

        if (axil_tr.op == AXIL_WRITE) begin
            if (apb_tr.wdata != axil_tr.wdata) begin
                `uvm_error("BRIDGE_SB",
                    $sformatf("Write-data mismatch: AXI=%08h APB=%08h",
                              axil_tr.wdata, apb_tr.wdata))
                mismatch = 1'b1;
            end

            if (apb_tr.wstrb != axil_tr.wstrb) begin
                `uvm_error("BRIDGE_SB",
                    $sformatf("Write-strobe mismatch: AXI=%04b APB=%04b",
                              axil_tr.wstrb, apb_tr.wstrb))
                mismatch = 1'b1;
            end
        end
        else if (axil_tr.rdata != apb_tr.rdata) begin
            `uvm_error("BRIDGE_SB",
                $sformatf("Read-data mismatch: AXI=%08h APB=%08h",
                          axil_tr.rdata, apb_tr.rdata))
            mismatch = 1'b1;
        end

        if (axil_tr.resp != expected_resp) begin
            `uvm_error("BRIDGE_SB",
                $sformatf("Response mismatch: AXI=%02b expected=%02b",
                          axil_tr.resp, expected_resp))
            mismatch = 1'b1;
        end

        checked_count++;
        if (mismatch)
            error_count++;
        else begin
            `uvm_info("BRIDGE_SB",
                $sformatf("Matched %s transfer at address %08h",
                          apb_tr.write ? "write" : "read", apb_tr.addr),
                UVM_HIGH)
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        if ((axil_fifo.used() != 0) || (apb_fifo.used() != 0)) begin
            `uvm_error("BRIDGE_SB",
                $sformatf("Unmatched transactions remain: AXI=%0d APB=%0d",
                          axil_fifo.used(), apb_fifo.used()))
        end

        if (checked_count == 0)
            `uvm_error("BRIDGE_SB", "No completed transfers were checked")
        else if (error_count == 0)
            `uvm_info("BRIDGE_SB",
                $sformatf("PASS: checked %0d transfers", checked_count),
                UVM_LOW)
        else
            `uvm_error("BRIDGE_SB",
                $sformatf("FAIL: %0d of %0d transfers mismatched",
                          error_count, checked_count))
    endfunction

endclass
