class xgemac_base_test;

  xgemac_tb_config h_cfg;
  xgemac_env h_env;
  string REPORT_TAG;

  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  function void build();
    $display("Inside %s build", REPORT_TAG);
    if(h_cfg.has_env == 1)
      begin
        h_env = new(h_cfg);
        h_env.build();
        set_test_specific_configurations();
      end
  endfunction : build

  function void connect();
    $display("Inside %s Connect", REPORT_TAG);
    if(h_cfg.has_env == 1)
      begin
        h_env.connect();
       end
  endfunction : connect

  task run();
    $display("Inside %s Run", REPORT_TAG);
    if(h_cfg.has_env == 1)
      begin
        h_env.run();
        fork
        give_stimulus();
        wait_for_finish();
        join
      end
  endtask : run

  function void report();
    $display("Inside %s Report", REPORT_TAG);
    h_env.report();
  endfunction : report


  virtual function void set_test_specific_configurations();

  endfunction : set_test_specific_configurations

  virtual task give_stimulus();

  endtask : give_stimulus

  //test ending mechanism
  task wait_for_finish();
    process p[2];

    fork
      begin
        p[0] = process :: self();
        wait(h_cfg.trans_count == h_cfg.act_count);
        $display("Trans count %0d == Actual count %0d", h_cfg.trans_count, h_cfg.act_count);
        
      end
      begin
        p[1] = process :: self();
        #(`TIMEOUT * 1ns);
        $error("Timeout occured");
      end
    join_any

    foreach(p[i])
      begin
        if(p[i] != null)
          p[i].kill();
      end

  endtask : wait_for_finish


endclass : xgemac_base_test


class xgemac_direct_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
    REPORT_TAG = "DIRECT_TEST";
  endfunction : new


  function void set_test_specific_configurations();
    h_cfg.trans_count = 20;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_direct_stimulus_and_put_into_mbx();
  endtask : give_stimulus


endclass : xgemac_direct_test


class xgemac_incremental_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
    REPORT_TAG = "INCREMENTAL_TEST";
  endfunction : new

  function void set_test_specific_configurations();
    h_cfg.trans_count     = 20;
    h_cfg.inc_trans_count = 4;
    h_cfg.inc_start_value = 'h1212_3121_8021_310A;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_incremental_stimulus_and_put_into_mbx();
  endtask : give_stimulus

endclass : xgemac_incremental_test


// Fully random test
class xgemac_fully_random_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
    REPORT_TAG = "FULLY_RANDOM_TEST";
  endfunction : new

  function void set_test_specific_configurations();
     h_cfg.trans_count = $urandom_range(2,99); 
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_random_stimulus_and_put_into_mbx();   
  endtask : give_stimulus

endclass : xgemac_fully_random_test


class xgemac_tx_reset_test extends xgemac_direct_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    super.set_test_specific_configurations();
  endfunction : set_test_specific_configurations

  task give_stimulus();
    process p[2];
    fork
    begin
      p[0] = process :: self();
      super.give_stimulus();      
    end
    begin
      p[1] = process :: self();
      #100_000;
      $display("[%0t] >>> PUTTING RESET INTO MAILBOX <<<", $time);
      fork
      h_env.h_tx_rx_rst_gen.generate_reset_indicator_and_put_into_mbx();
      h_env.h_xgmii_rst_gen.generate_reset_indicator_and_put_into_mbx();
      join_none
    end
  join_any

  foreach(p[i])
  begin
    if(p[i] != null)
      p[i].kill();
  end
  super.give_stimulus();

endtask : give_stimulus

endclass : xgemac_tx_reset_test



class xgemac_tx_inc_reset_test extends xgemac_incremental_test;

  xgemac_incremental_test h_inc_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    super.set_test_specific_configurations();
  endfunction : set_test_specific_configurations

  task give_stimulus();
    process p[2];
    fork
    begin
      p[0] = process :: self();
      h_env.h_xgemac_gen.generate_incremental_stimulus_and_put_into_mbx();      
    end
    begin
      p[1] = process :: self();
      #160ns;
      $display("[%0t] >>> PUTTING RESET INTO MAILBOX <<<", $time);
      fork
      h_env.h_tx_rx_rst_gen.generate_reset_indicator_and_put_into_mbx();
      h_env.h_xgmii_rst_gen.generate_reset_indicator_and_put_into_mbx();
      join_none     
    end
    join_any
    
    foreach(p[i]) begin
      if(p[i]!=null) begin
        p[i].kill();
      end
    end
    h_env.h_xgemac_gen.generate_incremental_stimulus_and_put_into_mbx();

endtask : give_stimulus

endclass : xgemac_tx_inc_reset_test


class xgemac_tx_random_reset_test extends xgemac_fully_random_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    super.set_test_specific_configurations();
  endfunction : set_test_specific_configurations

  task give_stimulus();
    process p[2];
    fork
    begin
      p[0] = process :: self();
      super.give_stimulus();      
    end
    begin
      p[1] = process :: self();
      #55_000;
      $display("[%0t] >>> PUTTING RESET INTO MAILBOX <<<", $time);
      fork
      h_env.h_tx_rx_rst_gen.generate_reset_indicator_and_put_into_mbx();
      h_env.h_xgmii_rst_gen.generate_reset_indicator_and_put_into_mbx();
    join_none
    end
  join_any
  foreach(p[i])
  begin
    if(p[i] != null)
      p[i].kill();
  end
  super.give_stimulus();
endtask : give_stimulus


endclass : xgemac_tx_random_reset_test

class xgemac_rx_reset_test extends xgemac_direct_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
    REPORT_TAG = "RX_RESET_TEST";
  endfunction : new

  function void set_test_specific_configurations();
    super.set_test_specific_configurations();
  endfunction : set_test_specific_configurations

  task give_stimulus();
    process p[2];
    fork
    begin
      p[0] = process :: self();
      super.give_stimulus();      
    end
    begin
      p[1] = process :: self();
      #475ns;
      $display("[%0t] >>> PUTTING RESET INTO MAILBOX <<<", $time);
      h_env.h_tx_rx_rst_gen.generate_reset_indicator_and_put_into_mbx();
      h_env.h_xgmii_rst_gen.generate_reset_indicator_and_put_into_mbx();    
    end
  join_none

  foreach(p[i])
  begin
    if(p[i] != null)
    begin
      p[i].kill();
    end
  end

endtask : give_stimulus

endclass : xgemac_rx_reset_test


class xgemac_without_sop_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    h_cfg.trans_count = 2;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_without_sop_error_stimulus_and_put_into_mbx();
    #600ns;
    h_cfg.act_count = h_cfg.trans_count;

  endtask : give_stimulus

endclass : xgemac_without_sop_test


class xgemac_without_eop_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    h_cfg.trans_count = 2;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_without_eop_error_stimulus_and_put_into_mbx();
    #600ns;
    h_cfg.act_count = h_cfg.trans_count;

  endtask : give_stimulus

endclass : xgemac_without_eop_test


class xgemac_without_sop_eop_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    h_cfg.trans_count = 2;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_without_sop_eop_error_stimulus_and_put_into_mbx();
    #600ns;
    h_cfg.act_count = h_cfg.trans_count;

  endtask : give_stimulus

endclass : xgemac_without_sop_eop_test


class wishbone_read_tx_enable_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();

  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.wb_gen.read_tx_enable();

  endtask : give_stimulus


endclass : wishbone_read_tx_enable_test


