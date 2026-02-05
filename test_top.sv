program test_top(xgemac_clk_interface tx_rx_clk, 
                 xgemac_clk_interface wb_clk,
                 xgemac_clk_interface xgmii_clk, 
                 xgemac_rst_interface tx_rx_rst,
                 xgemac_rst_interface wb_rst,
                 xgemac_rst_interface xgmii_rst,
                 xgemac_tx_interface tx_intf,
                 xgemac_rx_interface rx_intf,
                 xgemac_wb_interface wb_intf,
                 xgmii_tx_rx_interface xgmii_intf);


    //xgemac_tb_config instance 
    xgemac_tb_config h_cfg;

    //base test instance
    xgemac_base_test h_base_test;
  

    initial begin
        $display("This is test top");
    end

    initial begin
        assign_interfaces();
        create_test_and_initiate_components();
      end
      
    function void assign_interfaces();
        h_cfg = new();
        h_cfg.tx_rx_clk_vif = tx_rx_clk;
        h_cfg.wb_clk_vif = wb_clk;
        h_cfg.xgmii_clk_vif = xgmii_clk;
        h_cfg.tx_rx_rst_vif = tx_rx_rst;
        h_cfg.wb_rst_vif = wb_rst;
        h_cfg.xgmii_rst_vif = xgmii_rst;
        h_cfg.tx_vif = tx_intf;
        h_cfg.rx_vif = rx_intf;
        h_cfg.wb_vif = wb_intf;
        h_cfg.xgmii_vif = xgmii_intf;
    endfunction : assign_interfaces

    task create_test_and_initiate_components();
      string test_name;
      if(!$value$plusargs("TEST_NAME=%s", test_name))
        begin
          $fatal("Not received testname as argument, Testname : %s", test_name);
        end
      else
        begin
            $display("Received Testname : %0s", test_name);
        end

      case(test_name)
        "xgemac_base_test"                 : h_base_test = new(h_cfg);
        "xgemac_direct_test"               : begin
                                               xgemac_direct_test h_dir_test;
                                               h_dir_test = new(h_cfg);
                                               $cast(h_base_test, h_dir_test);
                                             end

        "xgemac_incremental_test"          : begin
                                               xgemac_incremental_test h_inc_test;
                                               h_inc_test = new(h_cfg);
                                               $cast(h_base_test, h_inc_test);
                                             end

        "xgemac_fully_random_test"         : begin
                                               xgemac_fully_random_test h_f_rand_test;
                                               h_f_rand_test = new(h_cfg);
                                               $cast(h_base_test, h_f_rand_test);
                                             end


        "xgemac_tx_reset_test"             : begin
                                               xgemac_tx_reset_test h_rst_test;
                                               h_rst_test = new(h_cfg);
                                               $cast(h_base_test, h_rst_test);
                                             end

        "xgemac_tx_inc_reset_test"         : begin
                                               xgemac_tx_inc_reset_test h_rst_test;
                                               h_rst_test = new(h_cfg);
                                               $cast(h_base_test, h_rst_test);
                                             end

        "xgemac_tx_random_reset_test"      : begin
                                               xgemac_tx_random_reset_test h_rst_test;
                                               h_rst_test = new(h_cfg);
                                               $cast(h_base_test, h_rst_test);
                                             end

        "xgemac_rx_reset_test"              : begin
                                               xgemac_rx_reset_test h_rst_test;
                                               h_rst_test = new(h_cfg);
                                               $cast(h_base_test, h_rst_test);
                                             end

        "xgemac_without_sop_test"           : begin
                                               xgemac_without_sop_test h_sop_test;
                                               h_sop_test = new(h_cfg);
                                               $cast(h_base_test, h_sop_test);
                                             end

        "xgemac_without_eop_test"           : begin
                                               xgemac_without_eop_test h_eop_test;
                                               h_eop_test = new(h_cfg);
                                               $cast(h_base_test, h_eop_test);
                                             end

        "xgemac_without_sop_eop_test"       : begin
                                               xgemac_without_sop_eop_test h_sop_eop_test;
                                               h_sop_eop_test = new(h_cfg);
                                               $cast(h_base_test, h_sop_eop_test);
                                             end



        "wishbone_read_tx_enable_test"     : begin
                                               wishbone_read_tx_enable_test h_wb_test;
                                               h_wb_test = new(h_cfg);
                                               $cast(h_base_test, h_wb_test);
                                             end


                                               

      endcase

      h_base_test.build();
      h_base_test.connect();
      h_base_test.run();
      h_base_test.report();

    endtask : create_test_and_initiate_components


endprogram : test_top
