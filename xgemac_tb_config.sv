class xgemac_tb_config;

  string REPORT_TAG = "XGEMAC_TB_CONFIG";
  //clock virtual interfaces
  tx_rx_clk_vif_t tx_rx_clk_vif;
  wb_clk_vif_t wb_clk_vif;
  xgmii_clk_vif_t xgmii_clk_vif;

  //reset virtual interfaces
  tx_rx_rst_vif_t tx_rx_rst_vif;
  wb_rst_vif_t wb_rst_vif;
  xgmii_rst_vif_t xgmii_rst_vif;
  
  //tx virtual interface
  tx_vif_t tx_vif;

  //rx virtual interface
  rx_vif_t rx_vif;

  //wishbone virtual interface
  wb_vif_t wb_vif;

  //xgmii virtual interface
  xgmii_vif_t xgmii_vif;

  //Knobs
  //Environment knob
  bit has_env = 1;

  //TX RX GENERATOR KNOB
  bit has_tx_rx_gen = 1;

  //WISHBONE GENERATOR KNOB
  bit has_wb_gen = 1;

  //TX PKT DRIVER KNOB
  bit has_tx_pkt_drv = 1;

  //RX PKT DRIVER KNOB
  bit has_rx_pkt_drv = 1;

  //WISHBONE DRIVER KNOB
  bit has_wb_drv = 1;

  //TX MONITOR KNOB
  bit has_tx_mon = 1;
  
  //RX MONITOR KNOB
  bit has_rx_mon = 1;

  //WISHBONE MONITOR KNOB
  bit has_wb_mon = 1;

  //XGEMAC SCOREBOARD KNOB
  bit has_scbd = 1;

  //Transaction count for direct test
  rand int unsigned trans_count;

  int act_count;

  int tx_trans_count;

  //frame trans_count for incremental test
  int inc_trans_count;

  int pad_act_count;

  int check_inc_count;

  //start value for incremental test
  bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] inc_start_value;

  //rand delay or set delay task in tx_pkt driver
  bit rand_delay;

  bit test_status;

  string print_string;

  rand int read_enable_delay;


  //Constructor
  function new();
    $display("%s : Constructor", REPORT_TAG);
  endfunction : new


endclass : xgemac_tb_config
