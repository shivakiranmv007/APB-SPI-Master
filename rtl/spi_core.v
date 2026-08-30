// Code your design here
`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module spi_core(input PCLK,
                input PRESET_n,
                input[`SPI_APB_ADDR_WIDTH-1:0] PADDR_i,
                input PWRITE_i,
                input PSEL_i,
                input PENABLE_i,
                input[`SPI_APB_DATA_WIDTH-1:0] PWDATA_i,
                output[`SPI_APB_DATA_WIDTH-1:0]PRDATA_o,
                output PREADY_o,
                output PSLVERR_o,
                input miso_i,
                output ss_o,
                output sclk_o,
                output spi_interrupt_request_o,//Connected to processor
                output mosi_o);
  
  //These are internals wires used for connecting the blocks
  wire[`SPI_APB_DATA_WIDTH-1:0]data_mosi;
  wire[`SPI_APB_DATA_WIDTH-1:0]data_miso;
  
  wire mstr;
  wire cpol;
  wire cpha;
  wire lsbfe;
  wire spiswai;
  wire [2:0]sppr;
  wire [2:0]spr;
  wire send_data;
  wire receive_data;
  wire tip;
  wire[1:0]spi_mode;
  wire[11:0] BaudRateDivisor;
  wire ss;
  wire miso_receive_pos_sclk;
  wire miso_receive_neg_sclk;
  wire mosi_send_pos_sclk;
  wire mosi_send_neg_sclk;
  wire miso;
  wire mosi;
  
  
  spi_baud_generator spi_bg(.PCLK(PCLK),
                    .PRESET_n(PRESET_n),
                    .spi_mode_i(spi_mode),//three modes(run,wait,stop)
                    .spiswai_i(spiswai),
                    .sppr_i(sppr),//SPI BAUD RATE preselection bit
                    .spr_i(spr),// SPI BAUD RATE selection bit
                    .cpol_i(cpol),//when 1 = preclk(0),when 0 = preclk(0)
                    .cpha_i(cpha),//when 1 = odd edge, when 0 = even edge
                            .ss_i(ss_o),//slave select
                    .sclk_o(sclk_o),
                    .miso_receive_sclk_o(miso_receive_pos_sclk),
                    .miso_receive_sclk0_o(miso_receive_neg_sclk),
                    .mosi_send_sclk_o(mosi_send_pos_sclk),
                    .mosi_send_sclk0_o(mosi_send_neg_sclk),
                    .BaudRateDivisor_o(BaudRateDivisor));
  
  spi_apb_interface spi_apb(.PCLK(PCLK),
                       .PRESET_n(PRESET_n),
                       .PADDR_i(PADDR_i),
                       .PWRITE_i(PWRITE_i),
                       .PSEL_i(PSEL_i),
                       .PENABLE_i(PENABLE_i),
                       .PWDATA_i(PWDATA_i),
                       .ss_i(ss_o), //slave select
                       .data_miso_i(data_miso),
                       .receive_data_i(receive_data),//data written into DR when this is set
                       .tip_i(tip),
                       .PRDATA_i(PRDATA_o),
                       .mstr_o(mstr),//master selected
                       .cpol_o(cpol),//Decides preclk value
                       .cpha_o(cpha),//Decides odd or even edge
                       .lsbfe_o(lsbfe),//Decides lsb or msb 1st
                       .spiswai_o(spiswai),
                       .sppr_o(sppr),
                       .spr_o(spr),
                       .spi_interrupt_request_o(spi_interrupt_request_o),
                       .PREADY_o(PREADY_o),
                       .PSLVERR_o(PSLVERR_o),
                       .send_data_o(send_data),
                       .data_mosi_o(data_mosi),   
                       .spi_mode_o(spi_mode));

  
  spi_shifter spi_shift(.PCLK(PCLK),
                     .PRESET_n(PRESET_n),
                     .ss_i(ss_o),
                     .send_data_i(send_data),
                     .lsbfe_i(lsbfe),
                     .cpha_i(cpha),
                     .cpol_i(cpol),
                     .miso_receive_sclk_i(miso_receive_pos_sclk),
                     .miso_receive_sclk0_i(miso_receive_neg_sclk),
                     .mosi_send_sclk_i(mosi_send_pos_sclk),
                     .mosi_send_sclk0_i(mosi_send_neg_sclk),
                     .data_mosi_i(data_mosi),
                     .miso_i(miso_i),
                     .receive_data_i(receive_data),
                     .mosi_o(mosi_o),
                     .data_miso_o(data_miso));
  
  spi_slave_select spi_ss(.PCLK(PCLK),
                           .PRESET_n(PRESET_n),
                           .mstr_i(mstr),
                           .spiswai_i(spiswai),
                           .spi_mode_i(spi_mode),
                           .send_data_i(send_data),
                           .BaudRateDivisor_i(BaudRateDivisor),
                           .receive_data_o(receive_data),
                           .ss_o(ss_o),
                           .tip_o(tip));
                     
                    
  
endmodule

