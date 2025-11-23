module APB_slave_interface(input PCLK,PRESET_n,
			   input [2:0]PADDR_i,
			   input PWRITE_i,PSEL_i,PENABLE_i,
			   input [7:0]PWDATA_i,miso_data_i,
			   input ss_i,receive_data_i,tip_i,
			   output reg [7:0]PRDATA_o,
			   output mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o,
			   output [2:0]sppr_o,spr_o,
			   output reg spi_interrupt_request_o,
			   output PREADY_o,PSLVERR_o,
			   output reg send_data_o,
		   output reg [7:0] mosi_data_o,
			   output reg [1:0] spi_mode_o);
//parameter macros
parameter SPI_APB_DATA_WIDTH=8,
	  SPI_REG_WIDTH=8,
	  SPI_APB_ADDR_WIDTH=3;
	  wire [7:0]cr2_mask,br_mask;
  	  assign cr2_mask=8'b00011011;
	  assign  br_mask=8'b01110111;
//declaring registers,wires and internal signals
reg[7:0] SPI_CR_1,SPI_CR_2,SPI_BR,SPI_DR;

reg sample_recieve;//to delay recieve signal

wire SPI_SR;
wire spif,sptef,modf,modfen,spe;
wire wr_enb,rd_enb;
//FSM for APB Slave interface
localparam IDLE=2'b00,
	   SETUP=2'b01,
	   ENABLE=2'b10;
reg[1:0]pre_state,next_state;
//present state logic
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		pre_state<=IDLE;
	else
		pre_state<=next_state;
end


always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		sample_recieve<=1'b0;
	else
		sample_recieve<=receive_data_i;
end

//next state logic
always@(*)
begin
	case(pre_state)
		IDLE:begin
			if(PSEL_i && !PENABLE_i)
				next_state=SETUP;
			else
				next_state=IDLE;
		end
		SETUP:begin
			if(PSEL_i && !PENABLE_i)
				next_state=SETUP;
			else if (PSEL_i && PENABLE_i)
				next_state=ENABLE;
			else
				next_state=IDLE;
		end
		ENABLE:begin
			if(PSEL_i)
				next_state=SETUP;
			else
				next_state=IDLE;
		end
		default:next_state=IDLE;
	endcase
end
//output logic
assign PREADY_o=(pre_state==ENABLE)? 1'b1:1'b0;
assign PSLVERR_o=(pre_state==ENABLE && tip_i)? 1'b1:1'b0;
assign wr_enb=(PWRITE_i && (pre_state==ENABLE))?1'b1:1'b0;
assign rd_enb=((!PWRITE_i) && (pre_state==ENABLE))?1'b1:1'b0;
//FSM for SPI Modes
//module spi_modes(PCLK,PRESET_n,spe,spiswai_O)
localparam spi_run=2'b00,
	   spi_wait=2'b01,
	   spi_stop=2'b10;
reg[1:0]next_state2;
//present state logic
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		spi_mode_o<=spi_run;
	else
		spi_mode_o<=next_state2;
end
//next state logic
always@(*)
begin
	case(spi_mode_o)
		spi_run: begin
			if(!spe)
				next_state2=spi_wait;
			else
				next_state2=spi_run;
		end
		spi_wait: begin
			if(spe)
				next_state2=spi_run;
			else if(spiswai_o)
				next_state2=spi_stop;
			else
				next_state2=spi_wait;
		end
		spi_stop: begin
			if(spe)
				next_state2=spi_run;
			else if(!spiswai_o)
				next_state2=spi_wait;
			else
				next_state2=spi_stop;
		end
		default:next_state2=spi_run;
	endcase
end
//sequential block for SPI_CR_1
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_CR_1<=8'h04;
	else
		begin
			if(wr_enb)
			begin
				if(PADDR_i==3'b000)
					SPI_CR_1<=PWDATA_i;
				else
					SPI_CR_1<=SPI_CR_1;
			end
			else begin
			    SPI_CR_1 <= SPI_CR_1;
				end
		end
end
//sequential block for SPI_CR_2
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_CR_2<=8'h00;
	else
	begin
		if(wr_enb)
		begin
			if(PADDR_i==3'b001)
				SPI_CR_2<= PWDATA_i & cr2_mask ;
			else
				SPI_CR_2<=SPI_CR_2;
		end
		else
		      SPI_CR_2 <= SPI_CR_2;
	end
end
//sequential block for BR Mask
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_BR<=8'h00;
	else
	begin
		if(wr_enb)
		begin
			if(PADDR_i==3'b010)
				SPI_BR<=(PWDATA_i &  br_mask);
			else
				SPI_BR<=SPI_BR;
		end
		else
			SPI_BR<=SPI_BR;
	end
end
//Implementing APB Read Data Path
always@(*)
begin
   PRDATA_o = 8'd0;
	if(rd_enb)
	begin
		case(PADDR_i)
			3'b000:PRDATA_o = SPI_CR_1;
			3'b001:PRDATA_o = SPI_CR_2;
			3'b010:PRDATA_o = SPI_BR;
			3'b011:PRDATA_o = SPI_SR;
			3'b101:PRDATA_o = SPI_DR;
			default:PRDATA_o =8'd0;
		endcase
	end
	else
		PRDATA_o=8'd0;
end
//to decode control register fields
assign {spie,spe,sptie,mstr_o,cpol_o,cpha_o,ssoe,lsbfe_o} = SPI_CR_1[7:0];
assign spiswai_o = SPI_CR_2[1];
assign modfen = SPI_CR_2[4];
assign sppr_o = SPI_BR[6:4];
assign spr_o = SPI_BR[2:0];
//detect mode fault(MODF)
assign modf = (!ss_i && mstr_o && modfen && !ssoe)? 1'b1:1'b0;
//to detect spi_interrupt_request_o based on SPI control bits and flags
assign sptef=(SPI_DR==8'b00000000) ?1'b1:1'b0;
assign spif=(SPI_DR==8'b00000000) ?1'b1:1'b0;
//updating status flags to SPI_SR
assign SPI_SR=(!PRESET_n)?{spif,1'b0,sptef,modf,4'b0}:8'b0010_0000;
//sequential block for send_data_o
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		send_data_o<=1'b0;
	else
	begin
		if(wr_enb)	
		//begin
			send_data_o<=1'b0;
		else
		begin
		if((SPI_DR==PWDATA_i) && (SPI_DR!=miso_data_i) && ((spi_mode_o==spi_run)||(spi_mode_o==spi_wait)))
			send_data_o<=1'b1;
		//end
		else
			send_data_o<=1'b0;
		end
		//else
			//send_data_o<=1'b0;
		
	end
end

//sequential block for mosi data
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		mosi_data_o<=8'b0;
	else if ((SPI_DR==PWDATA_i) && (SPI_DR!=miso_data_i) && ((spi_mode_o==spi_run)||(spi_mode_o==spi_wait)))
		mosi_data_o<=SPI_DR;
	else
		mosi_data_o<=mosi_data_o;
end
//sequential block for SPI_DR
always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		SPI_DR<=8'b0;
	else
	begin
		if(wr_enb)
		begin
			if(PADDR_i==3'b101)
				SPI_DR<=PWDATA_i;
			else
				SPI_DR<=SPI_DR;
		end
		else
		begin
			if(((SPI_DR==PWDATA_i) && (SPI_DR!=miso_data_i) && ((spi_mode_o==spi_run)||(spi_mode_o==spi_wait))))
				begin
					SPI_DR<=8'd0;
				end
				//else if(receive_data_i && ((spi_mode_o==spi_run) || (spi_mode_o==spi_wait)))
				else if(sample_recieve && ((spi_mode_o==spi_run) || (spi_mode_o==spi_wait)))
					SPI_DR<=miso_data_i;
		 		else
					SPI_DR<=SPI_DR;
			
			end
		//end
	end
end
//combinational logic for spi_interrup_request signal
always@(*)
begin
	if(spie && sptie)
		spi_interrupt_request_o=1'b0;
	else
	begin
		if(!sptie && spie)
			spi_interrupt_request_o=spif || sptie;
		else
		begin
			if(!spie && sptie)
				spi_interrupt_request_o=sptef;
			else
				spi_interrupt_request_o=spif || modf || sptef;
		end
	end
end
endmodule






			


