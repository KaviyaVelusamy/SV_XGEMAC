class xgemac_rx_pkt;

  bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] pkt_rx_data;
  bit                                   pkt_rx_sop;
  bit                                   pkt_rx_eop;
  bit[`XGEMAC_TX_RX_MOD - 1 : 0]        pkt_rx_mod;
  bit                                   pkt_rx_err;

  function void display();
    $display("Value of pkt_rx_data : %0h\n", pkt_rx_data);
    $display("Value of pkt_rx_sop  : %0h\n", pkt_rx_sop);
    $display("Value of pkt_rx_eop  : %0h\n", pkt_rx_eop);
    $display("Value of pkt_rx_mod  : %0h\n",  pkt_rx_mod);
  endfunction : display

  function xgemac_rx_pkt clone();
    xgemac_rx_pkt h_rx_pkt;
    h_rx_pkt = new();
    h_rx_pkt.copy(this);
    return h_rx_pkt;
  endfunction : clone

  function void copy(xgemac_rx_pkt h_rx_pkt);
    this.pkt_rx_data = h_rx_pkt.pkt_rx_data;
    this.pkt_rx_sop  = h_rx_pkt.pkt_rx_sop;
    this.pkt_rx_eop  = h_rx_pkt.pkt_rx_eop;
    this.pkt_rx_mod  = h_rx_pkt.pkt_rx_mod;
    this.pkt_rx_err  = h_rx_pkt.pkt_rx_err;
  endfunction : copy
  
endclass : xgemac_rx_pkt 
