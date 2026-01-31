class xgemac_base_test;

  xgemac_tb_config h_cfg;
  xgemac_env h_env;
  string REPORT_TAG;

  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  function void build();
    $display("This is base test build");
    if(h_cfg.has_env == 1)
      begin
        h_env = new(h_cfg);
        h_env.build();
        set_test_specific_configurations();
      end
  endfunction : build

  function void connect();
    $display("This is base test connect");
    if(h_cfg.has_env == 1)
      begin
        h_env.connect();
       end
  endfunction : connect

  task run();
    $display("This is base test run");
    if(h_cfg.has_env == 1)
      begin
        h_env.run();
        give_stimulus();
        wait_for_finish();
      end
  endtask : run

  function void report();
    $display("This is base test report");
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
  endfunction : new


  function void set_test_specific_configurations();
    h_cfg.trans_count = 8;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_direct_stimulus_and_put_into_mbx();
  endtask : give_stimulus


endclass : xgemac_direct_test


class xgemac_incremental_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    h_cfg.trans_count     = 20;
    h_cfg.inc_trans_count = 2;
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
  endfunction : new

  function void set_test_specific_configurations();
     h_cfg.trans_count = $urandom_range(0,25); 
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_random_stimulus_and_put_into_mbx();   
  endtask : give_stimulus

endclass : xgemac_fully_random_test

class xgemac_padding_test extends xgemac_base_test;

  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    h_cfg.trans_count = 7;
  endfunction : set_test_specific_configurations

  task give_stimulus();
    h_env.h_xgemac_gen.generate_padding_stimulus_and_put_into_mbx();
  endtask : give_stimulus

endclass : xgemac_padding_test

class xgemac_reset_test extends xgemac_direct_test;

  xgemac_direct_test h_dir_test;
  function new(xgemac_tb_config h_cfg);
    super.new(h_cfg);
  endfunction : new

  function void set_test_specific_configurations();
    super.set_test_specific_configurations();
  endfunction : set_test_specific_configurations

  task give_stimulus();
    fork
    begin
      super.give_stimulus();      
    end
    begin
      #55_000;
      $display("[%0t] >>> PUTTING RESET INTO MAILBOX <<<", $time);
      h_env.h_tx_rx_rst_gen.mbx.put(1);
    end
   join
endtask : give_stimulus


endclass : xgemac_reset_test


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


