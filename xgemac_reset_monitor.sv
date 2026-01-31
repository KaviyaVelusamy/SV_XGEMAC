class xgemac_reset_monitor;

  xgemac_tb_config h_cfg;
  mailbox#(bit) mbx;
  
  tx_rx_rst_vif_t vif;
  string REPORT_TAG = "RESET_MONITOR";

  

  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  function void build();
    mbx = new(1);
  endfunction : build

  function void connect();
    vif = h_cfg.tx_rx_rst_vif;
  endfunction : connect

  function void report();
  endfunction : report

  task wait_for_reset();
    @(negedge vif.rst);
  endtask : wait_for_reset

  task run();
    forever
    begin
      fork
      begin
        wait_for_reset();
      end
    join
    mbx.put('b1);
    end
  endtask : run



endclass : xgemac_reset_monitor
