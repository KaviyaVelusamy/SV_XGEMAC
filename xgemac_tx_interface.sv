`include "xgemac_defines.sv"

interface xgemac_tx_interface(input clk, rst);

    
logic [`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] pkt_tx_data;
logic                                    pkt_tx_val;
logic                                    pkt_tx_sop;
logic                                    pkt_tx_eop;
logic [`XGEMAC_TX_RX_MOD - 1 : 0]        pkt_tx_mod;
logic                                    pkt_tx_full;

clocking dr_cb@(posedge clk);
    default input #1 output #0;
    output pkt_tx_data;
    output pkt_tx_val;
    output pkt_tx_sop;
    output pkt_tx_eop;
    output pkt_tx_mod;
endclocking : dr_cb

clocking mr_cb@(posedge clk);
    default input #1 output #0;
    input pkt_tx_full;
    input pkt_tx_data;
    input pkt_tx_val;
    input pkt_tx_sop;
    input pkt_tx_eop;
    input pkt_tx_mod;
endclocking : mr_cb

initial begin
    $display("This is tx_interface");
end


endinterface : xgemac_tx_interface
