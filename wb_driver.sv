class wb_driver;

  //wait for reset 
  //wait for reset done
  //get and driver
  //drive transfer
  //reset input signals
  //drive into pins

  mailbox#(wb_pkt) mbx;
  xgemac_tb_config h_cfg;
  wb_vif_t vif;
  string REPORT_TAG = "WISHBONE_DRIVER";
  
  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build Function
  function void build();
    if(h_cfg.has_wb_drv)
    begin
      $display("%s : Build Function", REPORT_TAG);
      mbx = new(1);
    end
  endfunction : build

  //Connect Function
  function void connect();
    if(h_cfg.has_wb_drv)
    begin
      $display("%s : Connect Function", REPORT_TAG);
      vif = h_cfg.wb_vif;
    end
  endfunction : connect

  //Report Function
  function void report();

  endfunction : report

  //Wait for reset task
  task wait_for_reset();
    @(posedge vif.rst);
  endtask : wait_for_reset

  //Wait for reset done task
  task wait_for_reset_done();
    wait(vif.rst);
    @(negedge vif.rst);
  endtask : wait_for_reset_done

  //Reset input signals task
  function void reset_input_signals();
    vif.wb_adr_i = 'hx;
    vif.wb_cyc_i = 'h0;
    vif.wb_dat_i = 'hx;
    vif.wb_stb_i = 'h0;
    vif.wb_we_i  = 'h0;   
  endfunction : reset_input_signals
 
  //Get and drive Task
  task get_and_drive();
    wb_pkt h_wb_pkt, h_wb_cl_pkt;
    forever begin
      mbx.get(h_wb_pkt);
      $cast(h_wb_cl_pkt, h_wb_pkt.clone());
      drive_into_pins(h_wb_cl_pkt);
      @(posedge vif.clk);
      reset_input_signals();
    end
  endtask : get_and_drive

  //Drive transfer task
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

    foreach(p[i])
      p[i].kill();

  endtask :drive_transfer

  //Drive into pins Task
  task drive_into_pins(wb_pkt h_wb_pkt);

    vif.dr_cb.wb_adr_i <= h_wb_pkt.wb_adr_i;
    vif.dr_cb.wb_cyc_i <= 'h1;
    vif.dr_cb.wb_dat_i <= h_wb_pkt.wb_dat_i;
    vif.dr_cb.wb_stb_i <= 'h1;
    vif.dr_cb.wb_we_i  <= h_wb_pkt.wb_we_i;
    wait(vif.mr_cb.wb_ack_o);
    
  endtask : drive_into_pins

  //Run Task
  task run();
    if(h_cfg.has_wb_drv)
    begin
      $display("%s: Run task", REPORT_TAG);
      forever begin
        wait_for_reset_done();
        reset_input_signals();
        drive_transfer();
      end
    end
  endtask : run

endclass : wb_driver

