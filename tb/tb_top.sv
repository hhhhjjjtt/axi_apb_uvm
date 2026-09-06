`timescale 1ns/1ps
`default_nettype none

module tb_top;

    import uvm_pkg::*;
    import bridge_pkg::*;

    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;

    logic clk = 1'b0;

    always #5 clk = ~clk;

    axil_if #(
        .C_AXI_ADDR_WIDTH(ADDR_WIDTH),
        .C_AXI_DATA_WIDTH(DATA_WIDTH)
    ) axil_vif (
        .S_AXI_ACLK(clk)
    );

    apb_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) apb_vif (
        .PCLK(clk),
        .PRESETN(axil_vif.S_AXI_ARESETN)
    );

    axil2apb #(
        .C_AXI_ADDR_WIDTH(ADDR_WIDTH),
        .C_AXI_DATA_WIDTH(DATA_WIDTH),
        .OPT_OUTGOING_SKIDBUFFER(1'b0)
    ) dut (
        .S_AXI_ACLK   (clk),
        .S_AXI_ARESETN(axil_vif.S_AXI_ARESETN),

        .S_AXI_AWVALID(axil_vif.S_AXI_AWVALID),
        .S_AXI_AWREADY(axil_vif.S_AXI_AWREADY),
        .S_AXI_AWADDR (axil_vif.S_AXI_AWADDR),
        .S_AXI_AWPROT (axil_vif.S_AXI_AWPROT),

        .S_AXI_WVALID (axil_vif.S_AXI_WVALID),
        .S_AXI_WREADY (axil_vif.S_AXI_WREADY),
        .S_AXI_WDATA  (axil_vif.S_AXI_WDATA),
        .S_AXI_WSTRB  (axil_vif.S_AXI_WSTRB),

        .S_AXI_BVALID (axil_vif.S_AXI_BVALID),
        .S_AXI_BREADY (axil_vif.S_AXI_BREADY),
        .S_AXI_BRESP  (axil_vif.S_AXI_BRESP),

        .S_AXI_ARVALID(axil_vif.S_AXI_ARVALID),
        .S_AXI_ARREADY(axil_vif.S_AXI_ARREADY),
        .S_AXI_ARADDR (axil_vif.S_AXI_ARADDR),
        .S_AXI_ARPROT (axil_vif.S_AXI_ARPROT),

        .S_AXI_RVALID (axil_vif.S_AXI_RVALID),
        .S_AXI_RREADY (axil_vif.S_AXI_RREADY),
        .S_AXI_RDATA  (axil_vif.S_AXI_RDATA),
        .S_AXI_RRESP  (axil_vif.S_AXI_RRESP),

        .M_APB_PSEL   (apb_vif.M_APB_PSEL),
        .M_APB_PENABLE(apb_vif.M_APB_PENABLE),
        .M_APB_PREADY (apb_vif.M_APB_PREADY),
        .M_APB_PADDR  (apb_vif.M_APB_PADDR),
        .M_APB_PWRITE (apb_vif.M_APB_PWRITE),
        .M_APB_PWDATA (apb_vif.M_APB_PWDATA),
        .M_APB_PWSTRB (apb_vif.M_APB_PWSTRB),
        .M_APB_PPROT  (apb_vif.M_APB_PPROT),
        .M_APB_PRDATA (apb_vif.M_APB_PRDATA),
        .M_APB_PSLVERR(apb_vif.M_APB_PSLVERR)
    );

    initial begin
        axil_vif.S_AXI_ARESETN = 1'b0;
        repeat (5) @(posedge clk);
        axil_vif.S_AXI_ARESETN <= 1'b1;
    end

    initial begin : start_uvm
        string test_name;

        uvm_config_db#(virtual axil_if)::set(
            null, "uvm_test_top.env.axil_agent*", "vif", axil_vif);
        uvm_config_db#(virtual apb_if)::set(
            null, "uvm_test_top.env.apb_agent*", "vif", apb_vif);

        uvm_root::get().set_timeout(1ms, 1'b1);
        if (!$value$plusargs("UVM_TESTNAME=%s", test_name))
            test_name = "bridge_basic_test";
        run_test(test_name);
    end

`ifdef FSDB
    initial begin : dump_fsdb
        string fsdb_file;

        if (!$value$plusargs("FSDB_FILE=%s", fsdb_file))
            fsdb_file = "waves.fsdb";

        $fsdbDumpfile(fsdb_file);
        $fsdbDumpvars(0, tb_top, "+all");
    end
`endif

endmodule

`default_nettype wire
