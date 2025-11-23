
module top_tb();
reg PCLK,PRESET_n;
reg [2:0]PADDR_i;
reg PWRITE_i, PSEL_i,PENABLE_i;
reg[7:0]PWDATA_i;
reg miso_i;
wire ss_o,sclk_o,spi_interrupt_request_o,mosi_o;
wire[7:0]PRDATA_o;
wire PREADY_o;
wire PSLVERR_o;
integer i;

top DUT(PCLK,
		  PRESET_n,
		  PADDR_i,
		  PWRITE_i, 
		  PSEL_i,
		  PENABLE_i,
		  PWDATA_i,
		  miso_i,
		  ss_o,
		  sclk_o,
		  spi_interrupt_request_o,
		  mosi_o,
		  PRDATA_o,
		  PREADY_o,
		  PSLVERR_o);
//clock generation
initial
begin
PCLK=1'b0;
forever #10 PCLK=~PCLK;
end
//task for reset
task reset();
begin
PRESET_n=1'b0;
#25;
PRESET_n=1'b1;
end
endtask
//task for write into CR1,CR2,BR
task write_ctrl_register(input[7:0]cntrl1_data,input[7:0]cntrl2_data,input [7:0]baud_data);
begin
	@(posedge PCLK)     //control register 1
	PADDR_i=3'd0;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b0;
	PWDATA_i=cntrl1_data;
	@(posedge PCLK)  
	PADDR_i=3'd0;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b1;
	PWDATA_i=cntrl1_data;
	@(posedge PCLK)
	wait(PREADY_o);
	PENABLE_i=1'b0;

	@(posedge PCLK)     //control register 2
	PADDR_i=3'd1;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b1;
	PWDATA_i=cntrl2_data;
	@(posedge PCLK)
	wait(PREADY_o);
	PENABLE_i=1'b0;

	
	@(posedge PCLK)     //Baud rate register 
	PADDR_i=3'b010;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b1;
	PWDATA_i=baud_data;
	@(posedge PCLK)
	wait(PREADY_o);
	PENABLE_i=1'b0;
end	
endtask

//Data register 
task write_data_register(input[7:0]write_data);
begin
	@(posedge PCLK)     
	PADDR_i=3'b101;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b0;
	PWDATA_i=write_data;
	@(posedge PCLK)  
	PADDR_i=3'b101;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b1;
	PWDATA_i=write_data;
	@(posedge PCLK)
	wait(PREADY_o);
	PENABLE_i=1'b0;
end
endtask
/*//task for read
task read(input[2:0]addr);
begin
	@(posedge PCLK)
	PADDR_i=addr;
	PWRITE_i=1'b0;
	PSEL_i=1'b1;
	PENABLE_i=1'b0;
	@(posedge PCLK)
	PENABLE_i=1'b1;
	@(posedge PCLK)
	PSEL_i=1'b0;
	PENABLE_i=1'b0;
#5;
$display("read addrs%b data=%b",addr,PRDATA_o);
end
endtask */


//write the MISO data through the MISO ports clklow to high shifting from index 0
task write_miso_data_lsbfe(input[7:0]miso_data);
begin
wait(~ss_o)
	
	miso_i=miso_data[0];
	//@(negedge sclk_o);
	for(i=1;i<=7;i=i+1)
	begin
		@(negedge sclk_o)
		miso_i=miso_data[i];
		
	end
end
endtask


//calling tasks
initial
begin
reset;
write_ctrl_register(8'b1111_1111,8'b1111_1000,8'b0000_0001);
write_data_register(8'b1100_1101);
//@(posedge PCLK)     
//PWRITE_i=1'b0;
write_miso_data_lsbfe(8'b0101_0101);
@(posedge PCLK)     
PWRITE_i=1'b0;
/*read(3'b010);
read(3'b001);
read(3'b101);*/
end
endmodule


 
