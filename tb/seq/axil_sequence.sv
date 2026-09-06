class axil_sequence extends uvm_sequence #(axil_item);

    `uvm_object_utils(axil_sequence)

    int unsigned num_items = 10;

    function new(string name = "axil_sequence");
        super.new(name);
    endfunction

    task send_write(
        input bit [31:0] address,
        input bit [31:0] data,
        input bit [3:0]  strobes = 4'b1111,
        input bit [2:0]  protection = 3'b000,
        input int unsigned address_delay = 0,
        input int unsigned data_delay = 0,
        input int unsigned ready_delay = 0
    );
        axil_item req;

        req = axil_item::type_id::create("write_req");
        start_item(req);
        if (!req.randomize() with {
                op                   == AXIL_WRITE;
                addr                 == address;
                wdata                == data;
                wstrb                == strobes;
                prot                 == protection;
                aw_delay             == address_delay;
                w_delay              == data_delay;
                ar_delay             == 0;
                response_ready_delay == ready_delay;
            }) begin
            `uvm_fatal("AXIL_SEQ", "Failed to randomize directed write")
        end
        finish_item(req);
    endtask

    task send_read(
        input bit [31:0] address,
        input bit [2:0]  protection = 3'b000,
        input int unsigned address_delay = 0,
        input int unsigned ready_delay = 0
    );
        axil_item req;

        req = axil_item::type_id::create("read_req");
        start_item(req);
        if (!req.randomize() with {
                op                   == AXIL_READ;
                addr                 == address;
                prot                 == protection;
                aw_delay             == 0;
                w_delay              == 0;
                ar_delay             == address_delay;
                response_ready_delay == ready_delay;
            }) begin
            `uvm_fatal("AXIL_SEQ", "Failed to randomize directed read")
        end
        finish_item(req);
    endtask

endclass


class axil_smoke_sequence extends axil_sequence;

    `uvm_object_utils(axil_smoke_sequence)

    function new(string name = "axil_smoke_sequence");
        super.new(name);
    endfunction

    task body();
        send_write(32'h0000_0000, 32'h1234_abcd);
        send_read (32'h0000_0000);
        send_write(32'h0000_0004, 32'hdead_beef);
        send_read (32'h0000_0004);
    endtask

endclass


class axil_channel_order_sequence extends axil_sequence;

    `uvm_object_utils(axil_channel_order_sequence)

    function new(string name = "axil_channel_order_sequence");
        super.new(name);
    endfunction

    task body();
        // AW and W together, AW first, then W first.
        send_write(32'h0000_0010, 32'haaaa_0001, 4'hf, 3'b000, 0, 0);
        send_write(32'h0000_0014, 32'hbbbb_0002, 4'hf, 3'b001, 0, 3);
        send_write(32'h0000_0018, 32'hcccc_0003, 4'hf, 3'b010, 3, 0);

        send_read(32'h0000_0010, 3'b000, 0);
        send_read(32'h0000_0014, 3'b001, 2);
        send_read(32'h0000_0018, 3'b010, 5);
    endtask

endclass


class axil_mapping_sequence extends axil_sequence;

    `uvm_object_utils(axil_mapping_sequence)

    function new(string name = "axil_mapping_sequence");
        super.new(name);
    endfunction

    task body();
        send_write(32'h0000_0020, 32'h1122_3344, 4'b0001, 3'b000);
        send_write(32'h0000_0024, 32'h5566_7788, 4'b0010, 3'b001);
        send_write(32'h0000_0028, 32'h99aa_bbcc, 4'b1100, 3'b101);
        send_write(32'h0000_002c, 32'hddee_ff00, 4'b1111, 3'b111);

        send_read(32'h0000_0020, 3'b000);
        send_read(32'h0000_0024, 3'b001);
        send_read(32'h0000_0028, 3'b101);
        send_read(32'h0000_002c, 3'b111);
    endtask

endclass


class axil_random_sequence extends axil_sequence;

    `uvm_object_utils(axil_random_sequence)

    function new(string name = "axil_random_sequence");
        super.new(name);
    endfunction

    task body();
        axil_item req;

        repeat (num_items) begin
            req = axil_item::type_id::create("req");

            // Disable the soft defaults so random traffic varies PROT/WSTRB.
            req.defaults_c.constraint_mode(0);

            start_item(req);
            if (!req.randomize() with {
                    addr inside {[32'h0000_0000:32'h0000_00fc]};
                }) begin
                `uvm_fatal("AXIL_SEQ", "Failed to randomize AXI item")
            end
            finish_item(req);

            `uvm_info("AXIL_SEQ",
                $sformatf("Completed transaction:\n%s", req.sprint()),
                UVM_HIGH)
        end
    endtask

endclass
