// Code your testbench here
// or browse Examples
module spi_slave_select_tb();
  reg PCLK;
  reg PRESETn;
  reg[1:0]spi_mode;
  reg mstr;
  reg spiswai;
  reg[11:0]BaudRateDivisor;
  reg send_data;
  wire ss;
  wire receive_data;
  wire tip;
  
  spi_slave_select dut(
    .PCLK(PCLK),
    .PRESET_n(PRESETn),
    .spi_mode_i(spi_mode),
    .mstr_i(mstr),
    .BaudRateDivisor_i(BaudRateDivisor),
    .spiswai_i(spiswai),
    .send_data_i(send_data),//to start it ,we need to send data by enabling this 
    .ss_o(ss),//Based on plck and baudratedivisor we need to keep ss_o enable 
    .receive_data_o(receive_data),
    .tip_o(tip)
  );
  
  initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
  end
  
  task reset();
    begin
      #10;
      PRESETn = 1'b0;
      #10;
      PRESETn = 1'b1;
    end
  endtask
  
  // ss selects the slave when in master mode and send data is desserted ,slave should be selected
  //for a duration of BRD*16 after that slave is deselected and stop mode is activated
  //then slave is deasserted
  
  task ss_generation();
    begin
      spi_mode = 2'b00;
      send_data = 1'b1;
      mstr = 1;
      spiswai = 1'b0;
      BaudRateDivisor = 12'h4;
      #10;
      @(posedge PCLK)
      send_data = 1'b0;
    end
  endtask
  
  task ss_generation_stop();
    begin
      send_data = 1'b0;
      spi_mode = 2'b10;
    end
  endtask
  
  initial begin
    reset();
    #10;
    ss_generation();
    #700;
    ss_generation_stop();
    #200;
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
  
endmodule
