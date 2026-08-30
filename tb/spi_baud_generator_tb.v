// Code your testbench here
// or browse Examples
module tb_spi_baud_generator();
  reg PCLK;
  reg PRESET_n;
  reg [1:0]spi_mode_i;
  reg spiswai_i;
  reg[2:0] sppr_i;
  reg[2:0] spr_i;
  reg cpol_i;
  reg cpha_i;
  reg ss_i;
  wire sclk_o;
  wire miso_receive_sclk_o;
  wire miso_receive_sclk0_o;
  wire mosi_send_sclk_o;
  wire mosi_send_sclk0_o;
  wire[11:0]BaudRateDivisor_o;
  
  spi_baud_generator dut(.*); // default based , saves time
  
  initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
  end
  
  task initialize();
    begin
      spi_mode_i = 2'b00;
      sppr_i     = 3'b0;
      spr_i      = 3'b0;
      cpol_i     = 1'b0;
      cpha_i     = 1'b1;
      ss_i       = 1'b1;
      spiswai_i  = 1'b0;
      PRESET_n   = 1'b0;
    end
  endtask
  
  task reset();
    begin
      #1;
      PRESET_n = 1'b0;
      #43;
      PRESET_n = 1'b1;
    end
  endtask
  
  task baud_gen(input[2:0]i,j,
                input m,n);
    begin
      spi_mode_i = 2'b01;//in wait
      sppr_i     = i;
      spr_i      = j;
      cpol_i     = m;
      cpha_i     = n;
      ss_i       = 1'b0;
      spiswai_i  = 1'b0;//but it is zero
    end
  endtask
  
  initial begin
    initialize();
    #10;
    reset();
    #10;
    baud_gen(3'd0,3'd2,1'b0,1'b1);
    #700;
    baud_gen(3'd0,3'd2,1'b0,1'b0);
    #700;
    spiswai_i = 1'b1;
    #1000;
    $finish;
    
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
  
endmodule
