class xgemac_functional_coverage;

  xgemac_tx_pkt h_tx_pkt;
  
  xgemac_rx_pkt h_rx_pkt;

  covergroup cover_g1;

    option.auto_bin_max = 128;

    cp_1 : coverpoint h_rx_pkt.pkt_rx_data;

    cp_2 : coverpoint h_rx_pkt.pkt_rx_sop;

    cp_3 : coverpoint h_rx_pkt.pkt_rx_eop;

    cp_4 : coverpoint h_rx_pkt.pkt_rx_mod;

  endgroup : cover_g1

  covergroup cover_g2;
    option.auto_bin_max = 128;

    cp_1 : coverpoint h_tx_pkt.pkt_tx_data;

    cp_2 : coverpoint h_tx_pkt.pkt_tx_sop;

    cp_3 : coverpoint h_tx_pkt.pkt_tx_eop;

    cp_4 : coverpoint h_tx_pkt.pkt_tx_mod;
  endgroup

  function new();
    cover_g1 = new();
    cover_g2 = new();
  endfunction : new

  function void rx_packet_in_sample(xgemac_rx_pkt h_rx_pkt);
    this.h_rx_pkt = h_rx_pkt;
    cover_g1.sample();
  endfunction : rx_packet_in_sample

  function void tx_packet_in_sample(xgemac_tx_pkt h_tx_pkt);
    this.h_tx_pkt = h_tx_pkt;
    cover_g2.sample();
  endfunction : tx_packet_in_sample


  function void display();
    $display("Coverage detail RX : %0d", cover_g1.get_coverage());
    $display("Coverage detail TX: %0d", cover_g2.get_coverage());

  endfunction : display




endclass : xgemac_functional_coverage
