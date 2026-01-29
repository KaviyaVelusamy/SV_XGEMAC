package xgemac_pkg;

  //typedefed enum for reset types
  typedef enum bit {POS_RESET, NEG_RESET} rst_type_t;

  // virtual clock interfaces
  typedef virtual xgemac_clk_interface tx_rx_clk_vif_t;
  typedef virtual xgemac_clk_interface wb_clk_vif_t;
  typedef virtual xgemac_clk_interface xgmii_clk_vif_t;

  // virtual reset interfaces
  typedef virtual xgemac_rst_interface tx_rx_rst_vif_t;
  typedef virtual xgemac_rst_interface wb_rst_vif_t;
  typedef virtual xgemac_rst_interface xgmii_rst_vif_t;

  //virtual tx interface
  typedef virtual xgemac_tx_interface tx_vif_t;

  //virtual rx interface
  typedef virtual xgemac_rx_interface rx_vif_t;

  //virtual wishbone interface
  typedef virtual xgemac_wb_interface wb_vif_t;

  //virtual xgmii interface 
  typedef virtual xgmii_tx_rx_interface xgmii_vif_t;

  `include "xgemac_tb_config.sv"
  `include "clk_driver.sv"
  `include "rst_driver.sv"
  `include "xgemac_tx_pkt.sv"
  `include "xgemac_rx_pkt.sv"
  `include "wb_pkt.sv"
  `include "xgemac_generator.sv"
  `include "wb_generator.sv"
  `include "xgemac_tx_pkt_driver.sv"
  `include "xgemac_rx_pkt_driver.sv"
  `include "wb_driver.sv"
  `include "xgemac_tx_monitor.sv"
  `include "xgemac_rx_monitor.sv"
  `include "wb_monitor.sv"
  `include "xgemac_scoreboard.sv"
  `include "xgemac_env.sv"
  `include "xgemac_test_lib.sv"


endpackage : xgemac_pkg
