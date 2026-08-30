// Code your design here
`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module spi_shifter(
  input PCLK,
  input PRESET_n,
  input ss_i, //slave select
  input lsbfe_i,//lsb or msb select
  input cpha_i,
  input cpol_i,
  input miso_receive_sclk_i,
  input miso_receive_sclk0_i,
  input mosi_send_sclk_i,
  input mosi_send_sclk0_i,
  input send_data_i,//when 1 laod data from data reg to shift reg from data_mosi_i
  input [`SPI_APB_DATA_WIDTH-1:0]data_mosi_i,
  input miso_i,
  input receive_data_i,//when 1 send the temp reg bits to apb slave interface
  output [`SPI_APB_DATA_WIDTH-1:0]data_miso_o,
  output reg mosi_o);
  
  reg[`SPI_APB_DATA_WIDTH-1:0] shift_register_s;
  reg[`SPI_APB_DATA_WIDTH-1:0] temp_reg_s;
  reg[2:0]count_s;
  reg[2:0]count1_s;
  reg[2:0]count2_s;
  reg[2:0]count3_s;
  
   //logic to receive the data to shift register
  always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)
      shift_register_s <= 8'b0;
    else if(send_data_i)
      shift_register_s <= data_mosi_i;
  end
  
  //logic to send the received data to the data register
  assign data_miso_o = receive_data_i ? temp_reg_s : 8'b0;
  
  //logic to send the mosi data
  always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
      mosi_o <= 1'b0;
      count_s <= 3'd0;
      count1_s <= 3'd0;
    end
    else begin
      if(!ss_i)begin
        if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))begin // negedge sampling
          if(lsbfe_i)begin // start from lsb and increment
            if(count_s <= 3'd7)begin
              if(mosi_send_sclk0_i)begin // flag is set
                mosi_o <= shift_register_s[count_s];
                count_s <= count_s + 1;
              end
            end
            else
              count_s <= 3'd0;
          end
          else begin // start from msb and decrement
            if(count1_s >= 3'd0)begin
              if(mosi_send_sclk0_i)begin // flag is set
                mosi_o <= shift_register_s[count_s];
                count1_s <= count1_s - 1;
              end
            end
            else
              count1_s <= 3'd7;
          end
        end
          else begin
            if((cpha_i && cpol_i) || (!cpha_i && !cpol_i))begin // posedge sampling
              if(lsbfe_i)begin // start from lsb and increment
                if(count_s <= 3'd7)begin
                  if(mosi_send_sclk_i)begin // flag is set
                    mosi_o <= shift_register_s[count_s];
                    count_s <= count_s + 1;
                end
              end
                else
                  count_s <= 3'd0;
            end
              else begin  //start from msb and decrement
                if(count1_s >= 3'd0)begin
                  if(mosi_send_sclk_i)begin // flag is set
                    mosi_o <= shift_register_s[count1_s];
                    count1_s <= count1_s - 1;
                  end
                end
                count1_s <= 3'd7;
              end
            end
          end
      end
    end
  end
      
  //logic to receive the miso data
  always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
      temp_reg_s <= 8'b0;
      count2_s <= 3'd0;
      count3_s <= 3'd0;
    end
    else begin
      if(!ss_i)begin
        if(!cpha_i && cpol_i || cpha_i && !cpol_i)begin // negedge sampling
          if(lsbfe_i)begin // start from lsb and increment
            if(count2_s <= 3'd7)begin
              if(miso_receive_sclk0_i)begin // flag is set
                temp_reg_s[count2_s] <= miso_i;
                count2_s <= count2_s + 1;
              end
            end
            else
              count2_s <= 3'd0;
          end
          else begin // start from msb and decrement
            if(count3_s >= 3'd0)begin
              if(miso_receive_sclk0_i)begin // flag is set
                temp_reg_s[count2_s] <= miso_i;
                count3_s <= count3_s - 1;
              end
            end
            else
              count3_s <= 3'd7;
          end
        end
          else begin
            if(!cpha_i && !cpol_i || cpha_i && cpol_i)begin // posedge sampling
              if(lsbfe_i)begin // start from lsb and increment
                if(count2_s <= 3'd7)begin
                  if(miso_receive_sclk_i)begin // flag is set
                    temp_reg_s[count2_s] <= miso_i;
                    count2_s <= count2_s + 1;
                end
              end
                else
                  count2_s <= 3'd0;
            end
              else begin  //start from msb and decrement
                if(count3_s >= 3'd0)begin
                  if(miso_receive_sclk_i)begin // flag is set
                    temp_reg_s[count3_s] <= miso_i;
                    count3_s <= count3_s - 1;
                  end
                end
                count3_s <= 3'd7;
              end
            end
          end
      end
    end
  end
  
endmodule
