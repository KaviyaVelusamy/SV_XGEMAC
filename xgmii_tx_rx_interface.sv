`include "xgemac_defines.sv"



interface xgmii_tx_rx_interface(input clk, rst_n);
    logic [`XGMII_TX_RX_CONTROL_WIDTH - 1 : 0] xgmii_tx_rx_c;
    logic [`XGMII_TX_RX_DATA_WIDTH - 1 : 0] xgmii_tx_rx_d;

    initial begin
        $display("This is XGMII tx rx Interface");
    end
endinterface : xgmii_tx_rx_interface
