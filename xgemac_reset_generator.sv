class xgemac_reset_generator;

  mailbox#(reset_pkt) mbx;
  xgemac_tb_config h_cfg;

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


  //Generate reset and put into mailbox
  task generate_reset_indicator_and_put_into_mbx(int unsigned rst_period = `XGEMAC_TX_RX_RESET_PERIOD);
    reset_pkt h_rst_pkt, h_cl_rst_pkt;
    h_rst_pkt = new();
    h_rst_pkt.rst_period = rst_period;
    $cast(h_cl_rst_pkt, h_rst_pkt);
    mbx.put(h_cl_rst_pkt);
  endtask : generate_reset_indicator_and_put_into_mbx

  
endclass : xgemac_reset_generator
