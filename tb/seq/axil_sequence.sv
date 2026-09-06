class axil_sequence extends uvm_sequence #(axil_item);
    
    `uvm_object_utils(axil_sequence)

    int unsigned num_items = 10;
    
    function new(string name = "axil_sequence");
        super.new(name);
    endfunction

    task send_read();
    endtask 

    task send_write();
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
            start_item(req);
            if (!req.randomize() with{addr inside{[32'h0000_0000:32'h0000_00FC]};}) begin
                `uvm_fatal("AXIL_SEQ", "Failed to randomize AXI item")
            end
            finish_item(req);
            `uvm_info(
                "AXIL_SEQ",
                $sformatf("Completed transaction:\n%s", req.sprint()),
                UVM_MEDIUM
            )
        end
    endtask 

endclass
