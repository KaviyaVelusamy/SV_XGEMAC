class xgemac_rx_monitor;

  //collect from vif
  //wait for reset
  //wait for rest done
  //collect transfer
  
  rx_vif_t vif;
  xgemac_tb_config h_cfg;
  mailbox#(xgemac_rx_pkt) mbx;
  string REPORT_TAG = "XGEMAC_RX_MONITOR";

  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build function
  function void build();
    $display("%s : Build function", REPORT_TAG);
    if(h_cfg.has_rx_mon) 
    begin
      mbx = new(1);
    end
  endfunction : build

  //Connect function
  function void connect();
    $display("%s : Connect function", REPORT_TAG);
    if(h_cfg.has_rx_mon)
    begin
      vif = h_cfg.rx_vif;
    end
  endfunction : connect

  //Report function
  function void report();
    $display("%s : Report funtion", REPORT_TAG);
  endfunction : report

  //Wait for reset task
  task wait_for_reset();
    @(negedge vif.rst);
  endtask : wait_for_reset

  //Wait for reset done task
  task wait_for_reset_done();
    wait(vif.rst == 0);
    @(posedge vif.rst);
  endtask : wait_for_reset_done

  //Collect from vif task
  task collect_from_vif();
    xgemac_rx_pkt h_rx_pkt, h_rx_cl_pkt;
    forever begin
      if(vif.mr_cb.pkt_rx_val == 1)
      begin
        h_rx_pkt = new();
        h_rx_pkt.pkt_rx_sop  = vif.mr_cb.pkt_rx_sop;
        h_rx_pkt.pkt_rx_data = vif.mr_cb.pkt_rx_data;
        h_rx_pkt.pkt_rx_mod  = vif.mr_cb.pkt_rx_mod;
        h_rx_pkt.pkt_rx_eop  = vif.mr_cb.pkt_rx_eop;
        $cast(h_rx_cl_pkt, h_rx_pkt.clone());
        //FIXME
        $display("From RX Interface to RX Monitor");
        h_rx_cl_pkt.display();
        mbx.put(h_rx_cl_pkt);
      end
      @(posedge vif.clk);
    end

  endtask : collect_from_vif

  //Collect transfer task
  task collect_transfer();
    process p[2];

    fork
    begin
      p[0] = process :: self();
      collect_from_vif();
    end
    begin
      p[1] = process :: self();
      wait_for_reset();
    end
    join_any

    foreach(p[i])
    begin
      if(p[i] != null)
      p[i].kill();
    end
  endtask : collect_transfer

  //Run task
  task run();
    forever
    begin
      wait_for_reset_done();
      collect_transfer();
    end
  endtask : run


endclass : xgemac_rx_monitor
