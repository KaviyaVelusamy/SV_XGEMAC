class wb_monitor;

  //collect from vif
  //collect transfer
  //wait for reset
  //wait for reset done

  xgemac_tb_config h_cfg;
  mailbox#(wb_pkt) mbx;
  wb_pkt h_wb_pkt;
  wb_vif_t vif;
  string REPORT_TAG = "WISHBONE MONITOR";

  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build function
  function void build();
    if(h_cfg.has_wb_mon)
      begin
        $display("%s : Build function", REPORT_TAG);
        mbx = new(1);
      end
  endfunction : build

  //Connect function 
  function void connect();
    if(h_cfg.has_wb_mon)
      begin
        $display("%s : Connect function", REPORT_TAG);
        vif = h_cfg.wb_vif;
      end
  endfunction :connect

  //Report function
  function void report();
  endfunction : report

  //Wait for reset task
  task wait_for_reset();
    @(posedge vif.rst);
  endtask : wait_for_reset

  //Wait for reset done
  task wait_for_reset_done();
    wait(vif.rst == 1);
    @(negedge vif.rst);
  endtask : wait_for_reset_done

  //Collect from vif task
  task collect_from_vif();
    wb_pkt h_wb_pkt, h_wb_cl_pkt;
    forever
    begin
      if(vif.mr_cb.wb_ack_o);
      begin
        h_wb_pkt = new();
        h_wb_pkt.wb_dat_o = vif.mr_cb.wb_dat_o;
        h_wb_pkt.wb_int_o = vif.mr_cb.wb_int_o;
        $cast(h_wb_cl_pkt, h_wb_pkt.clone());
        //FIXME
       // display(h_wb_cl_pkt);
        mbx.put(h_wb_cl_pkt);
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

  //Display function to display packet values
  function void display(wb_pkt h_wb_cl_pkt);
    $display("Wishbone packet values :");
    $display("WISHBONE_DATA      : %0h", h_wb_cl_pkt.wb_dat_o);
    $display("WISHBOBE_INTERRUPT : %0h", h_wb_cl_pkt.wb_int_o);
  endfunction : display

  //Run task
  task run();
    if(h_cfg.has_wb_mon)
    begin
      $display("%s : Run Task", REPORT_TAG);
      forever 
      begin
        wait_for_reset_done();
        collect_transfer();
      end
    end
  endtask : run


endclass : wb_monitor
