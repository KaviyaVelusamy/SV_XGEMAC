class xgemac_env;

  xgemac_tb_config h_cfg;

  // wb clk driver instantiation
  clk_driver#(.t(int), .CLOCK_PERIOD(`XGEMAC_WB_CLOCK_PERIOD), .vif_t(wb_clk_vif_t)) wb_clk_drv;

  // tx_rx clk driver instantiation
  clk_driver#(.t(int), .CLOCK_PERIOD(`XGEMAC_TX_RX_CLOCK_PERIOD), .vif_t(tx_rx_clk_vif_t)) tx_rx_clk_drv;

  // xgmii clk driver instantiation
  clk_driver#(.t(int), .CLOCK_PERIOD(`XGEMAC_TX_RX_CLOCK_PERIOD), .vif_t(xgmii_clk_vif_t)) xgmii_clk_drv;

  // wb reset driver instantiation
  rst_driver#(.RESET_PERIOD(`XGEMAC_WB_RESET_PERIOD), .rst_type(xgemac_pkg :: POS_RESET), .vif_t(wb_rst_vif_t)) wb_rst_drv;

  // tx_rx reset driver instantiation
  rst_driver#(.RESET_PERIOD(`XGEMAC_TX_RX_RESET_PERIOD), .rst_type(xgemac_pkg :: NEG_RESET), .vif_t(tx_rx_rst_vif_t)) tx_rx_rst_drv;

  // xgmii reset driver instantiation
  rst_driver#(.RESET_PERIOD(`XGEMAC_TX_RX_RESET_PERIOD), .rst_type(xgemac_pkg :: NEG_RESET), .vif_t(xgmii_rst_vif_t)) xgmii_rst_drv;

  //xgemac reset generator
  xgemac_reset_generator h_wb_rst_gen;

  xgemac_reset_generator h_tx_rx_rst_gen;

  xgemac_reset_generator h_xgmii_rst_gen;

  //xgemac tx pkt generator
  xgemac_generator h_xgemac_gen;

  //tx interface driver
  xgemac_tx_pkt_driver tx_pkt_drv;

  //rx interface driver
  xgemac_rx_pkt_driver rx_pkt_drv;

  //tx interface monitor
  xgemac_tx_monitor tx_pkt_mon;

  //rx interface monitor
  xgemac_rx_monitor rx_pkt_mon;

  //xgemac reset monitor
  xgemac_reset_monitor rst_mon;

  //wishbone generator
  wb_generator wb_gen;

  //wishbone interface driver
  wb_driver wb_drv;

  //wishbone interface monitor
  wb_monitor wb_mon;

  //xgemac scoreboard
  xgemac_scoreboard h_scbd;

  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build Function
  function void build();
    $display("Inside ENVIRONMENT build");
    wb_clk_drv    = new(h_cfg.wb_clk_vif);
    tx_rx_clk_drv = new(h_cfg.tx_rx_clk_vif);
    xgmii_clk_drv = new(h_cfg.xgmii_clk_vif);

    h_wb_rst_gen     = new(h_cfg);
    h_tx_rx_rst_gen  = new(h_cfg);
    h_xgmii_rst_gen  = new(h_cfg);

    wb_rst_drv    = new(h_cfg.wb_rst_vif);
    tx_rx_rst_drv = new(h_cfg.tx_rx_rst_vif);
    xgmii_rst_drv = new(h_cfg.xgmii_rst_vif);

    h_xgemac_gen  = new(h_cfg);

    tx_pkt_drv    = new(h_cfg);
    rx_pkt_drv    = new(h_cfg);

    tx_pkt_mon    = new(h_cfg);
    rx_pkt_mon    = new(h_cfg);
    rst_mon       = new(h_cfg);


    wb_gen        = new(h_cfg);

    wb_drv        = new(h_cfg);

    wb_mon        = new(h_cfg);

    h_scbd        = new(h_cfg);

    h_wb_rst_gen.build();
    h_tx_rx_rst_gen.build();
    h_xgmii_rst_gen.build();

    h_xgemac_gen.build();

    tx_pkt_drv.build();
    rx_pkt_drv.build();

    wb_gen.build();

    wb_drv.build();

    tx_pkt_mon.build();
    rx_pkt_mon.build();
    wb_mon.build();
    rst_mon.build();

    h_scbd.build();
    
  endfunction : build

  function void connect();
    $display("Inside ENVIRONMENT connect");
    
    wb_clk_drv.connect();
    tx_rx_clk_drv.connect();
    xgmii_clk_drv.connect();

    h_wb_rst_gen.connect();
    h_tx_rx_rst_gen.connect();
    h_xgmii_rst_gen.connect();

    tx_rx_rst_drv.mbx = h_tx_rx_rst_gen.mbx;
    wb_rst_drv.mbx    = h_wb_rst_gen.mbx;
    xgmii_rst_drv.mbx = h_xgmii_rst_gen.mbx;


    wb_rst_drv.connect();
    tx_rx_rst_drv.connect();
    xgmii_rst_drv.connect();

    tx_pkt_drv.connect();
    rx_pkt_drv.connect();
    wb_drv.connect();

    tx_pkt_mon.connect();
    rx_pkt_mon.connect();
    rst_mon.connect();
    
    h_scbd.connect();

    tx_pkt_drv.mbx = h_xgemac_gen.mbx;
    wb_drv.mbx     = wb_gen.mbx;

    h_scbd.rst_mbx = rst_mon.mbx;

    h_scbd.tx_mbx  = tx_pkt_mon.mbx;
    h_scbd.rx_mbx  = rx_pkt_mon.mbx;
    
  endfunction : connect

  task run();
    $display("Inside ENVIRONMENT run");
    fork
    wb_clk_drv.run();
    tx_rx_clk_drv.run();
    xgmii_clk_drv.run();

    wb_rst_drv.run();
    tx_rx_rst_drv.run();
    xgmii_rst_drv.run();

    wb_rst_drv.drive_reset_method();
    tx_rx_rst_drv.drive_reset_method();
    xgmii_rst_drv.drive_reset_method();

    tx_pkt_drv.run();
    rx_pkt_drv.run();
 
    wb_drv.run();

    tx_pkt_mon.run();
    rx_pkt_mon.run();
    rst_mon.run();


    h_scbd.run();
    join_none
  endtask : run

  function void report();
    $display("Inside Environent report");
  endfunction : report


endclass : xgemac_env
