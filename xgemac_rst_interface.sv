interface xgemac_rst_interface(input clk);
  
    logic rst;

    initial begin
        $display("This is reset interface");
    end
    
endinterface : xgemac_rst_interface
