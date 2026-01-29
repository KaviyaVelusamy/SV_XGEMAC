class wb_pkt;

  rand bit[`XGEMAC_WB_ADDR_WIDTH - 1 : 0] wb_adr_i;
  rand bit                                wb_cyc_i;
  rand bit[`XGEMAC_WB_DATA_WIDTH - 1 : 0] wb_dat_i;
  rand bit                                wb_stb_i;
  rand bit                                wb_we_i;
       bit                                wb_ack_o;
       bit[`XGEMAC_WB_DATA_WIDTH - 1 : 0] wb_dat_o;
       bit                                wb_int_o;


  function void display();

    $display("WB_ADDR_i         = %0h\n", wb_adr_i);
    $display("WB_CYC_i          = %0h\n", wb_cyc_i);
    $display("WB_DATA_i         = %0h\n", wb_dat_i);
    $display("WB_STROBE_i       = %0h\n", wb_stb_i);
    $display("WB_WRITE_ENABLE_i = %0h\n", wb_we_i);
    $display("WB_ACKNOWLEDGEMENT_o = %0h\n", wb_ack_o);
    $display("WB_DATA_o = %0h\n", wb_dat_o);
    $display("WB_INTERRUPT_o = %0h\n",wb_int_o);
  endfunction : display


  function wb_pkt clone();
    wb_pkt h_wb_pkt;
    h_wb_pkt = new();
    h_wb_pkt.copy(this);
    return h_wb_pkt;
  endfunction : clone

  function void copy(wb_pkt h_wb_pkt);
    this.wb_adr_i = h_wb_pkt.wb_adr_i;
    this.wb_cyc_i = h_wb_pkt.wb_cyc_i;
    this.wb_dat_i = h_wb_pkt.wb_dat_i;
    this.wb_stb_i = h_wb_pkt.wb_stb_i;
    this.wb_we_i  = h_wb_pkt.wb_we_i;
    this.wb_ack_o = h_wb_pkt.wb_ack_o;
    this.wb_dat_o = h_wb_pkt.wb_dat_o;
    this.wb_int_o  = h_wb_pkt.wb_int_o;
  endfunction : copy


endclass : wb_pkt
