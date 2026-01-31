class xgemac_tx_pkt_driver;

  mailbox#(xgemac_tx_pkt) mbx;
  tx_vif_t vif;
  xgemac_tb_config h_cfg;


  //get and drive
  //drive transfer
  //wait for reset done
  //wait for reset 
  //reset input signals
  //drive into pins
  
  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Wait for reset Task
  task wait_for_reset();
    @(negedge vif.rst);
  endtask : wait_for_reset

  //Wait for reset done Task
  task wait_for_reset_done();
    wait(vif.rst == 0);
    @(posedge vif.rst);
  endtask : wait_for_reset_done

  //Reset Input Signals Function
  function void reset_input_signals();
    vif.pkt_tx_data = 'hx;
    vif.pkt_tx_val  = 'h0;
    vif.pkt_tx_sop  = 'h0;
    vif.pkt_tx_eop  = 'h0;
    vif.pkt_tx_mod  = 'hx;
  endfunction : reset_input_signals

  //Drive Transfer Task
  task drive_transfer();
    process p[2];
    fork
    begin
      p[0] = process :: self();
      get_and_drive();
    end
    begin
      p[1] = process :: self();
      wait_for_reset();
    end
    join_any

    foreach(p[i]) begin
      $display("###############HI##############");
      p[i].kill();
    end

  endtask : drive_transfer

  //Get and drive Task
  task get_and_drive();
    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;
    forever
    begin
      mbx.get(h_tx_pkt);
      $display("Reset handling");
      $cast(h_tx_cl_pkt, h_tx_pkt.clone());
      h_tx_cl_pkt.display();
      drive_into_pins(h_tx_cl_pkt);
     
    end
  endtask : get_and_drive

  //Drive into pins Task
  task drive_into_pins(xgemac_tx_pkt h_tx_pkt);
      wait(vif.mr_cb.pkt_tx_full === 0)
      //FIXME $display("%%%%%%%%%%%%Data going to drive%%%%%%%%");
      //FIXME $display("PKT_TX_FULL(DR_CB) : %0b time : %0t", vif.dr_cb.pkt_tx_full, $time);
      //FIXME$display("PKT_TX_FULL(MR_CB) : %0b time : %0t", vif.mr_cb.pkt_tx_full, $time);
      vif.dr_cb.pkt_tx_val  <= 1;
      vif.dr_cb.pkt_tx_data <= h_tx_pkt.pkt_tx_data;
      vif.dr_cb.pkt_tx_sop  <= h_tx_pkt.pkt_tx_sop;
      vif.dr_cb.pkt_tx_eop  <= h_tx_pkt.pkt_tx_eop;
      vif.dr_cb.pkt_tx_mod  <= h_tx_pkt.pkt_tx_mod;
      @(posedge vif.clk);
      reset_input_signals();
      //FIXME set_delay();
  endtask : drive_into_pins

  //Build Function
  function void build();
    $display("Inside tx_pkt_driver");
  endfunction : build

  //Connect Function
  function void connect();
    this.vif = h_cfg.tx_vif;
  endfunction : connect
  
  //Run Task
  task run();
    forever begin
      reset_input_signals();
      wait_for_reset_done();
      drive_transfer();
    end
  endtask : run

endclass : xgemac_tx_pkt_driver
