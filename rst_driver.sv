class rst_driver#(RESET_PERIOD, rst_type_t rst_type , type vif_t = int);

    vif_t vif;
    string REPORT_TAG = "RESET_DRIVER";
    mailbox#(reset_pkt) mbx;

    //Constructor
    function new(vif_t vif);
      this.vif = vif;
    endfunction : new

    //Build function
    function void build();
      $display("%s : Build Function", REPORT_TAG);
    endfunction : build 

    //Connect Function
    function void connect();
      $display("%s : Connect Function", REPORT_TAG);
    endfunction : connect

    
    //drive reset method
    task drive_reset_method();
      reset_pkt h_rst_pkt, h_rst_cl_pkt;
      forever begin
      mbx.get(h_rst_pkt);
      $cast(h_rst_cl_pkt, h_rst_pkt);
      @(posedge vif.clk);
      vif.rst = ~rst_type;
      repeat(h_rst_cl_pkt.rst_period) begin
        @(posedge vif.clk);
      end
      vif.rst = rst_type;
      end

    endtask : drive_reset_method

  /*  //Run Task
    task run();
      bit rx_indicator;
      forever begin
        mbx.get(rx_indicator);  
        drive_reset_method();
      end
    endtask : run */

    //Run Task
    task run();
      vif.rst = rst_type;
      @(posedge vif.clk);
      vif.rst = ~rst_type;
      repeat(RESET_PERIOD) begin
        @(posedge vif.clk);
      end
      vif.rst = rst_type;
    endtask : run

endclass: rst_driver
