class xgemac_rx_pkt_driver;


  //get and drive
  //drive transfer
  //wait for reset
  //wait for reset done
  //reset input signals
  //drive into pins

  xgemac_tb_config h_cfg;
  rx_vif_t vif;
  string REPORT_TAG = "XGEMAC_RX_PKT_DRIVER";

  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  function void build();
    $display("%s : Build function", REPORT_TAG);
  endfunction : build

  function void connect();
    $display("%s : Connect function", REPORT_TAG);
    if(h_cfg.has_rx_pkt_drv == 1)
    begin
      this.vif = h_cfg.rx_vif;
    end
  endfunction : connect

  task wait_for_reset();
    @(negedge vif.rst);
  endtask : wait_for_reset

  task wait_for_reset_done();
    @(posedge vif.rst);
  endtask : wait_for_reset_done

  function void reset_input_signals();
    vif.pkt_rx_ren = 0;
  endfunction : reset_input_signals

  task wait_and_drive();
    forever begin
    wait(vif.mr_cb.pkt_rx_avail === 1);
    
    drive_into_pins();
    wait(vif.mr_cb.pkt_rx_eop === 1);
  //  @(posedge vif.clk);
    reset_input_signals();
    end
  endtask : wait_and_drive

  task drive_into_pins();
    @(posedge vif.clk);  
    vif.dr_cb.pkt_rx_ren <= 1;
  endtask : drive_into_pins

  task drive_transfer();
    process p[2];

    fork
    begin
      p[0] = process ::self();
      wait_and_drive();
    end
    begin
      p[1] = process::self();
      wait_for_reset();
    end
  join_any

  foreach(p[i])
    p[i].kill();
    
  endtask : drive_transfer

  task run();
    $display("%s : Run task", REPORT_TAG);
    if(h_cfg.has_rx_pkt_drv)
    begin
      forever begin
        wait_for_reset_done();
        reset_input_signals();
        drive_transfer();
      end
    end
  endtask : run

  
endclass : xgemac_rx_pkt_driver
