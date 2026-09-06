class apb_responder extends uvm_component;

    `uvm_component_utils(apb_responder)

    virtual apb_if vif;

    int unsigned max_wait_cycles = 0;
    int unsigned error_percent   = 0;

    bit [31:0] memory [bit [31:0]];

    function new(string name = "apb_responder", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("APB_RESPONDER", "Could not get apb_if from config DB")
        end

        void'(uvm_config_db#(int unsigned)::get(
            this, "", "max_wait_cycles", max_wait_cycles));
        void'(uvm_config_db#(int unsigned)::get(
            this, "", "error_percent", error_percent));

        if (error_percent > 100) begin
            `uvm_warning("APB_RESPONDER", "error_percent limited to 100")
            error_percent = 100;
        end
    endfunction

    task run_phase(uvm_phase phase);
        drive_idle();

        forever begin
            @(vif.responder_cb);

            if (vif.responder_cb.PRESETN !== 1'b1) begin
                drive_idle();
                memory.delete();
            end
            else if (vif.responder_cb.M_APB_PSEL
                     && !vif.responder_cb.M_APB_PENABLE) begin
                respond_to_transfer();
            end
        end
    endtask

    task drive_idle();
        vif.responder_cb.M_APB_PREADY  <= 1'b0;
        vif.responder_cb.M_APB_PRDATA  <= '0;
        vif.responder_cb.M_APB_PSLVERR <= 1'b0;
    endtask

    task respond_to_transfer();
        bit        write;
        bit [31:0] addr;
        bit [31:0] wdata;
        bit [3:0]  wstrb;
        bit [31:0] read_data;
        bit [31:0] new_data;
        bit        error;
        int unsigned wait_cycles;
        int byte_index;

        write = vif.responder_cb.M_APB_PWRITE;
        addr  = vif.responder_cb.M_APB_PADDR;
        wdata = vif.responder_cb.M_APB_PWDATA;
        wstrb = vif.responder_cb.M_APB_PWSTRB;

        if (memory.exists(addr))
            read_data = memory[addr];
        else
            read_data = '0;

        wait_cycles = $urandom_range(max_wait_cycles, 0);
        error = (error_percent != 0)
                && ($urandom_range(99, 0) < error_percent);

        vif.responder_cb.M_APB_PREADY  <= 1'b0;
        vif.responder_cb.M_APB_PRDATA  <= read_data;
        vif.responder_cb.M_APB_PSLVERR <= error;

        repeat (wait_cycles) begin
            @(vif.responder_cb);
            if (vif.responder_cb.PRESETN !== 1'b1) begin
                drive_idle();
                return;
            end
        end

        vif.responder_cb.M_APB_PREADY <= 1'b1;

        do begin
            @(vif.responder_cb);
            if (vif.responder_cb.PRESETN !== 1'b1) begin
                drive_idle();
                return;
            end
        end while (!(vif.responder_cb.M_APB_PSEL
                     && vif.responder_cb.M_APB_PENABLE));

        if (write && !error) begin
            if (memory.exists(addr))
                new_data = memory[addr];
            else
                new_data = '0;

            for (byte_index = 0; byte_index < 4; byte_index++) begin
                if (wstrb[byte_index])
                    new_data[byte_index*8 +: 8] =
                        wdata[byte_index*8 +: 8];
            end

            memory[addr] = new_data;
        end

        vif.responder_cb.M_APB_PREADY  <= 1'b0;
        vif.responder_cb.M_APB_PSLVERR <= 1'b0;
    endtask

endclass
