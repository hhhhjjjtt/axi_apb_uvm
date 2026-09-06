typedef enum bit {
    AXIL_READ,
    AXIL_WRITE
} axil_op_e;


class axil_item extends uvm_sequence_item;

    rand axil_op_e  op;
    rand bit [31:0] addr;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;
    rand bit [2:0]  prot;

    rand int unsigned aw_delay;
    rand int unsigned w_delay;
    rand int unsigned ar_delay;
    rand int unsigned response_ready_delay;

    bit [31:0] rdata;
    bit [1:0]  resp;

    `uvm_object_utils_begin(axil_item)
        `uvm_field_enum(axil_op_e, op, UVM_DEFAULT)
        `uvm_field_int(addr,                 UVM_DEFAULT)
        `uvm_field_int(wdata,                UVM_DEFAULT)
        `uvm_field_int(wstrb,                UVM_DEFAULT)
        `uvm_field_int(prot,                 UVM_DEFAULT)
        `uvm_field_int(aw_delay,             UVM_DEFAULT)
        `uvm_field_int(w_delay,              UVM_DEFAULT)
        `uvm_field_int(ar_delay,             UVM_DEFAULT)
        `uvm_field_int(response_ready_delay, UVM_DEFAULT)
        `uvm_field_int(rdata,                UVM_DEFAULT)
        `uvm_field_int(resp,                 UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axil_item");
        super.new(name);
    endfunction

    constraint aligned_address_c {
        addr[1:0] == 2'b00;
    }

    constraint timing_c {
        aw_delay             inside {[0:5]};
        w_delay              inside {[0:5]};
        ar_delay             inside {[0:5]};
        response_ready_delay inside {[0:5]};
    }

    constraint defaults_c {
        soft prot == 3'b000;

        if (op == AXIL_WRITE) {
            soft wstrb == 4'b1111;
        }
        else {
            wdata == '0;
            wstrb == '0;
        }
    }

endclass
