class clk_driver#(type t = int, t CLOCK_PERIOD, type vif_t = int);

  vif_t vif;
  string REPORT_TAG = "CLOCK_DRIVER";

  //Constructor
  function new(vif_t vif);
    this.vif = vif;
  endfunction : new

  //Build function
  function void build();
    $display("%s : Build Function", REPORT_TAG);
  endfunction : build

  //Connect function
  function void connect();
    $display("%s : Connect Function", REPORT_TAG);
  endfunction : connect

  //Run function
  task run();
    $display("%s : Run Task", REPORT_TAG);
    vif.clk = 0;
    forever
    begin
      #(CLOCK_PERIOD/2);
      vif.clk = ~vif.clk;
    end
  endtask : run


endclass : clk_driver
