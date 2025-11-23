module spi_baud_generator(input PCLK,PRESET_n,
								  input[1:0]spi_mode_i,
								  input spiswai_i,
								  input[2:0]sppr_i,spr_i,
								  input cpol_i,cpha_i,ss_i,
								  output reg sclk_o,miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,
								  output [11:0]BaudRateDivisor_o);
wire pre_sclk_s;
reg[11:0] count_s;
//compute Baud Rate Divisor
assign BaudRateDivisor_o = (sppr_i+1)*(2**(spr_i+1));
//Generate Initial SCLK Polarity
assign pre_sclk_s = cpol_i?1'b1:1'b0;
//Generate SPI Clock
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		count_s<=12'd0;
		sclk_o<=pre_sclk_s;
	end
	else if (!ss_i && !spiswai_i && ((spi_mode_i==2'b00)||(spi_mode_i==2'b01) ))
	begin
		if(count_s == (BaudRateDivisor_o/2-1))
		begin
			sclk_o<=~sclk_o;
			count_s<=12'd0;
		end
		else
			count_s<=count_s+1;
		end
	else
	begin
		sclk_o<=1'b0;
		count_s<=1'b0;
	end
end
//Generate MISO sample flags
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		miso_receive_sclk_o <= 1'b0;
		miso_receive_sclk0_o <= 1'b0;
	end
	else if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
		begin
			if(sclk_o) 
			begin
				if(count_s==(BaudRateDivisor_o/2-1))
				miso_receive_sclk0_o <=1'b1;
			   else
				miso_receive_sclk0_o <= 1'b0;
		        end
		   else
			miso_receive_sclk0_o <= 1'b0;
	end

          else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
	  begin
		  if(!sclk_o)
		  begin
			 if(count_s==(BaudRateDivisor_o/2-1))
			  	miso_receive_sclk_o <=1'b1;
			else
				miso_receive_sclk_o <= 1'b0;
	       	  end
		  else
	        	miso_receive_sclk_o <= 1'b0;
	end
	else
	begin
			miso_receive_sclk0_o <= 1'b0;
			miso_receive_sclk_o <= 1'b0;
	end
	end
//Generate MOSI sample flags
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		mosi_send_sclk_o <= 1'b0;
		mosi_send_sclk0_o <= 1'b0;
	end
	else if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
		begin
			if(sclk_o) 
			begin
				if(count_s==(BaudRateDivisor_o/2-2))
				mosi_send_sclk0_o <=1'b1;
			        else
				mosi_send_sclk0_o <= 1'b0;
		        end
			else
			mosi_send_sclk0_o <= 1'b0;

	end

          else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
	  begin
		  if(!sclk_o)
		  begin
			 if( count_s==(BaudRateDivisor_o/2-2))
			  	mosi_send_sclk_o <=1'b1;
			else
				mosi_send_sclk_o <= 1'b0;
	       	  end
		  else
	        	mosi_send_sclk_o <= 1'b0;
	end
	else
	begin
			mosi_send_sclk0_o <= 1'b0;
			mosi_send_sclk_o <= 1'b0;
	end
end
endmodule






