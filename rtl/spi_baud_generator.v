// Code your design here
module spi_baud_generator(
  input PCLK,
  input PRESET_n,
  input [1:0]spi_mode_i, // indicates the run,wait,stop mode
  input spiswai_i,  // indicates the wait mode when it is set 1
  input[2:0] sppr_i,
  input[2:0] spr_i, // these both are used to baud rate divisor generation
  input cpol_i,
  input cpha_i, // these indicates whethear to sample at pos or neg edge,
  input ss_i,  // this is used for slave selection
  output reg sclk_o,
  output reg miso_receive_sclk_o,
  output reg miso_receive_sclk0_o,
  output reg mosi_send_sclk_o,
  output reg mosi_send_sclk0_o,
  output[11:0]BaudRateDivisor_o);
  
  wire pre_sclk_s;
  reg[11:0]count_s;
  reg[11:0]count1_s;
  wire[11:0]BaudRateDivisor;
  
  assign BaudRateDivisor = ((sppr_i + 1)*(2**(spr_i + 1)));
  assign BaudRateDivisor_o = BaudRateDivisor/2; // here we are dividing by 2 because we want to acheive 1 complete sclk based on pclk/baudratedivisor ,so in order to toggle at half we are dividing it by 2 ,it will be 50% duty cycle ,for ex if we have pclk/8 then sclk will complete 1 cycle at 8 pclk's so we are toggling at pclk 4
  
  // Here Pre_clk depends upon CPOL 
  assign pre_clk_s = cpol_i ? 1'b1 : 1'b0;
  
  //SCLK generation
  always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
      count_s <= 12'b0;
      sclk_o <= pre_clk_s;
    end
    else if((~ss_i) && (spi_mode_i == 2'b00 || (spi_mode_i == 2'b01 && ~spiswai_i)))
    begin
      if(count_s == BaudRateDivisor/2-1'b1)begin
        sclk_o <= ~sclk_o;
        count_s <= 12'b0;
      end
      else
        count_s <= count_s + 1'b1;
    end
   else 
     begin
       count_s <= 12'b0;
       sclk_o <= pre_clk_s;
     end
  end
  
  
  //Logic to generate the flag to receive the miso data
  always@(posedge PCLK  or negedge PRESET_n)begin
    if(!PRESET_n)begin
      miso_receive_sclk_o <= 1'b0;
      miso_receive_sclk0_o <= 1'b0;
    end
    else begin
      if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))//Negative egde sampling
        begin  
        if(sclk_o)
          if(count_s == BaudRateDivisor/2 - 1'b1)//recieve signals after posedge or negedge
               miso_receive_sclk0_o <= 1'b1;
           else
             miso_receive_sclk0_o <= 1'b0;
           else
             miso_receive_sclk0_o <= 1'b0;
         end
         else begin
           if(~sclk_o)//Positive edge sampling
             if(count_s == BaudRateDivisor/2 - 1'b1)
               miso_receive_sclk_o <= 1'b1;
               else
                 miso_receive_sclk_o <= 1'b0;
           else
             miso_receive_sclk_o <= 1'b0;
         end
      end
  end
         
  //Logic to generate the flag to send mosi data
  always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
      mosi_send_sclk_o <= 1'b0;
      mosi_send_sclk0_o <= 1'b0;
    end
    else begin
      if((!cpol_i && cpha_i) || (cpol_i && cpha_i))begin
        if(sclk_o)
          if(count_s == BaudRateDivisor/2 - 2'b10)//transmit signals before posedge or negedge
            mosi_send_sclk0_o <= 1'b1;
        else
          mosi_send_sclk0_o <= 1'b0;
      else
        mosi_send_sclk0_o <= 1'b0;
      end
      else begin
        if(!sclk_o)
          if(count_s == BaudRateDivisor/2 - 2'b10)
            mosi_send_sclk_o <= 1'b1;
        else
          mosi_send_sclk_o <= 1'b0;
        else
          mosi_send_sclk_o <= 1'b0;
      end
    end
  end
  
endmodule
