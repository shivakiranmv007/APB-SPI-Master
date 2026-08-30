// Code your testbench here
// or browse Examples
`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3
module spi_core_tb();
  reg PCLK = 1'b0;
  reg PRESET_n;
  reg PWRITE;
  reg[`SPI_APB_ADDR_WIDTH-1:0] PADDR;
  reg PSEL;
  reg PENABLE;
  reg[`SPI_APB_DATA_WIDTH-1:0]PWDATA;
  wire[`SPI_APB_DATA_WIDTH-1:0]PRDATA;
  wire PREADY;
  wire PSLVERR;
  reg miso;
  wire ss;
  wire sclk;
  wire spi_interrupt_request;
  wire mosi;
  integer i;
  
  spi_core dut(.PCLK(PCLK),
               .PRESET_n(PRESET_n),
               .PADDR_i(PADDR),
               .PWRITE_i(PWRITE),
               .PSEL_i(PSEL),
               .PENABLE_i(PENABLE),
               .PWDATA_i(PWDATA),
               .PRDATA_o(PRDATA),
               .PREADY_o(PREADY),
               .PSLVERR_o(PSLVERR),
               .miso_i(miso),
               .ss_o(ss),
               .sclk_o(sclk),
               .spi_interrupt_request_o(spi_interrupt_request),
               .mosi_o(mosi));
  
  always #5 PCLK = ~PCLK;
  
  task reset();
    begin
      @(posedge PCLK)
      PRESET_n = 1'b0;
      @(posedge PCLK)
      PRESET_n = 1'b1;
    end
  endtask
  
  //APB Protocol
  //Updating the CR1 ,CR2 and BRR
  task write_registers(input[7:0] contr1_data,contr2_data,baud_data);
    begin
      
      //Control reg1
      @(posedge PCLK)
      PADDR = 3'b000;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b0;//setup phase
      PWDATA = contr1_data;
      
       @(posedge PCLK)
      PADDR = 3'b000;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;//access phase
      PWDATA = contr1_data;
      
      @(posedge PCLK)
      wait(PREADY)//after PREADY becomes 1 the transaction takes place (read or write based on flags)
      PENABLE = 1'b0;
      
      //Control reg2
      @(posedge PCLK)
      PADDR = 3'b001;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b0;//setup phase
      PWDATA = contr2_data;
      
       @(posedge PCLK)
      PADDR = 3'b001;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;//access phase
      PWDATA = contr2_data;
      
      @(posedge PCLK)
      wait(PREADY)//after PREADY becomes 1 the transaction takes place (read or write based on flags)
      PENABLE = 1'b0;
      
      //BRR
      @(posedge PCLK)
      PADDR = 3'b010;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b0;//setup phase
      PWDATA = baud_data;
      
       @(posedge PCLK)
      PADDR = 3'b010;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;//access phase
      PWDATA = baud_data;
      
      @(posedge PCLK)
      wait(PREADY)//after PREADY becomes 1 the transaction takes place (read or write based on flags)
      PENABLE = 1'b0;
      
    end 
  endtask
  
  //Write the value to the DRR
  task write_data_register(input[7:0] write_data);
    begin
      //DRR
      @(posedge PCLK)
      PADDR = 3'b101;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b0;//setup phase
      PWDATA = write_data;
      
       @(posedge PCLK)
      PADDR = 3'b101;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;//access phase
      PWDATA = write_data;
      
      @(posedge PCLK)
      wait(PREADY)//after PREADY becomes 1 the transaction takes place (read or write based on flags)
      PADDR = 3'b101;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b0;
      PWDATA = write_data;
      
    end
  endtask
  
  //Write the MISO data through the MISO ports ,from MSB
  task write_miso_data_low_lsbfe(input[7:0]miso_data);
    begin
      wait(~ss);
      miso = miso_data[0];
      for(i=1;i<=7;i=i+1)
        begin
          @(negedge sclk)
          miso = miso_data[i];
        end
    end
  endtask
  
  //Write the MISO data through the MISO ports clk high to low shifting from index0,from LSB and posedge
   task write_miso_data_high_lsbfe(input[7:0]miso_data);
    begin
      miso = 0;
      wait(~ss)
      for(i=0;i<=7;i=i+1)
        begin
          @(posedge sclk)
          miso = miso_data[i];
        end
    end
  endtask
  
  //Write the MISO data through the MISO ports clk high to low shifting from index7,from MSB and posedge
   task write_miso_data_high_lsbfe0(input[7:0]miso_data);
    begin
      //miso_data = 0;
      wait(~ss)
      miso = miso_data[7];
      for(i=6;i>=0;i=i-1)
        begin
          @(posedge sclk)
          miso = miso_data[i];
        end
    end
  endtask
  
  //Write the MISO data through the MISO ports clk low to high shifting from index0,from LSB and posedge
   task write_miso_data_low_lsbfe0(input[7:0]miso_data);
    begin
      //miso_data = 0;
      wait(~ss)
      for(i=7;i>=0;i=i-1)
        begin
          @(negedge sclk)
          miso = miso_data[i];
        end
    end
  endtask
  
  initial begin
    miso = 1'b0;
    reset();
    write_registers(8'b1111_0111,8'b0000_0000,8'b0000_0011);
    write_data_register(8'b1010_1010);
    write_miso_data_low_lsbfe(8'b01010111);
    #100;
    
    write_registers(8'b1111_0111,8'b0000_0000,8'b0000_0011);
    write_data_register(8'b1010_1010);
    write_miso_data_low_lsbfe(8'b01010101);
    #500;
    
    $finish;
  end
  

endmodule
