class rst_driver#(RESET_PERIOD, rst_type_t rst_type , type vif_t = int);

    vif_t vif;
    string REPORT_TAG = "RESET_DRIVER";

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

    //wait for reset task
    task wait_for_reset();
      @(negedge vif.rst == 0);
    endtask : wait_for_reset

    //drive reset method
    task drive_reset_method();
      vif.rst = rst_type;
      @(posedge vif.clk);
      vif.rst = ~rst_type;
      repeat(RESET_PERIOD) begin
        @(posedge vif.clk);
      end
      vif.rst = rst_type; 
    endtask : drive_reset_method

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
