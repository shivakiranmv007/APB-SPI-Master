// Code your testbench here
// or browse Examples
module spi_shifter_tb();
  reg PCLK = 1'b0 ;
  reg PRESETn;
  reg ss;
  reg send_data;
  reg lsbfe;
  reg cpha;
  reg cpol;
  reg miso_receive_sclk_o;
  reg miso_receive_sclk0_o;
  reg mosi_send_sclk_o;
  reg mosi_send_sclk0_o;
  reg [7:0]data_mosi;
  reg miso;
  reg receive_data;
  wire [7:0]data_miso;
  wire mosi;
  
  reg sclk;
  reg [11:0]count;
  wire pre_sclk;
  integer i;
  reg [2:0]spi_mode;
  reg spiswai;
  reg [11:0]baudrateDivisor;
  reg [2:0]sppr =0;
  reg [2:0]spr =0;
  
  spi_shifter dut(.PCLK(PCLK),
                  .PRESET_n(PRESETn),
                  .ss_i(ss),
                  .send_data_i(send_data),
                  .lsbfe_i(lsbfe),
                  .cpha_i(cpha),
                  .cpol_i(cpol),
                  .miso_receive_sclk_i(miso_receive_sclk_o),
                  .miso_receive_sclk0_i(miso_receive_sclk0_o),
                  .mosi_send_sclk_i(mosi_send_sclk_o),
                  .mosi_send_sclk0_i(mosi_send_sclk0_o),
                  .data_mosi_i(data_mosi),
                  .miso_i(miso),
                  .receive_data_i(receive_data),
                  .data_miso_o(data_miso),
                  .mosi_o(mosi));
  
  always #5 PCLK = ~PCLK;
  //always #10 sclk = ~sclk;
  //logic to generate pre_sclk based on the cpol
  assign pre_sclk = cpol? 1'b1 : 1'b0;
  always@*
    begin
   baudrateDivisor = ((sppr+1)*(2**(spr+1)));
   //  baudrateDivisor = 4;
    end
  
  //logic to generate a sclk
   always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          count <= 12'b0;
          sclk <= pre_sclk;
        end
      else if((~ss) && (spi_mode == 2'b00 || (spi_mode == 2'b01 && (~spiswai))))
        begin
          if(count == (baudrateDivisor/2 -1'b1))
            begin
              count <= 12'b0;
              sclk <= ~sclk;
            end
          else
            count <= count+1'b1;
        end
      else
        begin
          sclk <= pre_sclk;
          count <= 12'b0;
        end
    end
  
   //logic to generate the flag to receive miso data
  
  always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          miso_receive_sclk_o <= 1'b0;
          miso_receive_sclk0_o <= 1'b0;
        end
      else
        begin
          if((!cpha && cpol) || (cpha && !cpol)) //falling edge sampling data on miso
            begin
              if(sclk)
                if(count == (baudrateDivisor/2-2'b01))
                  miso_receive_sclk0_o <= 1'b1;
              else
                 miso_receive_sclk0_o <= 1'b0;
              else
                miso_receive_sclk0_o <= 1'b0;
            end
          else //rising edge samping data on miso
            begin
              if(~sclk)
                if(count == (baudrateDivisor/2-2'b01))
                  miso_receive_sclk_o <= 1'b1;
              else
                miso_receive_sclk_o <= 1'b0;
              else
                miso_receive_sclk_o <= 1'b0;
            end
        end
    end
  
  //logic to generate the flag to send mosi data
  always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          mosi_send_sclk_o <= 1'b0;
          mosi_send_sclk0_o <= 1'b0;
        end
      else
        begin
          if((!cpha && cpol) || (cpha && !cpol))
            begin
              if(sclk)
                if(count == (baudrateDivisor/2-2'b10))
                  mosi_send_sclk0_o <= 1'b1;
              else
                 mosi_send_sclk0_o <= 1'b0;
              else
                 mosi_send_sclk0_o <= 1'b0;
            end
          else
            begin
              if(~sclk)
                if(count == (baudrateDivisor/2-2'b10))
                  mosi_send_sclk_o <= 1'b1;
              else
                mosi_send_sclk_o <= 1'b0;
              else
                mosi_send_sclk_o <= 1'b0;
            end
        end
    end
  
  task reset;
    begin
      #1;
      PRESETn =1'b0;
      #25;
      PRESETn =1'b1;
    end
  endtask
  
  task initialize;
    begin
      PRESETn =1'b1;
      ss = 1'b1;
      lsbfe = 1'b1;
      cpol = 1'b0;
      cpha = 1'b1;
      miso = 1'b0;
      send_data = 1'b0;
      receive_data = 1'b0;
    end
  endtask
  
  //task for sampling of mosi data after sending
  task sample_posedge;
    begin
      PRESETn = 1'b1;
      @(posedge PCLK)
      send_data = 1'b1;
      data_mosi = 8'b11000011;
      
      //@(posedge PCLK)
      // send_data = 1'b0;
       @(posedge PCLK)
      ss = 1'b0;//start sending
      send_data = 1'b0;
      lsbfe = 1'b1;
      //start sampling at posedge 
      cpha = 1'b0;
      cpol = 1'b0;
      repeat(8)
        @(posedge sclk);
      @(posedge PCLK)
      receive_data = 1'b1;
      ss = 1'b1;
      @(posedge PCLK)
      @(posedge PCLK)
      receive_data = 1'b0;
      // ss = 1'b1;
    end
  endtask
       
          
  task sample_negedge;
    begin
      PRESETn = 1'b1;
      @(posedge PCLK)
      send_data = 1'b1;
      data_mosi = 8'b11000011;
     
     // @(posedge PCLK)
      //send_data = 1'b0;
       @(posedge PCLK)
      ss = 1'b0;//start sending
      lsbfe = 1'b1;
      send_data = 1'b0;
      //sampling at negedge
      cpha = 1'b1;
      cpol = 1'b0;
      repeat(8)
        @(negedge sclk);
      @(posedge PCLK)//after 8 clock cycles the received data will be in temp so after enabling receive into 1, that will transfer into DR
      receive_data = 1'b1;
       ss = 1'b1;
      @(posedge PCLK)
      @(posedge PCLK)
       receive_data = 1'b0;
        //ss = 1'b1;
    end
  endtask
  
  //here in this particular logic instead of receiving the mosi data from miso data , we are receiving the miso data as 1 for every sclk for 8times
  task send_miso_not_cphase;
    begin
      for(i=0 ; i<=7; i = i+1)
        begin
          @(negedge sclk)
            miso = 1'b1;
        end
    end
  endtask
  
  task baud_gen(input [2:0]i,j,input m,n);
    begin
      spi_mode = 2'b00;
      sppr = i;
      spr  = j;
      cpol = m;
      cpha = n;
      ss   = 1'b0;
      spiswai = 1'b0;
    end
  endtask
      
  initial begin
    initialize;
    #10;
    reset;
    #10;
    fork
      begin
        baud_gen(3'd0,3'd2,1'b0,1'b1);
       sample_posedge;
      end
      
      send_miso_not_cphase; // parallely receiving miso by using the fork join
    join
    
    fork 
      begin
        baud_gen(3'd0,3'd2,1'b0,1'b1);
       sample_negedge;
      end
      
       send_miso_not_cphase;
    join
    #500 ;
    $finish();
  end
  
  initial
    $monitor("time:%0d, sclk=%b, ss=%b,mosi=%b, data_mosi=%b,miso=%b,data_miso=%b,send_data=%b,receive_data=%b,cpol=%b,cpha=%b",$time,sclk,ss,mosi,data_mosi,miso,data_miso,send_data,receive_data,cpol,cpha);
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
      	
endmodule
