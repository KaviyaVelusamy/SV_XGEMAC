`include "xgemac_defines.sv"

interface xgemac_wb_interface(input clk, rst);
    logic [`XGEMAC_WB_ADDR_WIDTH - 1 : 0] wb_adr_i;
    logic                                 wb_cyc_i;
    logic [`XGEMAC_WB_DATA_WIDTH - 1 : 0] wb_dat_i;
    logic                                 wb_stb_i;
    logic                                 wb_we_i;
    logic                                 wb_ack_o;
    logic [`XGEMAC_WB_DATA_WIDTH - 1 : 0] wb_dat_o;
    logic                                 wb_int_o;

    clocking dr_cb@(posedge clk);
        output wb_adr_i;
        output wb_cyc_i;
        output wb_dat_i;
        output wb_stb_i;
        output wb_we_i;
    endclocking : dr_cb

    clocking mr_cb@(posedge clk);
        input wb_ack_o;
        input wb_dat_o;
        input wb_int_o;
    endclocking :mr_cb

    initial begin
        $display("This is wb interface");
    end


endinterface : xgemac_wb_interface
