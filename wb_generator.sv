class wb_generator;

  mailbox#(wb_pkt) mbx;
  xgemac_tb_config h_cfg;
 // wb_pkt h_wb_pkt;
  string REPORT_TAG = "WISHBONE_GENERATOR";

  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  function void build();
    if(h_cfg.has_wb_gen)
    begin
      $display("%s : Build Function", REPORT_TAG);
      mbx = new(1);
    end
  endfunction : build

  function void connect();
  endfunction : connect

  function void report();
  endfunction : report

  task run();
  endtask : run

  task write_in_configuration_register();
    wb_pkt h_wb_pkt, h_wb_cl_pkt;
    h_wb_pkt = new();
    h_wb_pkt.wb_adr_i = 'h0;
    h_wb_pkt.wb_dat_i = 'h0;
    h_wb_pkt.wb_we_i  = 'h1;
    $cast(h_wb_cl_pkt, h_wb_pkt.clone());
    mbx.put(h_wb_cl_pkt);
  endtask : write_in_configuration_register

  function void write_in_interrupt_mask_register();
  endfunction : write_in_interrupt_mask_register

  task read_tx_enable();
    wb_pkt h_wb_pkt, h_wb_cl_pkt;
    h_wb_pkt = new();
    h_wb_pkt.wb_adr_i = 'h0;
    h_wb_pkt.wb_we_i  = 'h0;

    $cast(h_wb_cl_pkt, h_wb_pkt.clone());
    mbx.put(h_wb_cl_pkt);
    
  endtask : read_tx_enable

  task disable_tx_enable();

  endtask : disable_tx_enable


endclass : wb_generator
