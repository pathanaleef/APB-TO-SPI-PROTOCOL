module shift_register(input PCLK,PRESET_n,ss_i,send_data_i,lsbfe_i,cpha_i,cpol_i,
		      input miso_receive_sclk_o,miso_receive_sclk0_o,
		      input mosi_send_sclk_o,mosi_send_sclk0_o,
		      input [7:0]data_mosi_i,
		      input miso_i,receive_data_i,
		      output reg mosi_o,
		      output reg[7:0]data_miso_o);
//internal signals
reg[7:0] shift_register,temp_reg;
reg [2:0]count,count1,count2,count3;
//Transmit data register logic
always@(posedge PCLK or negedge PRESET_n)
begin
       if(!PRESET_n)
	       shift_register<=8'd0;
       else
       begin
	       if(send_data_i)
		        shift_register<=data_mosi_i;
			else
				 shift_register<=shift_register;
	end
end
//Output Receive data
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		data_miso_o <=8'd0;
	else
	begin 
		if(receive_data_i)
			data_miso_o<=temp_reg;
		else
			data_miso_o <=data_miso_o;
	end
end
			
//Sequential logic for count/count1
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		mosi_o<=1'b0;
		count<=8'h00;
		count1<=8'h07;
	end
	else
		if(!ss_i)
		begin
			if((!cpha_i&&cpol_i)||(!cpol_i&&cpha_i))
			begin
				if(lsbfe_i)
				begin
					if(count<=3'd7)
					begin
						if(mosi_send_sclk0_o)
						begin
							mosi_o<=shift_register[count];
							count<=count+1'b1;
						end
					else
						count<=count;
					end
				end
				else
				begin
					if(count1>=3'd0)
					begin
						if(mosi_send_sclk0_o)
						begin
							mosi_o<=shift_register[count1];
							count1<=count1-1'b1;
						end
					else
						count1<=3'd7;
					end	
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(count<=3'd7)
					begin
						if(mosi_send_sclk_o)
						begin
							mosi_o<=shift_register[count];
							count<=count+1'b1;
						end
					else
						count<=count;
					end
				end
				else
				begin
					if(count1>=3'd0)
					begin
						if(mosi_send_sclk_o)
						begin
							mosi_o<=shift_register[count1];
							count1<=count1-1'b1;
						end
					else
						count1<=3'd7;
					end
				end	
			end
		end
	end
	

//Sequential logic for count2/count3
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		count2<=8'h00;
		count3<=8'h07;
		temp_reg<=8'd0;
	end
	else
		if(!ss_i)
		begin
			if((!cpha_i&&cpol_i)||(!cpol_i&&cpha_i))
			begin
				if(lsbfe_i)
				begin
					if(count2<=3'd7)
					begin
						if(miso_receive_sclk0_o)
						begin
							temp_reg[count2]<=miso_i;
							count2<=count2+1'b1;
						end
						else
							count2<=count2;
					end
				end
				else
				begin
					if(count3>=3'd0)
					begin
						if(miso_receive_sclk0_o)
						begin
							temp_reg[count3]<=miso_i;
							count3<=count3-1'b1;
						end
						else
							count3<=count3;
					end	
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(count2<=3'd7)
					begin
						if(miso_receive_sclk_o)
						begin
							temp_reg[count2]<=miso_i;
							count2<=count2+1'b1;
						end
						else
							count2<=count2;
					end
				end
				else
				begin
					if(count3>=3'd0)
					begin
						if(miso_receive_sclk_o)
						begin
							temp_reg[count3]<=miso_i;
							count3<=count3-1'b1;
						end
						else
							count3<=count3;
					end
				end	
			end
		end
	end
endmodule


/*//Sequential logic for temp_reg[count2],temp_reg[count3]
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		temp_reg[count2]<=8'h00;
		temp_reg[count3]<=8'h07;
	end
	else
		if(ss_i)
		begin
			temp_reg[count2]<=temp_reg[count2];
			temp_reg[count3]<=temp_reg[count3];
		end
		else
			if((!cpha_i&&cpol_i)||(!cpol_i&&cpha_i))
			begin
				if(lsbfe_i)
				begin
					if(temp_reg[count2]<=3'd7)
					begin 
						if(miso_receive_sclk0_o)
							temp_reg[count2]<=temp_reg[count2]+1'b1;
						else
							temp_reg[count2]<=3'd0;
					end
				end
				else
				begin
					if(temp_reg[count3]>=3'd0)
					begin 
						if(miso_receive_sclk0_o)
							temp_reg[count3]<=temp_reg[count3]-1'b1;
						else
							temp_reg[count3]<=3'd7;
					end
				end
			end
			else
			begin
				if(lsbfe_i)
				begin
					if(temp_reg[count2]<=3'd7)
					begin 
						if(miso_receive_sclk_o)
							temp_reg[count2]<=count2+1'b1;
						else
							temp_reg[count2]<=3'd0;
					end
				end
				else
				begin
					if(temp_reg[count3]>=3'd0)
					begin
						if(miso_receive_sclk_o)
							temp_reg[count3]<=temp_reg[count3]-1'b1;
						else
							temp_reg[count3]<=3'd7;
					end
				end
			end
		end*/





	
