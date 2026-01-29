`timescale 1ps/1ps

`include "xgemac_defines.sv"
`include "xgemac_clk_interface.sv"
`include "xgemac_rst_interface.sv"
`include "xgemac_tx_interface.sv"
`include "xgemac_rx_interface.sv"
`include "xgemac_wb_interface.sv"
`include "xgmii_tx_rx_interface.sv"
`include "xgemac_pkg.sv"
 import xgemac_pkg ::*;
`include "../rtl/verilog/xgemac_rtl_list.sv"
`include "test_top.sv"

module tb_top();

initial begin
    $display("Hello World");
end

//clock interface instance tx_rx
xgemac_clk_interface tx_rx_clk();

//clock interface instance for wb
xgemac_clk_interface wb_clk();

//clock interface instance for xgmii
xgemac_clk_interface xgmii_clk();

//reset interface instance
xgemac_rst_interface tx_rx_rst(tx_rx_clk.clk);

//reset interface instance for wb
xgemac_rst_interface wb_rst(wb_clk.clk);

//reset interface instance for rx
xgemac_rst_interface xgmii_rst(xgmii_clk.clk);

//xgemac tx interface instance
xgemac_tx_interface tx_intf(tx_rx_clk.clk, tx_rx_rst.rst);

//xgemac rx interface instance
xgemac_rx_interface rx_intf(tx_rx_clk.clk, tx_rx_rst.rst);

//xgemac wb interface
xgemac_wb_interface wb_intf(wb_clk.clk, wb_rst.rst);

//xgmii interface
xgmii_tx_rx_interface xgmii_intf(xgmii_clk.clk, xgmii_rst.rst);

//DUT Instance
xge_mac xg(
     //input ports
     .xgmii_rxd(xgmii_intf.xgmii_tx_rx_d), .xgmii_rxc(xgmii_intf.xgmii_tx_rx_c), .wb_we_i(wb_intf.wb_we_i), .wb_stb_i(wb_intf.wb_stb_i), .wb_rst_i(wb_rst.rst), .wb_dat_i(wb_intf.wb_dat_i), .wb_cyc_i(wb_intf.wb_cyc_i), .wb_clk_i(wb_clk.clk), .wb_adr_i(wb_intf.wb_adr_i), .reset_xgmii_tx_n(xgmii_rst.rst), .reset_xgmii_rx_n(xgmii_rst.rst), .reset_156m25_n(tx_rx_rst.rst), .pkt_tx_val(tx_intf.pkt_tx_val), .pkt_tx_sop(tx_intf.pkt_tx_sop), .pkt_tx_mod(tx_intf.pkt_tx_mod), .pkt_tx_eop(tx_intf.pkt_tx_eop), .pkt_tx_data(tx_intf.pkt_tx_data), .pkt_rx_ren(rx_intf.pkt_rx_ren), .clk_xgmii_tx(xgmii_clk.clk), .clk_xgmii_rx(xgmii_clk.clk), .clk_156m25(tx_rx_clk.clk),

     //output ports
     .xgmii_txd(xgmii_intf.xgmii_tx_rx_d), .xgmii_txc(xgmii_intf.xgmii_tx_rx_c), .wb_int_o(wb_intf.wb_int_o), .wb_dat_o(wb_intf.wb_dat_o), .wb_ack_o(wb_intf.wb_ack_o), .pkt_tx_full(tx_intf.pkt_tx_full), .pkt_rx_val(rx_intf.pkt_rx_val), .pkt_rx_sop(rx_intf.pkt_rx_sop), .pkt_rx_mod(rx_intf.pkt_rx_mod), .pkt_rx_err(rx_intf.pkt_rx_err), .pkt_rx_eop(rx_intf.pkt_rx_eop), .pkt_rx_data(rx_intf.pkt_rx_data), .pkt_rx_avail(rx_intf.pkt_rx_avail));

//test_top instance
test_top i_tp(.tx_rx_clk(tx_rx_clk), .wb_clk(wb_clk), .xgmii_clk(xgmii_clk), .tx_rx_rst(tx_rx_rst), .wb_rst(wb_rst), .xgmii_rst(xgmii_rst), .tx_intf(tx_intf), .rx_intf(rx_intf), .wb_intf(wb_intf), .xgmii_intf(xgmii_intf));



endmodule: tb_top
