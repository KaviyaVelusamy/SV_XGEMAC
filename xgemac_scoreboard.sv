class xgemac_scoreboard;
  
  xgemac_tb_config h_cfg;
  mailbox#(xgemac_tx_pkt) tx_mbx;
  mailbox#(xgemac_rx_pkt) rx_mbx;
  mailbox#(bit)           rst_mbx;

  xgemac_tx_pkt exp_pkt_queue[$];

  string REPORT_TAG = "XGEMAC_SCOREBOARD";

  //Constructor
  function new(xgemac_tb_config h_cfg);

    this.h_cfg = h_cfg;

  endfunction : new

  //Build Function
  function void build();

    if(h_cfg.has_scbd)
    begin
      $display("%s : Build Function", REPORT_TAG);
    end

  endfunction : build

  //Connect Function
  function void connect();
    if(h_cfg.has_scbd)
    begin
      $display("%s : Connect Function", REPORT_TAG);
    end
  endfunction : connect

  //Report Function
  function void report();
    if(h_cfg.has_scbd)
    begin
      $display("%s : Report function", REPORT_TAG);
      if(exp_pkt_queue.size() != 0)
      begin
        $error("Expected Queue is not empty. Not received all outputs from the DUT. Expected Queue size = %0d", exp_pkt_queue.size());
      end
      if(h_cfg.test_status)
      begin
        $error("%s : Testcase failed", h_cfg.print_string);
      end
      else
      begin
        $display("%s : Testcase Passed", REPORT_TAG);
      end
    end
  endfunction : report

  //Run Task
  task run();
    if(h_cfg.has_scbd)
    begin
      $display("%s : Run Task", REPORT_TAG);
      fork
        begin
          wait_for_tx_pkt_and_calc_exp();
        end
        begin
          wait_for_rx_pkt();
        end
        begin
          wait_for_reset();
        end
      join_none
    end
  endtask : run

  //task wait for reset
  task wait_for_reset();
    bit rst_indicator;
    forever
    begin
      rst_mbx.get(rst_indicator);
      h_cfg.act_count += exp_pkt_queue.size();
      exp_pkt_queue.delete();
    end    
  endtask : wait_for_reset


  //Wait_for_tx_pkt_and_calc_exp Task
  task wait_for_tx_pkt_and_calc_exp();

    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] tx_mod_data;

    forever
      begin
        tx_mbx.get(h_tx_pkt);
        if(h_cfg.tx_trans_count > 7)
        begin
        if(h_tx_pkt.pkt_tx_mod != 0)
          begin
            tx_mod_data = h_tx_pkt.pkt_tx_data >> 8 * (8 - h_tx_pkt.pkt_tx_mod) & calc_tx_data_for_mod(h_tx_pkt.pkt_tx_mod);
            h_tx_pkt.pkt_tx_data = tx_mod_data;
          end
        end
        $cast(h_tx_cl_pkt, h_tx_pkt.clone());
        $display("From TX Monitor to Scoreboard");
        h_tx_cl_pkt.display();
        exp_pkt_queue.push_back(h_tx_cl_pkt);
      end

  endtask : wait_for_tx_pkt_and_calc_exp

  //Wait_for_rx_pkt
  task wait_for_rx_pkt();
    xgemac_rx_pkt h_rx_pkt, h_rx_cl_pkt;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] rx_mod_data;

    forever 
      begin
        rx_mbx.get(h_rx_pkt);
        if(h_cfg.tx_trans_count > 7)
        begin
        if(h_rx_pkt.pkt_rx_mod != 0)
          begin
            $display("Just before : PKT_RX_DATA : %0h", h_rx_pkt.pkt_rx_data);
            rx_mod_data = h_rx_pkt.pkt_rx_data  >> 8 * (8 - h_rx_pkt.pkt_rx_mod)  & calc_tx_data_for_mod(h_rx_pkt.pkt_rx_mod);
            $display("Just after : RX_MOD_DATA : %0h", rx_mod_data);
            h_rx_pkt.pkt_rx_data = rx_mod_data;
          end
        end
        $cast(h_rx_cl_pkt, h_rx_pkt.clone());
        $display("From RX Monitor to Scoreboard");
        h_rx_cl_pkt.display();
        check_exp_data_and_act_data(h_rx_cl_pkt);
        h_cfg.act_count++;
        
      /*  else
          begin
            check_exp_data_and_act_data_padding(h_rx_cl_pkt);
            h_cfg.act_count ++;
          end */
          $display("!!!!!!!!!!!!!!ACTUAL_COUNT %0d!!!!!!!!!!!!!!!!!", h_cfg.act_count);
       // h_cfg.act_count++;
      end
  endtask : wait_for_rx_pkt



  function bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] calc_tx_data_for_mod(bit[2:0] mod);
    bit [`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] res;
    
    res = 2 ** (mod * 8) - 1;
    return res;
  endfunction : calc_tx_data_for_mod

  
  //Check expected and actual data function
  function void check_exp_data_and_act_data(xgemac_rx_pkt h_rx_pkt);
    xgemac_tx_pkt h_tx_pkt;
    static int success_count = 0;
    if(exp_pkt_queue.size() > 0)
    begin
      h_tx_pkt = exp_pkt_queue.pop_front();
      //$display("&&&&&&&&&&&Queue size is not zero&&&&&&&&&&&&");
    end
    if(h_tx_pkt.pkt_tx_sop != h_rx_pkt.pkt_rx_sop)
      begin
        $error("TX_PKT_SOP not matched with RX_PKT_SOP"); 
        $error("PKT_TX_SOP : %0h != PKT_RX_SOP : %0h", h_tx_pkt.pkt_tx_sop, h_rx_pkt.pkt_rx_sop);
      end
    else
      begin
        $display("Test Passed");
        success_count ++;
      end
    if(h_cfg.check_inc_count == 7)
      begin
    if(h_tx_pkt.pkt_tx_data != h_rx_pkt.pkt_rx_data)
      begin
        $error("7777TX_PKT_DATA not matched with RX_PKT_DATA");
        $error("****PKT_TX_DATA : %0h != PKT_RX_DATA : %0h****", h_tx_pkt.pkt_tx_data, h_rx_pkt.pkt_rx_data);
      end
    else
      begin
        $display("Test Passed");
        success_count ++;
      end
    end
    else
    begin
      if(h_tx_pkt.pkt_tx_data != h_rx_pkt.pkt_rx_data)
      begin
        $error("TX_PKT_DATA not matched with RX_PKT_DATA");
        $error("****PKT_TX_DATA : %0h != PKT_RX_DATA : %0h****", h_tx_pkt.pkt_tx_data, h_rx_pkt.pkt_rx_data);
      end
    else
      begin
        $display("Test Passed");
        success_count ++;
      end

    end
    if(h_cfg.check_inc_count == 7)
    begin
    if(h_tx_pkt.pkt_tx_mod != h_rx_pkt.pkt_rx_mod)
      begin
        $error("7777TX_PKT_MOD not matched with RX_PKT_MOD");
        $error("****PKT_TX_MOD : %0h != PKT_RX_MOD = %0h****", h_tx_pkt.pkt_tx_mod, h_rx_pkt.pkt_rx_mod);
      end
    else
      begin
        $display("Test Passed");
        success_count++;
      end
    end
    else
    begin
      if(h_tx_pkt.pkt_tx_mod != h_rx_pkt.pkt_rx_mod)
      begin
        $error("TX_PKT_MOD not matched with RX_PKT_MOD");
        $error("****PKT_TX_MOD : %0h != PKT_RX_MOD = %0h****", h_tx_pkt.pkt_tx_mod, h_rx_pkt.pkt_rx_mod);
      end
    else
      begin
        $display("Test Passed");
        success_count++;
      end

    end
    if(h_tx_pkt.pkt_tx_eop != h_rx_pkt.pkt_rx_eop)
      begin
        $error("TX_PKT_EOP not matched with RX_PKT_EOP");
        $error("****PKT_TX_EOP : %0h != PKT_RX_EOP : %0h****", h_tx_pkt.pkt_tx_eop, h_rx_pkt.pkt_rx_eop);
      end
    else
      begin
          $display("Test Passed");
          success_count++;
      end
    h_cfg.check_inc_count++;
    $display("+++++++++++++SUCCESS_COUNT : %0d++++++++++++++++",success_count); 
  endfunction : check_exp_data_and_act_data

/*
  //Check expected data and actual data for padding feature function
  function void check_exp_data_and_act_data_padding(xgemac_rx_pkt h_rx_pkt);
    xgemac_tx_pkt h_tx_pkt;

    
    h_cfg.pad_act_count ++;
  
    if(h_cfg.pad_act_count < h_cfg.tx_trans_count)
    begin
    h_tx_pkt = exp_pkt_queue.pop_front();

    if(h_tx_pkt.pkt_tx_sop != h_rx_pkt.pkt_rx_sop)
      begin
         $error("TX_PKT_SOP not matched with RX_PKT_SOP in padding feature"); 
      end
    else
      begin
        $display("Padding test passed");
      end
    if(h_tx_pkt.pkt_tx_data != h_rx_pkt.pkt_rx_data)
      begin
        $error("TX_PKT_DATA not matched with RX_PKT_DATA in padding feature"); 
      end
    else
      begin
        $display("Padding test passed");
      end
    if(h_tx_pkt.pkt_tx_mod != h_rx_pkt.pkt_rx_mod)
      begin
        $error("TX_PKT_MOD not matched with RX_PKT_MOD in padding feature"); 
      end
    else
      begin
        $display("Padding test passed");
      end
    if(h_tx_pkt.pkt_tx_eop != h_rx_pkt.pkt_rx_eop)
      begin
        $error("TX_PKT_EOP not matched with RX_PKT_EOP in padding feature"); 
      end
    else
      begin
        $display("Padding test passed");
        $display("++++++++++Pad_ACT_COUNT %0d+++++++++", h_cfg.pad_act_count);
      end
    end
    
    else if(h_cfg.pad_act_count == h_cfg.tx_trans_count )
    begin
      if(exp_pkt_queue.size() > 0)
      begin
        h_tx_pkt = exp_pkt_queue.pop_front();
      end
    if(h_tx_pkt.pkt_tx_sop != h_rx_pkt.pkt_rx_sop)
      begin
        $error("TX_PKT_SOP not matched with RX_PKT_SOP in padding feature"); 
      end
    else
      begin
        $display("Padding test passed");
      end
    if(h_tx_pkt.pkt_tx_data != h_rx_pkt.pkt_rx_data)
      begin
        $error("TX_PKT_DATA not matched with RX_PKT_DATA in padding feature"); 
        $error("Previous data, PKT_TX_DATA : %0h, PKT_RX_DATA : %0h", h_tx_pkt.pkt_tx_data, h_rx_pkt.pkt_rx_data);
      end
    else
      begin
        $display("Padding test passed");
      end
    if(h_tx_pkt.pkt_tx_mod != 0)
    begin
    if(h_tx_pkt.pkt_tx_mod == h_rx_pkt.pkt_rx_mod)
      begin
        $error("TX_PKT_MOD not matched with RX_PKT_MOD in padding feature");    
      end
      else
      begin
        $display("Padding test passed");
      end
    end
    if(h_tx_pkt.pkt_tx_eop == h_rx_pkt.pkt_rx_eop)
      begin
        $error("TX_PKT_EOP not matched with RX_PKT_EOP in padding feature"); 
      end
    else
      begin
        $display("Padding test passed");
        $display("++++++++++Pad_ACT_COUNT %0d+++++++++", h_cfg.pad_act_count);

      end
    end

    else if(h_cfg.pad_act_count > h_cfg.tx_trans_count)
    begin
      if(h_rx_pkt.pkt_rx_sop == 1)
      begin
        $error("RX_PKT_SOP is not valid in last packet of padding");
      end
      else
      begin
        $display("Padding test passed");
      end
      if(h_cfg.pad_act_count != 8)
      begin
      if(h_rx_pkt.pkt_rx_data != 0)
      begin
        $error("RX_PKT_DATA is not valid in last packet of padding %0h", h_rx_pkt.pkt_rx_data);
        $display("++++++++++Pad_ACT_COUNT %0d+++++++++", h_cfg.pad_act_count);

      end
      else
      begin
        $display("Padding test passed");
      end
    end
      if(h_cfg.pad_act_count == 8)
      begin
      if(h_rx_pkt.pkt_rx_mod != 4)
      begin
        $error("RX_PKT_MOD is not valid in last packet of padding");
        $display("++++++++++Pad_ACT_COUNT %0d+++++++++", h_cfg.pad_act_count);

      end
      else
      begin
        $display("Padding test passed");
      end
      end
      if(h_cfg.pad_act_count == 8)
      begin
      if(h_rx_pkt.pkt_rx_eop != 1)
      begin
        $error("RX_PKT_EOP is not valid in last packet of padding");
        $display("++++++++++Pad_ACT_COUNT %0d+++++++++", h_cfg.pad_act_count);

      end
      else
      begin
        $display("Padding test passed");
      end
    end

    end


  endfunction : check_exp_data_and_act_data_padding
*/

endclass : xgemac_scoreboard
