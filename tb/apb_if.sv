interface apb_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    input logic PCLK,
    input logic PRESETN
);

    logic                      M_APB_PSEL;
    logic                      M_APB_PENABLE;
    logic                      M_APB_PREADY;
    logic [ADDR_WIDTH-1:0]     M_APB_PADDR;
    logic                      M_APB_PWRITE;
    logic [DATA_WIDTH-1:0]     M_APB_PWDATA;
    logic [(DATA_WIDTH/8)-1:0] M_APB_PWSTRB;
    logic [2:0]                M_APB_PPROT;
    logic [DATA_WIDTH-1:0]     M_APB_PRDATA;
    logic                      M_APB_PSLVERR;

    clocking responder_cb @(posedge PCLK);
        default input #1step output #0;

        input PRESETN;
        input M_APB_PSEL;
        input M_APB_PENABLE;
        input M_APB_PADDR;
        input M_APB_PWRITE;
        input M_APB_PWDATA;
        input M_APB_PWSTRB;
        input M_APB_PPROT;

        output M_APB_PREADY;
        output M_APB_PRDATA;
        output M_APB_PSLVERR;
    endclocking

    clocking monitor_cb @(posedge PCLK);
        default input #1step;

        input PRESETN;
        input M_APB_PSEL;
        input M_APB_PENABLE;
        input M_APB_PREADY;
        input M_APB_PADDR;
        input M_APB_PWRITE;
        input M_APB_PWDATA;
        input M_APB_PWSTRB;
        input M_APB_PPROT;
        input M_APB_PRDATA;
        input M_APB_PSLVERR;
    endclocking

    modport RESPONDER (
        clocking responder_cb,
        input PCLK
    );

    modport MONITOR (
        clocking monitor_cb,
        input PCLK
    );

    property p_penable_requires_psel;
        @(posedge PCLK) disable iff (!PRESETN)
        M_APB_PENABLE |-> M_APB_PSEL;
    endproperty

    property p_setup_leads_to_access;
        @(posedge PCLK) disable iff (!PRESETN)
        M_APB_PSEL && !M_APB_PENABLE |=> M_APB_PSEL && M_APB_PENABLE;
    endproperty

    property p_control_stable_while_waiting;
        @(posedge PCLK) disable iff (!PRESETN)
        M_APB_PSEL && M_APB_PENABLE && !M_APB_PREADY
        |=> M_APB_PSEL && M_APB_PENABLE
            && $stable({M_APB_PADDR, M_APB_PWRITE, M_APB_PWDATA,
                        M_APB_PWSTRB, M_APB_PPROT});
    endproperty

    assert property (p_penable_requires_psel);
    assert property (p_setup_leads_to_access);
    assert property (p_control_stable_while_waiting);

endinterface
