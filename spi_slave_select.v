module spi_slave_select(input PCLK,PRESET_n,mstr_i,spiswai_i,
			input[1:0] spi_mode_i,
			input send_data_i,
			input[11:0]BaudRateDivisor_i,
			output reg receive_data_o,ss_o,
			output tip_o);
//internal signals
reg [15:0]count_s;
wire [15:0]target_s;
reg rcv_s;
//continuous assignment
assign target_s=((BaudRateDivisor_i/2)*16);
assign tip_o=~ss_o;
//sequential block receive_data
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		receive_data_o<=1'b0;
	else
		receive_data_o<=rcv_s;
end
//sequential block for internal varaiable-rcv_s
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		rcv_s<=1'b0;
	else if((!spiswai_i&&(spi_mode_i==2'b01) || (spi_mode_i==2'b00)) && mstr_i) 
	begin
		if(send_data_i)
			rcv_s<=1'b0;
		else if(count_s <= target_s-1'b1)
		begin
			if(count_s == target_s-1'b1)
				rcv_s<=1'b1;
			else
				rcv_s<=1'b0;
		end
		else rcv_s<=1'b0;
	end
else rcv_s<=1'b0;
end
//sequential block for slave select
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		ss_o<=1'b1;
	else
	begin
		if((!spiswai_i&&(spi_mode_i==2'b01) || (spi_mode_i==2'b00)) && mstr_i) 
		begin
			if(!send_data_i)
			begin
				if(count_s <= target_s-1'b1)
					ss_o<=1'b0;
				else
					ss_o<=1'b1;
			end
			else
				ss_o<=1'b0;
		end
		else
				ss_o<=1'b1;
	end

end
//sequential block for count variable
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		count_s<=16'hffff;
	else if((!spiswai_i&&(spi_mode_i==2'b01) || (spi_mode_i==2'b00)) && mstr_i) 
	begin
		if(send_data_i)
			count_s<=16'b0;
		else if(count_s <= target_s-1'b1)
			count_s<=count_s+1'b1;
		else
				count_s<=16'hffff;
		end
	else 
		count_s<=16'hffff;
end
endmodule


//sequential block for internal varaiable-rcv_s
/*always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		rcv_s<=1'b0;
	else
	begin 
		if((!spiswai_i&&(spi_mode_i==2'b01) || (spi_mode_i==2'b00)) && mstr_i)
			rcv_s<=1'b1;
		else if(!send_data_i)
			rcv_s<=1'b1;
		else if(count_s < target_s-1'b1)
			rcv_s<=1'b0;
		else if(count_s == target_s-1'b1)
			rcv_s<=1'b1;
		else
			rcv_s<=1'b0;
 	end

end
//sequential block for slave select
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		ss_o<=1'b1;
	else
	begin 
		if((!spiswai_i&&(spi_mode_i==2'b01) || (spi_mode_i==2'b00)) && mstr_i)
			ss_o<=1'b0;
		else if(send_data_i)
			ss_o<=1'b0;
		else if(count_s< target_s-1'b1)
			ss_o<=1'b0;
		else if (count_s==target_s-1'b1)
			ss_o<=1'b1;
 		end
end
//sequential block for count varaiable
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		count_s<=16'hffff;
	else
	begin 
		if((!spiswai_i&&(spi_mode_i==2'b01) || (spi_mode_i==2'b00)) && mstr_i)
			count_s<=16'd1;
		else if(!send_data_i)
			count_s<=16'd1;
		else if(count_s< target_s-1'b1)
			count_s<=count_s+1'b1;
		else if (count_s==target_s-1'b1)
			count_s<=16'hffff;
 		end
end
endmodule*/






	



