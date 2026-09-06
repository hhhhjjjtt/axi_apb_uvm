class apb_item extends uvm_sequence_item;

    bit        write;
    bit [31:0] addr;
    bit [31:0] wdata;
    bit [3:0]  wstrb;
    bit [2:0]  prot;
    bit [31:0] rdata;
    bit        slverr;
    int unsigned wait_cycles;

    `uvm_object_utils_begin(apb_item)
        `uvm_field_int(write,       UVM_DEFAULT)
        `uvm_field_int(addr,        UVM_DEFAULT)
        `uvm_field_int(wdata,       UVM_DEFAULT)
        `uvm_field_int(wstrb,       UVM_DEFAULT)
        `uvm_field_int(prot,        UVM_DEFAULT)
        `uvm_field_int(rdata,       UVM_DEFAULT)
        `uvm_field_int(slverr,      UVM_DEFAULT)
        `uvm_field_int(wait_cycles, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "apb_item");
        super.new(name);
    endfunction

endclass
