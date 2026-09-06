`uvm_analysis_imp_decl(_axil_cov)
`uvm_analysis_imp_decl(_apb_cov)

class bridge_coverage extends uvm_component;

    `uvm_component_utils(bridge_coverage)

    uvm_analysis_imp_axil_cov #(axil_item, bridge_coverage) axil_imp;
    uvm_analysis_imp_apb_cov  #(apb_item,  bridge_coverage) apb_imp;

    axil_op_e   sampled_op;
    bit [2:0]   sampled_prot;
    bit [3:0]   sampled_wstrb;
    bit [1:0]   sampled_resp;
    int unsigned sampled_aw_delay;
    int unsigned sampled_w_delay;
    int unsigned sampled_ar_delay;
    int unsigned sampled_ready_delay;

    bit          sampled_apb_write;
    bit          sampled_apb_error;
    int unsigned sampled_apb_wait;

    covergroup axil_cg;
        option.per_instance = 1;

        operation: coverpoint sampled_op;
        protection: coverpoint sampled_prot;
        response: coverpoint sampled_resp {
            bins okay   = {2'b00};
            bins slverr = {2'b10};
            bins other  = default;
        }
        strobes: coverpoint sampled_wstrb iff (sampled_op == AXIL_WRITE) {
            bins none    = {4'b0000};
            bins full    = {4'b1111};
            bins partial = default;
        }
        aw_delay: coverpoint sampled_aw_delay {
            bins zero  = {0};
            bins short = {[1:2]};
            bins long  = {[3:5]};
        }
        w_delay: coverpoint sampled_w_delay {
            bins zero  = {0};
            bins short = {[1:2]};
            bins long  = {[3:5]};
        }
        ar_delay: coverpoint sampled_ar_delay {
            bins zero  = {0};
            bins short = {[1:2]};
            bins long  = {[3:5]};
        }
        ready_delay: coverpoint sampled_ready_delay {
            bins zero  = {0};
            bins short = {[1:2]};
            bins long  = {[3:5]};
        }

        operation_x_response: cross operation, response;
    endgroup

    covergroup apb_cg;
        option.per_instance = 1;

        direction: coverpoint sampled_apb_write;
        error: coverpoint sampled_apb_error;
        wait_states: coverpoint sampled_apb_wait {
            bins zero  = {0};
            bins short = {[1:2]};
            bins long  = {[3:$]};
        }

        direction_x_error: cross direction, error;
        direction_x_wait:  cross direction, wait_states;
    endgroup

    function new(string name = "bridge_coverage",
                 uvm_component parent = null);
        super.new(name, parent);
        axil_cg = new();
        apb_cg  = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axil_imp = new("axil_imp", this);
        apb_imp  = new("apb_imp", this);
    endfunction

    function void write_axil_cov(axil_item tr);
        sampled_op          = tr.op;
        sampled_prot        = tr.prot;
        sampled_wstrb       = tr.wstrb;
        sampled_resp        = tr.resp;
        sampled_aw_delay    = tr.aw_delay;
        sampled_w_delay     = tr.w_delay;
        sampled_ar_delay    = tr.ar_delay;
        sampled_ready_delay = tr.response_ready_delay;
        axil_cg.sample();
    endfunction

    function void write_apb_cov(apb_item tr);
        sampled_apb_write = tr.write;
        sampled_apb_error = tr.slverr;
        sampled_apb_wait  = tr.wait_cycles;
        apb_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("BRIDGE_COV",
            $sformatf("AXI coverage=%0.2f%% APB coverage=%0.2f%%",
                      axil_cg.get_inst_coverage(),
                      apb_cg.get_inst_coverage()),
            UVM_LOW)
    endfunction

endclass
