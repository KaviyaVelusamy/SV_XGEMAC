class xgemac_scoreboard;
  
  xgemac_tb_config h_cfg;
  mailbox#(xgemac_tx_pkt) tx_mbx;
  mailbox#(xgemac_rx_pkt) rx_mbx;
  mailbox#(bit)           rst_mbx;

  bit[1:0] sop_flag = 0;

  xgemac_tx_pkt exp_pkt_queue[$];
  xgemac_functional_coverage h_fcov;

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
      h_fcov = new();
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
      h_fcov.display();
    end
  endfunction : report

  //Run Task
  task run();
    process p[3];
    if(h_cfg.has_scbd) begin
      forever begin
      $display("%s : Run Task", REPORT_TAG);
      fork
        begin
          p[0] = process :: self();
          wait_for_tx_pkt_and_calc_exp();
        end
        begin
          p[1] = process :: self();
          wait_for_rx_pkt();
        end
        begin
          p[2] = process :: self();
          wait_for_reset();
        end
      join_any

      foreach(p[i])
      begin
        if(p[i] != null)
          p[i].kill();
      end
    end
  end
  endtask : run

  //task wait for reset
  task wait_for_reset();
    bit rst_indicator;
      rst_mbx.get(rst_indicator);
      $display("_____________________EXPECTED QUEUE SIZE : %0d__________________ ACtual_count : %0d", exp_pkt_queue.size(), h_cfg.act_count);
      h_cfg.act_count += exp_pkt_queue.size();
      exp_pkt_queue.delete();
      h_cfg.check_inc_count = 0;
      sop_flag=0;
  endtask : wait_for_reset


  function void push_dummy_data_in_expected_queue(int tx_trans_count);
    xgemac_tx_pkt h_tx_pkt;
    repeat(8 - tx_trans_count - 1) begin
      h_tx_pkt = new();
      exp_pkt_queue.push_back(h_tx_pkt);
    end
    h_tx_pkt = new();
    h_tx_pkt.pkt_tx_mod = 'h4;
    h_tx_pkt.pkt_tx_eop = 'h1;
    exp_pkt_queue.push_back(h_tx_pkt);
  endfunction: push_dummy_data_in_expected_queue


  //Wait_for_tx_pkt_and_calc_exp Task
  task wait_for_tx_pkt_and_calc_exp();

    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;
    int tx_count, trans_tx_count;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] tx_mod_data;
    int temp_count = 0;
    forever
      begin
        tx_mbx.get(h_tx_pkt);
        tx_count++;
        $cast(h_tx_cl_pkt, h_tx_pkt.clone());
        h_fcov.tx_packet_in_sample(h_tx_cl_pkt);

        if(h_tx_cl_pkt.pkt_tx_sop == 1)
        begin
          if(sop_flag == 0)
          begin
            sop_flag = 1;
          end
          else if(sop_flag == 1)
          begin
            sop_flag = 3;
            exp_pkt_queue.delete();
          end
        end
        else if(sop_flag == 1 && h_tx_cl_pkt.pkt_tx_eop == 1)
        begin
          sop_flag = 2;
        end
        if(sop_flag != 3 && sop_flag != 0)
        begin
        if(h_tx_cl_pkt.pkt_tx_eop == 1) 
        begin
        sop_flag = 0;
        trans_tx_count = tx_count;
        tx_count=0;
        end
        if(h_tx_cl_pkt.pkt_tx_eop == 1 && trans_tx_count < 8) 
        begin
          h_tx_cl_pkt.pkt_tx_mod = 'h0;
          h_tx_cl_pkt.pkt_tx_eop = 'h0;
          exp_pkt_queue.push_back(h_tx_cl_pkt);
          push_dummy_data_in_expected_queue(trans_tx_count);
          h_cfg.act_count -= 8 - trans_tx_count;
        end
        else if(h_tx_cl_pkt.pkt_tx_eop == 1 && trans_tx_count == 8 && h_tx_cl_pkt.pkt_tx_mod <4 && h_tx_cl_pkt.pkt_tx_mod !=0)    begin
          h_tx_cl_pkt.pkt_tx_mod = 'h4;
          exp_pkt_queue.push_back(h_tx_cl_pkt);
        end
        else 
        begin
          exp_pkt_queue.push_back(h_tx_cl_pkt);
        end
    end
   end
      
  endtask : wait_for_tx_pkt_and_calc_exp

  //Wait_for_rx_pkt
  task wait_for_rx_pkt();
    xgemac_rx_pkt h_rx_pkt, h_rx_cl_pkt;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] rx_mod_data;

    forever 
      begin
        rx_mbx.get(h_rx_pkt);
        h_fcov.rx_packet_in_sample(h_rx_pkt);
        $cast(h_rx_cl_pkt, h_rx_pkt.clone());
        $display("From RX Monitor to Scoreboard : ");
        h_rx_cl_pkt.display();
        check_exp_data_and_act_data(h_rx_cl_pkt);
        h_cfg.act_count++;
        
        //$display("!!!!!!!!!!!!!!ACTUAL_COUNT %0d!!!!!!!!!!!!!!!!!", h_cfg.act_count);
      end
  endtask : wait_for_rx_pkt

  
  function bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] calc_mod(bit[`XGEMAC_TX_RX_MOD - 1 : 0] mod);
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] res;
    res = 2**(8*mod) - 1;
    res = {<<{res}};
    return res;
  endfunction: calc_mod
  
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
        //$display("Test Passed");
        success_count ++;
      end
    
    if(h_rx_pkt.pkt_rx_mod == 0 ? h_rx_pkt.pkt_rx_data != h_tx_pkt.pkt_tx_data : h_rx_pkt.pkt_rx_data & calc_mod(h_rx_pkt.pkt_rx_mod) != h_tx_pkt.pkt_tx_data & calc_mod(h_tx_pkt.pkt_tx_mod)) 
       begin
        $error("DATA not matched");
      end
    else 
    begin
      success_count++;
    end

    if(h_tx_pkt.pkt_tx_eop == 1 && h_tx_pkt.pkt_tx_mod != h_rx_pkt.pkt_rx_mod)
      begin
        $error("TX_PKT_MOD not matched with RX_PKT_MOD");
        $error("****PKT_TX_MOD : %0h != PKT_RX_MOD = %0h****", h_tx_pkt.pkt_tx_mod, h_rx_pkt.pkt_rx_mod);
      end
    else
      begin
        //$display("Test Passed");
        success_count++;
      end

    if(h_tx_pkt.pkt_tx_eop != h_rx_pkt.pkt_rx_eop)
      begin
        $error("TX_PKT_EOP not matched with RX_PKT_EOP");
        $error("****PKT_TX_EOP : %0h != PKT_RX_EOP : %0h****", h_tx_pkt.pkt_tx_eop, h_rx_pkt.pkt_rx_eop);
      end
    else
      begin
          //$display("Test Passed");
          success_count++;
      end

    $display("+++++++++++++actual_COUNT : %0d++++++++++++++++",h_cfg.act_count); 
  endfunction : check_exp_data_and_act_data

endclass : xgemac_scoreboard






/*class xgemac_scoreboard;
  
  xgemac_tb_config h_cfg;
  mailbox#(xgemac_tx_pkt) tx_mbx;
  mailbox#(xgemac_rx_pkt) rx_mbx;
  mailbox#(bit)           rst_mbx;

  xgemac_tx_pkt exp_pkt_queue[$];
  xgemac_functional_coverage h_fcov;

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
      h_fcov = new();
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
      h_fcov.display();
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
      $display("_____________________EXPECTED QUEUE SIZE : %0d__________________ ACtual_count : %0d", exp_pkt_queue.size(), h_cfg.act_count);
      h_cfg.act_count += exp_pkt_queue.size();
      exp_pkt_queue.delete();
      h_cfg.check_inc_count = 0;
    end    
  endtask : wait_for_reset


  //Wait_for_tx_pkt_and_calc_exp Task
  task wait_for_tx_pkt_and_calc_exp();

    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] tx_mod_data;
    int temp_count = 0;
    forever
      begin
        tx_mbx.get(h_tx_pkt);
        if(h_cfg.tx_trans_count < 8)
        begin
        temp_count++;
        end
        h_cfg.check_inc_count++;
        if(h_cfg.tx_trans_count > 7)
        begin
        if(h_tx_pkt.pkt_tx_mod != 0)
          begin
            tx_mod_data = h_tx_pkt.pkt_tx_data >> 8 * (8 - h_tx_pkt.pkt_tx_mod) & calc_tx_data_for_mod(h_tx_pkt.pkt_tx_mod);
            h_tx_pkt.pkt_tx_data = tx_mod_data;
          end
          $cast(h_tx_cl_pkt, h_tx_pkt.clone());
        
        $display("From TX Monitor to Scoreboard : count : %0d", temp_count);
        h_tx_cl_pkt.display();
        exp_pkt_queue.push_back(h_tx_cl_pkt);

        end
       
        else
        begin
        if(temp_count % 8 == h_cfg.tx_trans_count)
        begin
        int pad_packet_count, pad_byte_count;

        pad_byte_count = `MIN_PADDING_BYTE - (h_cfg.tx_trans_count * `BYTE);

        pad_packet_count = (pad_byte_count / `BYTE) + 1;

        $display("==========================Inside this========================");
        $display("BeforeeeeeeeeActual Count : %0dBeforeeeeeeeee", h_cfg.act_count);
 
        h_cfg.act_count = h_cfg.act_count - pad_packet_count;

        $display("AfterrrrrrrrActual Count : %0dAfterrrrrrrr", h_cfg.act_count);


        $cast(h_tx_cl_pkt, h_tx_pkt.clone());
        h_tx_cl_pkt.pkt_tx_eop = 0;
        $display("From TX Monitor to Scoreboard : count : %0d", temp_count);
        h_tx_cl_pkt.display();
        exp_pkt_queue.push_back(h_tx_cl_pkt);

        
        repeat(pad_packet_count)
        begin
          h_tx_pkt = new();
          h_cfg.check_inc_count++;
          if(h_cfg.check_inc_count == 8)
          begin
            h_tx_pkt.pkt_tx_eop = 'h1;
            h_tx_pkt.pkt_tx_mod = 'h4;
            temp_count = 0;
            h_cfg.check_inc_count = 0;
 
          end
          exp_pkt_queue.push_back(h_tx_pkt);

        end
        
        end
        else
        begin
          $cast(h_tx_cl_pkt, h_tx_pkt.clone());
        
        $display("From TX Monitor to Scoreboard : count : %0d", temp_count);
        h_tx_cl_pkt.display();
        exp_pkt_queue.push_back(h_tx_cl_pkt);

        end

      end
      end
    

  endtask : wait_for_tx_pkt_and_calc_exp

  //Wait_for_rx_pkt
  task wait_for_rx_pkt();
    xgemac_rx_pkt h_rx_pkt, h_rx_cl_pkt;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] rx_mod_data;

    forever 
      begin
        rx_mbx.get(h_rx_pkt);
        h_fcov.packet_in_sample(h_rx_pkt);
        if(h_cfg.tx_trans_count > 7)
        begin
        if(h_rx_pkt.pkt_rx_mod != 0)
          begin
            $display("Just before : PKT_RX_DATA : %0h, count : %0d", h_rx_pkt.pkt_rx_data, h_cfg.tx_trans_count);
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
        
        $display("!!!!!!!!!!!!!!ACTUAL_COUNT %0d!!!!!!!!!!!!!!!!!", h_cfg.act_count);
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
    static int check_count = 0;
    if(exp_pkt_queue.size() > 0)
    begin
      h_tx_pkt = exp_pkt_queue.pop_front();
      $display("&&&&&&&&&&&Queue size is not zero&&&&&&&&&&&&");
    end

    if(h_tx_pkt.pkt_tx_sop != h_rx_pkt.pkt_rx_sop)
      begin
        $error("TX_PKT_SOP not matched with RX_PKT_SOP, count : %0d", check_count); 
        $error("PKT_TX_SOP : %0h != PKT_RX_SOP : %0h", h_tx_pkt.pkt_tx_sop, h_rx_pkt.pkt_rx_sop);
      end
    else
      begin
        $display("Test Passed");
        success_count ++;
      end
    
   /* if(h_cfg.tx_trans_count < 8)
    begin
      if(h_cfg.act_count % 8 == h_cfg.tx_trans_count - 1)
      begin
        if(h_tx_pkt.pkt_tx_data == h_rx_pkt.pkt_rx_data)
        begin
          $error("))))))TX_PKT_DATA not matched with RX_PKT_DATA, count : %0d, actual_count : %0d", check_count, h_cfg.act_count);
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
          $error("wwwwwwTX_PKT_DATA not matched with RX_PKT_DATA, count : %0d, actual_count : %0d", check_count, h_cfg.act_count);
          $error("****PKT_TX_DATA : %0h != PKT_RX_DATA : %0h****", h_tx_pkt.pkt_tx_data, h_rx_pkt.pkt_rx_data);
        end
      else
        begin
          $display("Test Passed");
          success_count ++;
        end
      end
    end
    else
    begin *//*
      if(h_cfg.tx_trans_count >= 8)
      begin
      if(h_tx_pkt.pkt_tx_data != h_rx_pkt.pkt_rx_data)
      begin
        $error("555555TX_PKT_DATA not matched with RX_PKT_DATA, count : %0d", check_count);
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
      if(h_rx_pkt.pkt_rx_mod == 4)
      begin
        if(h_tx_pkt.pkt_tx_data == h_rx_pkt.pkt_rx_data)
        begin
          $error("555555TX_PKT_DATA not matched with RX_PKT_DATA, count : %0d", check_count);
          $error("****PKT_TX_DATA : %0h != PKT_RX_DATA : %0h****", h_tx_pkt.pkt_tx_data, h_rx_pkt.pkt_rx_data);
        end
         else
      begin
        $display("Test Passed");
        success_count ++;
      end
    end
      end

 //   end

    if(h_tx_pkt.pkt_tx_mod != h_rx_pkt.pkt_rx_mod)
      begin
        $error("TX_PKT_MOD not matched with RX_PKT_MOD, count : %0d", check_count);
        $error("****PKT_TX_MOD : %0h != PKT_RX_MOD = %0h****", h_tx_pkt.pkt_tx_mod, h_rx_pkt.pkt_rx_mod);
      end
    else
      begin
        $display("Test Passed");
        success_count++;
      end

    if(h_tx_pkt.pkt_tx_eop != h_rx_pkt.pkt_rx_eop)
      begin
        $error("TX_PKT_EOP not matched with RX_PKT_EOP, count : %0d", check_count);
        $error("****PKT_TX_EOP : %0h != PKT_RX_EOP : %0h****", h_tx_pkt.pkt_tx_eop, h_rx_pkt.pkt_rx_eop);
      end
    else
      begin
          $display("Test Passed");
          success_count++;
      end

      check_count ++;
    $display("+++++++++++++SUCCESS_COUNT : %0d++++++++++++++++",success_count); 
  endfunction : check_exp_data_and_act_data

endclass : xgemac_scoreboard



*/
