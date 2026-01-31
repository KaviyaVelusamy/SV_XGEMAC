class xgemac_generator;

  mailbox#(xgemac_tx_pkt) mbx;
  xgemac_tb_config h_cfg;
  //xgemac_tx_pkt h_tx_pkt;
  string REPORT_TAG = "XGEMAC_SCORBOARD";


  //Constructor
  function new(xgemac_tb_config h_cfg);
    this.h_cfg = h_cfg;
  endfunction : new

  //Build Function
  function void build();
    mbx = new(1);
  endfunction : build

  //Connect Function
  function void connect();
  endfunction : connect 

  function void report();
  endfunction : report

 
  //Generate Direct Stimulus and Put into Mailbox Task
  task generate_direct_stimulus_and_put_into_mbx();

    int unsigned count;
    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;

    
    $display("~~~~~~~~~~~~~H_CFG.ACT_COUNT : %0d~~~~~~~~~~~~", h_cfg.act_count);

    if(h_cfg.trans_count < 8)
    begin
    int pad_packet_count, pad_byte_count;

    pad_byte_count = `MIN_PADDING_BYTE - (h_cfg.trans_count * `BYTE);

    pad_packet_count = (pad_byte_count / `BYTE) + 1;
 
    h_cfg.act_count = h_cfg.act_count - pad_packet_count;

    h_cfg.tx_trans_count = h_cfg.trans_count;

    h_cfg.check_inc_count = 0;

    for(int i = 1 ; i <= 8; i++)
      begin
        h_tx_pkt = new();

        h_tx_pkt.pkt_tx_sop = (i == 1) ? 1 : 0;
        h_tx_pkt.pkt_tx_eop = (i == 8) ? 1 : 0;
        h_tx_pkt.pkt_tx_mod = (i == 8) ? 0 : 0;

        if(i <= h_cfg.trans_count)
        begin
          h_tx_pkt.pkt_tx_data = `XGEMAC_TX_RX_DATA_WIDTH'h AAAA_BBBB_CCCC_DDDD;
        end
        else
        begin
          h_tx_pkt.pkt_tx_data = 0;
        end

        $cast(h_tx_cl_pkt, h_tx_pkt.clone());
      
        mbx.put(h_tx_cl_pkt);
      end
    end
    else
    begin
      h_cfg.tx_trans_count = h_cfg.trans_count;
      for(int i = 1; i <= h_cfg.trans_count; i++)
      begin
        h_tx_pkt = new();

        h_tx_pkt.pkt_tx_data = `XGEMAC_TX_RX_DATA_WIDTH'h AAAA_BBBB_CCCC_DDDD;
        h_tx_pkt.pkt_tx_sop = (i == 1) ? 1 : 0;
        h_tx_pkt.pkt_tx_eop = (i == h_cfg.trans_count) ? 1 : 0;
        h_tx_pkt.pkt_tx_mod = (i == h_cfg.trans_count) ? 0 : 0;
      
        $cast(h_tx_cl_pkt, h_tx_pkt.clone());
        mbx.put(h_tx_pkt);

      end
    end
  endtask : generate_direct_stimulus_and_put_into_mbx

  //Generate Incremental Stimulus and put into Mailbox
  task generate_incremental_stimulus_and_put_into_mbx();

    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;

    int copy_trans_count;
    int current_pass;
    int start_value;

    int temp_loop_count = 0;

    copy_trans_count = h_cfg.trans_count;
    start_value      = h_cfg.inc_start_value;

    h_cfg.tx_trans_count = h_cfg.inc_trans_count;
    while(copy_trans_count > 0)
      begin
        temp_loop_count++;
        current_pass = (copy_trans_count >= h_cfg.inc_trans_count) ? h_cfg.inc_trans_count : copy_trans_count;

        if(current_pass < 8)
        begin
          int pad_packet_count, pad_byte_count;

          pad_byte_count = `MIN_PADDING_BYTE - (current_pass * `BYTE);

          pad_packet_count = (pad_byte_count / `BYTE) + 1;

          h_cfg.act_count = h_cfg.act_count - pad_packet_count;
          h_cfg.tx_trans_count = current_pass;
          h_cfg.check_inc_count = 0;
          for(int i = 0; i < 8; i++)
          begin
            h_tx_pkt = new();
            h_tx_pkt.pkt_tx_sop  = (i == 0) ? 1 : 0;
            h_tx_pkt.pkt_tx_eop  = (i == 7) ? 1 : 0;
            h_tx_pkt.pkt_tx_mod  = (h_tx_pkt.pkt_tx_eop == 1 ) ? 0 : 0;
            if(i+1 <= current_pass)
            begin
              h_tx_pkt.pkt_tx_data = start_value + i;
            end
            else
            begin
              h_tx_pkt.pkt_tx_data = 0;
            end
            $display("^^^^^^^^^^^pkt_tx_data : %0h^^^^^^^^^^^^", h_tx_pkt.pkt_tx_data);
            $cast(h_tx_cl_pkt, h_tx_pkt.clone());
            mbx.put(h_tx_cl_pkt);
          end
            start_value += current_pass;
        end
        else
        begin
        for(int i = 0; i< current_pass; i++) 
          begin
            h_tx_pkt = new();

            h_tx_pkt.pkt_tx_sop  = (i == 0) ? 1 : 0;
            h_tx_pkt.pkt_tx_eop  = (i == current_pass - 1) ? 1 : 0;
            h_tx_pkt.pkt_tx_mod  = (h_tx_pkt.pkt_tx_eop == 1 && temp_loop_count == 3) ? 0 : 0;
            h_tx_pkt.pkt_tx_data = start_value + i;
            $display("^^^^^^^^^^^pkt_tx_data : %0h^^^^^^^^^^^^", h_tx_pkt.pkt_tx_data);
            $cast(h_tx_cl_pkt, h_tx_pkt.clone());
            mbx.put(h_tx_cl_pkt);
          end
           start_value += current_pass;

        end

        copy_trans_count -= current_pass;

     end

  endtask : generate_incremental_stimulus_and_put_into_mbx


  //Generate Random Stimulus and Put into mailbox()
  task generate_random_stimulus_and_put_into_mbx();
    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;

    int temp_loop_count = 0;
    int rand_trans_count;
    int copy_trans_count;
    int current_pass;
    int min_reserve;
    int max_allowed;

    copy_trans_count = h_cfg.trans_count;
    
    while(copy_trans_count > 0)
      begin
        temp_loop_count ++;

      if(copy_trans_count % 2 == 1)
        min_reserve = `MIN_RESERVED_EVEN;
      else
        min_reserve = `MIN_RESERVED_ODD;

      if(copy_trans_count > min_reserve) 
      begin
        max_allowed = copy_trans_count - min_reserve;

        if(copy_trans_count % 2 == 1)
        begin
          if(!std::randomize(rand_trans_count) with {
          rand_trans_count >= 2;
          rand_trans_count <= max_allowed;
          rand_trans_count % 2 == 1;
          })
            rand_trans_count = copy_trans_count;
        end
        else 
        begin
          if (!std::randomize(rand_trans_count) with {
          rand_trans_count >= 2;
          rand_trans_count <= max_allowed;
          rand_trans_count % 2 == 0;
          })
           rand_trans_count = copy_trans_count;
        end
      end
      else
        rand_trans_count = copy_trans_count;

        current_pass = rand_trans_count;
 

        $display("*********");
        $display();
        $display("Transaction_count : %0d, RandTransCount : %0d, Temp_loop_count : %0d, Copy_trans_count : %0d, Current_pass: %0d", h_cfg.trans_count, rand_trans_count, temp_loop_count, copy_trans_count, current_pass);
        $display();
        $display("*********");

        if(current_pass < 8)
        begin
          int pad_packet_count, pad_byte_count;

          pad_byte_count = `MIN_PADDING_BYTE - (current_pass * `BYTE);

          pad_packet_count = (pad_byte_count / `BYTE) + 1;

          h_cfg.act_count = h_cfg.act_count - pad_packet_count;
          h_cfg.tx_trans_count = current_pass;
          h_cfg.check_inc_count = 0;

          for(int i = 1; i <= 8; i++)
            begin
              h_tx_pkt = new();

              h_tx_pkt.pkt_tx_sop = (i == 1) ? 1 : 0;
              h_tx_pkt.pkt_tx_eop = (i == 8) ? 1 : 0;
                          
              if(i <= current_pass)
              begin
                h_tx_pkt.pkt_tx_data = {$urandom_range(0,'hFFFF_FFFF_FFFF_FFFF), $urandom_range(0,'hFFFF_FFFF_FFFF_FFFF)};
              end
              else
              begin
                h_tx_pkt.pkt_tx_data = 'h0;
              end
              h_tx_pkt.pkt_tx_mod = 0;

           /*   if(i == current_pass - 1)
              begin
                h_tx_pkt.pkt_tx_mod = $urandom_range(0,7);
               // void'(std :: randomize(h_tx_pkt.pkt_tx_mod) with { h_tx_pkt.pkt_tx_mod inside {[6:7]}; });
              end
              else
              begin
                h_tx_pkt.pkt_tx_mod = 0;
              end
*/
              $cast(h_tx_cl_pkt, h_tx_pkt.clone());
              $display("Before putting in mailbox from generator, temp_loop_count = %0d, i : %0d, current_pass : %0d, time : %0t", temp_loop_count, i, current_pass, $time);
              $display("################");
              $display();
              h_tx_cl_pkt.display();
              $display();
              $display("################");
              mbx.put(h_tx_cl_pkt); 
            end
          end
          else
          begin
            for(int i = 1; i <= current_pass; i++)
            begin
              h_tx_pkt = new();

              h_tx_pkt.pkt_tx_sop = (i == 1) ? 1 : 0;
              h_tx_pkt.pkt_tx_eop = (i == current_pass) ? 1 : 0;
                          
              h_tx_pkt.pkt_tx_data = {$urandom_range(0,'hFFFF_FFFF_FFFF_FFFF), $urandom_range(0,'hFFFF_FFFF_FFFF_FFFF)};
             
              if(i == current_pass)
              begin
                h_tx_pkt.pkt_tx_mod = $urandom_range(0,7);
               // void'(std :: randomize(h_tx_pkt.pkt_tx_mod) with { h_tx_pkt.pkt_tx_mod inside {[6:7]}; });
              end
              else
              begin
                h_tx_pkt.pkt_tx_mod = 0;
              end

              $cast(h_tx_cl_pkt, h_tx_pkt.clone());
              $display("Before putting in mailbox from generator, temp_loop_count = %0d, i : %0d, current_pass : %0d, time : %0t", temp_loop_count, i, current_pass, $time);
              $display("################");
              $display();
              h_tx_cl_pkt.display();
              $display();
              $display("################");
              mbx.put(h_tx_cl_pkt); 
            end

          end


          copy_trans_count -= current_pass;          
      end

  endtask : generate_random_stimulus_and_put_into_mbx



  //padding test
  task generate_padding_stimulus_and_put_into_mbx();

    int unsigned count;
    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;

    repeat(h_cfg.trans_count)
      begin
        h_tx_pkt = new();
        h_tx_pkt.pkt_tx_data = `XGEMAC_TX_RX_DATA_WIDTH'h AAAA_BBBB_CCCC_DDDD;

        if(count == 0)
          begin
            h_tx_pkt.pkt_tx_sop  =  1;
          end
        else
          begin
            h_tx_pkt.pkt_tx_sop = 0;
          end

        count++;

        if(count == h_cfg.trans_count)
        begin
          h_tx_pkt.pkt_tx_eop = 1;
          h_tx_pkt.pkt_tx_mod = 6;
        end
        else
        begin
          h_tx_pkt.pkt_tx_eop = 0;
          h_tx_pkt.pkt_tx_mod = 0;
        end

        mbx.put(h_tx_pkt);
     
     end
  endtask : generate_padding_stimulus_and_put_into_mbx

  
  /*

  //Generate Random Stimulus and Put into mailbox()
  task generate_random_stimulus_and_put_into_mbx();

    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;

    int rand_trans_count;
    int copy_trans_count;
    int current_pass;
    int min_reserve;
    int max_allowed;

    copy_trans_count = h_cfg.trans_count;
    
    while(copy_trans_count > 0)
      begin 

        if(copy_trans_count%2 == 1)
          begin
            min_reserve = `MIN_RESERVED_EVEN;
          end
        else
          begin
            min_reserve = `MIN_RESERVED_ODD;
          end

        if(copy_trans_count > min_reserve) 
          begin
            max_allowed = copy_trans_count - min_reserve;

            if(copy_trans_count%2 == 1) 
              begin
                if(!std::randomize(rand_trans_count) with { rand_trans_count >= 7;
                                                            rand_trans_count <= max_allowed;
                                                            rand_trans_count%2 == 1;
                                                          })
                  rand_trans_count = copy_trans_count;
              end
            else 
              begin
                if(!std::randomize(rand_trans_count) with { rand_trans_count >= 8;
                                                            rand_trans_count <= max_allowed;
                                                            rand_trans_count%2 == 0;
                                                          })
                  rand_trans_count = copy_trans_count;
              end
            end
        else
          begin
            rand_trans_count = copy_trans_count;
          end

        current_pass = rand_trans_count;
 
        for(int i = 0; i < current_pass ; i++)
          begin
            h_tx_pkt = new();
            h_tx_pkt.pkt_tx_sop  = (i == 0) ? 1 : 0;
      
            h_tx_pkt.pkt_tx_data = {$urandom_range(0, 'hFFFF_FFFF_FFFF_FFFF), $urandom_range(0, 'hFFFF_FFFF_FFFF_FFFF)};

            h_tx_pkt.pkt_tx_eop  = (i == current_pass - 1) ? 1 : 0;

            h_tx_pkt.pkt_tx_mod  = (h_tx_pkt.pkt_tx_eop == 1) ? $urandom_range(5,7) : 0;

            $cast(h_tx_cl_pkt, h_tx_pkt.clone());
            h_tx_cl_pkt.display();
            mbx.put(h_tx_cl_pkt);
          end

          copy_trans_count -= current_pass;          
      end
  endtask : generate_random_stimulus_and_put_into_mbx
*/

  //Get PlusArgs to get stimulus in command line 
  task get_plusargs_or_rand_and_put_in_mbx();
    xgemac_tx_pkt h_tx_pkt, h_tx_cl_pkt;
    int unsigned count;
    bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] tx_data;
    h_tx_pkt = new();
    repeat(h_cfg.trans_count)
      begin
        if($value$plusargs($sformatf("TX_DATA_%0d", count), tx_data))
          begin
            h_tx_pkt.pkt_tx_data = tx_data;
          end
        else
          begin
            h_tx_pkt.pkt_tx_data = $urandom();
          end
      
      $cast(h_tx_cl_pkt, h_tx_pkt.clone());
      mbx.put(h_tx_cl_pkt);
    end

  endtask : get_plusargs_or_rand_and_put_in_mbx
  
endclass : xgemac_generator
