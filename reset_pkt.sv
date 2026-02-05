class reset_pkt;

  int rst_period;
  
  function reset_pkt clone();
    reset_pkt h_rst_pkt;
    h_rst_pkt = new();
    h_rst_pkt.copy(this);
    return h_rst_pkt;
  endfunction : clone

  function void copy(reset_pkt h_rst_pkt);
    this.rst_period = h_rst_pkt.rst_period;
  endfunction : copy

  function void display();
    $display("Value of Reset Period : %0d", this.rst_period);
  endfunction : display

endclass : reset_pkt
