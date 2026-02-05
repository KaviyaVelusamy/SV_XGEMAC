class xgemac_tx_pkt;

  rand bit[`XGEMAC_TX_RX_DATA_WIDTH - 1 : 0] pkt_tx_data;
  rand bit                                   pkt_tx_sop;
  rand bit                                   pkt_tx_eop;
  rand bit[`XGEMAC_TX_RX_MOD - 1 : 0]        pkt_tx_mod;
  

  function xgemac_tx_pkt clone();
    xgemac_tx_pkt h_tx_pkt;
    h_tx_pkt = new();
    h_tx_pkt.copy(this);
    return h_tx_pkt;
  endfunction : clone

  function void copy(xgemac_tx_pkt h_tx_pkt);
    this.pkt_tx_data = h_tx_pkt.pkt_tx_data;
    this.pkt_tx_sop  = h_tx_pkt.pkt_tx_sop;
    this.pkt_tx_eop  = h_tx_pkt.pkt_tx_eop;
    this.pkt_tx_mod  = h_tx_pkt.pkt_tx_mod;
  endfunction : copy

  function void display();
   // $display("Inside TX Packet --> time : %0t", $time);
    $display("Value of PKT_TX_DATA : %0h", pkt_tx_data);
    $display("Value of PKT_TX_SOP : %0h", pkt_tx_sop);
    $display("Value of PKT_TX_EOP : %0h", pkt_tx_eop);
    $display("Value of PKT_TX_MOD : %0h", pkt_tx_mod);
  endfunction : display

endclass : xgemac_tx_pkt
