class wb_driver;

  //wait for reset 
  //wait for reset done
  //get and driver
  //drive transfer
  //reset input signals
  //drive into pins

  mailbox#(wb_pkt) mbx;
  wb_pkt h_wb_pkt;
  xgemac_tb_config h_cfg;
  wb_vif_t vif;
  string REPORT_TAG = "WISHBONE_DRIVER";
  
  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build function
  function void build();
  endfunction : build

  //Connect function
  function void connect();
    mbx = new(1);
  endfunction : connect

  //Report function
  function void report();
  endfunction : report

  //Wait for reset task
  task wait_for_reset();
    @(posedge vif.rst)
  endtask : wait_for_reset

  //Wait for reset done task
  task wait_for_reset_done();
    wait(vif.rst == 1); 
    @(negedge vif.rst)
  endtask : wait_for_reset_done

  //Reset input signals task
  function void reset_input_signals();
    
  endfunction : reset_input_signals

  //Drive into pins task
  task drive_into_pins();
  endtask : drive_into_pins

  //Drive transfer task
  task drive_transfer();
  endtask : drive_transfer

  //Run task
  task run();
  endtask : run


endclass : wb_driver
