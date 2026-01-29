`include "xgemac_defines.sv"

interface xgemac_rx_interface(input clk, rst);

    logic                                     pkt_rx_ren;
    logic                                     pkt_rx_avail;
    logic                                     pkt_rx_val;
    logic [`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0]  pkt_rx_data;
    logic                                     pkt_rx_sop;
    logic                                     pkt_rx_eop;
    logic [`XGEMAC_TX_RX_MOD - 1 : 0]         pkt_rx_mod;
    logic                                     pkt_rx_err;

    clocking dr_cb@(posedge clk);
        output pkt_rx_ren;
    endclocking : dr_cb

    clocking mr_cb@(posedge clk);
        input pkt_rx_ren;
        input pkt_rx_avail;
        input pkt_rx_val;
        input pkt_rx_data;
        input pkt_rx_eop;
        input pkt_rx_sop;
        input pkt_rx_mod;
        input pkt_rx_err;
    endclocking : mr_cb

    initial begin
        $display("This is rx interface");
    end


endinterface : xgemac_rx_interface
