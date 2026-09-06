interface axil_if #(
    parameter	C_AXI_ADDR_WIDTH = 32,
    parameter	C_AXI_DATA_WIDTH = 32
) (
    input logic S_AXI_ACLK
);
    logic                               S_AXI_ARESETN;
    logic 			                    S_AXI_AWVALID;
    logic 			                    S_AXI_AWREADY;
    logic [C_AXI_ADDR_WIDTH-1:0]	    S_AXI_AWADDR;
    logic [2:0]			                S_AXI_AWPROT;
    logic 			                    S_AXI_WVALID;
    logic 			                    S_AXI_WREADY;
    logic [C_AXI_DATA_WIDTH-1 : 0]	    S_AXI_WDATA;
    logic [(C_AXI_DATA_WIDTH/8)-1:0]	S_AXI_WSTRB;
    logic 			                    S_AXI_BVALID;
    logic 			                    S_AXI_BREADY;
    logic [1:0]                         S_AXI_BRESP;
    logic 			                    S_AXI_ARVALID;
    logic 			                    S_AXI_ARREADY;
    logic [C_AXI_ADDR_WIDTH-1:0]	    S_AXI_ARADDR;
    logic [2:0]			                S_AXI_ARPROT;
    logic 			                    S_AXI_RVALID;
    logic 			                    S_AXI_RREADY;
    logic [C_AXI_DATA_WIDTH-1:0]	    S_AXI_RDATA;
    logic [1:0]			                S_AXI_RRESP;

    clocking driver_cb @(posedge S_AXI_ACLK);
        default input #1step output #0;
        input  S_AXI_ARESETN;

        output S_AXI_AWVALID;
        output S_AXI_AWADDR;
        output S_AXI_AWPROT;
        input  S_AXI_AWREADY;

        output S_AXI_WVALID;
        output S_AXI_WDATA;
        output S_AXI_WSTRB;
        input  S_AXI_WREADY;

        input  S_AXI_BVALID;
        input  S_AXI_BRESP;
        output S_AXI_BREADY;

        output S_AXI_ARVALID;
        output S_AXI_ARADDR;
        output S_AXI_ARPROT;
        input  S_AXI_ARREADY;

        input  S_AXI_RVALID;
        input  S_AXI_RDATA;
        input  S_AXI_RRESP;
        output S_AXI_RREADY;
    endclocking

    clocking monitor_cb @(posedge S_AXI_ACLK);
        default input #1step;
        input S_AXI_ARESETN;

        input S_AXI_AWVALID;
        input S_AXI_AWREADY;
        input S_AXI_AWADDR;
        input S_AXI_AWPROT;

        input S_AXI_WVALID;
        input S_AXI_WREADY;
        input S_AXI_WDATA;
        input S_AXI_WSTRB;

        input S_AXI_BVALID;
        input S_AXI_BREADY;
        input S_AXI_BRESP;

        input S_AXI_ARVALID;
        input S_AXI_ARREADY;
        input S_AXI_ARADDR;
        input S_AXI_ARPROT;

        input S_AXI_RVALID;
        input S_AXI_RREADY;
        input S_AXI_RDATA;
        input S_AXI_RRESP;
    endclocking

    modport DRIVER (
        clocking driver_cb,
        input S_AXI_ACLK
    );

    modport MONITOR (
        clocking monitor_cb,
        input S_AXI_ACLK
    );

    property p_aw_stable_while_waiting;
        @(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_AWVALID && !S_AXI_AWREADY
        |=> S_AXI_AWVALID && $stable({S_AXI_AWADDR, S_AXI_AWPROT});
    endproperty

    property p_w_stable_while_waiting;
        @(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_WVALID && !S_AXI_WREADY
        |=> S_AXI_WVALID && $stable({S_AXI_WDATA, S_AXI_WSTRB});
    endproperty

    property p_ar_stable_while_waiting;
        @(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_ARVALID && !S_AXI_ARREADY
        |=> S_AXI_ARVALID && $stable({S_AXI_ARADDR, S_AXI_ARPROT});
    endproperty

    property p_b_stable_while_waiting;
        @(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_BVALID && !S_AXI_BREADY
        |=> S_AXI_BVALID && $stable(S_AXI_BRESP);
    endproperty

    property p_r_stable_while_waiting;
        @(posedge S_AXI_ACLK) disable iff (!S_AXI_ARESETN)
        S_AXI_RVALID && !S_AXI_RREADY
        |=> S_AXI_RVALID && $stable({S_AXI_RDATA, S_AXI_RRESP});
    endproperty

    assert property (p_aw_stable_while_waiting);
    assert property (p_w_stable_while_waiting);
    assert property (p_ar_stable_while_waiting);
    assert property (p_b_stable_while_waiting);
    assert property (p_r_stable_while_waiting);

endinterface
