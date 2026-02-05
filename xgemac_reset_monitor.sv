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

  task wait_for_reset_done();
    wait(vif.rst === 0);
    @(posedge vif.rst);
  endtask : wait_for_reset_done

  task wait_for_reset();
    @(negedge vif.rst);
    mbx.put('b1);
  endtask : wait_for_reset

  task collect_transfer();
    wait_for_reset();
  endtask : collect_transfer

  task run();
    forever
    begin
      wait_for_reset_done();
      collect_transfer();
    end
  endtask : run



endclass : xgemac_reset_monitor
