class xgemac_tx_monitor;

  xgemac_tb_config h_cfg;
  tx_vif_t vif;
  mailbox#(xgemac_tx_pkt) mbx;

  //collect from vif
  //collect transfer
  //wait for reset 
  //wait for reset done
  

  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build function to create mailbox
  function void build();
    mbx = new();
  endfunction : build

  //Connect function to connect vif
  function void connect();
    vif = h_cfg.tx_vif;
  endfunction : connect

  //Report function
  function void report();
  endfunction : report

  //Wait for reset task
  task wait_for_reset();
    @(posedge vif.rst);
  endtask : wait_for_reset

  //Wait for reset done task
  task wait_for_reset_done();
    wait(vif.rst == 0);
    @(posedge vif.rst);
  endtask : wait_for_reset_done

  //Collect from vif
  task collect_from_vif();
    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;
    forever begin
    if(vif.mr_cb.pkt_tx_val == 1)
    begin
      h_tx_pkt = new();
      h_tx_pkt.pkt_tx_sop  = vif.mr_cb.pkt_tx_sop;
      h_tx_pkt.pkt_tx_data = vif.mr_cb.pkt_tx_data;
      h_tx_pkt.pkt_tx_mod  = vif.mr_cb.pkt_tx_mod;
      h_tx_pkt.pkt_tx_eop  = vif.mr_cb.pkt_tx_eop;
      $cast(h_tx_cl_pkt, h_tx_pkt.clone());
      //FIXME
      h_tx_cl_pkt.display();
      mbx.put(h_tx_cl_pkt);
    end
    @(posedge vif.clk);
  end
   // @(posedge vif.clk);
  endtask : collect_from_vif

  //Collect transfer
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

  foreach(p[i]) begin
    if(p[i] != null)
    p[i].kill();
  end

  endtask : collect_transfer

  //Display Function to display TX packet values
  function void display(xgemac_tx_pkt h_tx_cl_pkt);
    $display("XGEMAC Tx packet values :");
    $display("PKT_TX_DATA : %0h", h_tx_cl_pkt.pkt_tx_data);
    $display("PKT_TX_SOP  : %0h", h_tx_cl_pkt.pkt_tx_sop);
    $display("PKT_TX_EOP  : %0h", h_tx_cl_pkt.pkt_tx_eop);
    $display("PKT_TX_MOD  : %0h", h_tx_cl_pkt.pkt_tx_mod);
  endfunction : display

  //Run task
  task run();
    forever begin
      wait_for_reset_done();
      collect_transfer();
    end
  endtask : run

endclass : xgemac_tx_monitor
