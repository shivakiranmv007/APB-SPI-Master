// Code your testbench here
// or browse Examples
/*Verify : APB write operation
         APB read operation
         Whatever written into data_reg using receive_data_i ,can we read that data*/
module spi_apb_interface_tb();
  
  `define SPI_APB_DATA_WIDTH 8
  `define SPI_REG_WIDTH 8
  `define SPI_APB_ADDR_WIDTH 3

  reg PCLK;
  reg PRESET_n;
  reg[`SPI_APB_ADDR_WIDTH-1:0] PADDR;
  reg PWRITE;
  reg PSEL;
  reg PENABLE;
  reg[`SPI_APB_DATA_WIDTH-1:0]PWDATA;
  wire[`SPI_APB_DATA_WIDTH-1:0] PRDATA;
  wire PREADY;
  wire PSLVERR;
  reg ss;
  reg[`SPI_APB_DATA_WIDTH-1:0] data_miso;
  wire send_data;
  reg receive_data;
  reg tip;
  wire[`SPI_APB_DATA_WIDTH-1:0] data_mosi;
  wire[1:0]spi_mode;
  wire mstr;
  wire cpol;
  wire cpha;
  wire lsbfe;
  wire spiswai;
  wire[2:0]sppr;
  wire[2:0]spr;
  wire spi_interrupt_request;
  
  spi_apb_interface dut (
    .PCLK                     (PCLK),
    .PRESET_n                 (PRESET_n),
    .PADDR_i                  (PADDR),
    .PWRITE_i                 (PWRITE),
    .PSEL_i                   (PSEL),
    .PENABLE_i                (PENABLE),
    .PWDATA_i                 (PWDATA),
    .PRDATA_i                 (PRDATA),
    .PREADY_o                 (PREADY),
    .PSLVERR_o                (PSLVERR),
    .ss_i                     (ss),
    .data_miso_i              (data_miso),
    .send_data_o              (send_data),
    .receive_data_i           (receive_data),
    .tip_i                    (tip),
    .data_mosi_o              (data_mosi),
    .spi_mode_o               (spi_mode),
    .mstr_o                   (mstr),
    .cpol_o                   (cpol),
    .cpha_o                   (cpha),
    .lsbfe_o                  (lsbfe),
    .spiswai_o                (spiswai),
    .sppr_o                   (sppr),
    .spr_o                    (spr),
    .spi_interrupt_request_o  (spi_interrupt_request)
);
  
  initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
  end
  
  task reset();
    begin
      @(negedge PCLK)
      PRESET_n = 1'b0;
      @(negedge PCLK)
      PRESET_n = 1'b1;
    end
  endtask
  
  //Write into all registers and to check spi_mode
  task initialize();
    begin
      @(negedge PCLK)
      PADDR = 3'b0;//SPI_CR_1
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b0;//idle
      PWDATA = 8'b1111_0100;//data
      ss = 1'b1;//slave selected
      tip = 1'b0;//no progress
      
      @(negedge PCLK)
      PADDR = 3'b0;//SPI_CR_1
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b1;//setup phase and value is written
      PWDATA = 8'b1111_0100;//written into SPI_CR_1
      
      //one delay
      @(negedge PCLK)
      PADDR = 3'b0;//SPI_CR_1
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b0;//idle
      PWDATA = 8'b1111_0100;
      
      @(negedge PCLK)
      PADDR = 3'b1;//SPI_CR_2
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b0;//idle
      PWDATA = 8'b1100_0010;
      
      @(negedge PCLK)
      PADDR = 3'b001;//SPI_CR_2
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b1;//setup phase,value is written
      PWDATA = 8'b1100_0010;//written into SPI_CR_2
      
      @(negedge PCLK)
      PADDR = 3'b010;//SPI_BR
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b0;//idle
      PWDATA = 8'b0010_0111;
      
      @(negedge PCLK)
       PADDR = 3'b010;//SPI_BR
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b1;//setup phase, value is written
      PWDATA = 8'b0010_0111;//written into SPI_BR
      
    end
  endtask
  
  task write();
    begin
      
      @(negedge PCLK)
      PADDR = 3'b101;//SPI_DR
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b0;//idle
      PWDATA = 8'b1100_1111;//data
      tip = 1'b0;//no progress
      
      @(negedge PCLK)
      PADDR = 3'b101;//SPI_DR
      PWRITE = 1'b1;//write
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b1;//setup phase , value is written
      PWDATA = 8'b1100_1111;//written into SPI_DR
      
    end
  endtask
  
  task read();
    begin
      //reading from shift register which we get from miso_data_i
      @(negedge PCLK)
      PADDR = 3'b101;//SPI_DR
      PWRITE = 1'b0;//read
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b0;//idle
      
      @(negedge PCLK)
      PADDR = 3'b101;//SPI_DR
      PWRITE = 1'b0;//read
      PSEL = 1'b1;//slave addr is selected
      PENABLE = 1'b1;//setup phase,value is read
      
    end
    endtask
  
  initial begin
    #5;
    reset();
    #10;
    initialize();
    #10;
    write();
    #10;
    data_miso = 8'hff;//hardcoded the shift reg value
    ss = 1'b0;//active low
    receive_data = 1'b1;//enabled
    read();
    #20;
    receive_data = 1'b0;
    #100;
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,spi_apb_interface_tb);
  end
  
endmodule
