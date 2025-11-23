module apb_slave_interface_tb();
reg PCLK,PRESET_n;
reg [2:0]PADDR_i;
reg PWRITE_i,PSEL_i,PENABLE_i;
reg [7:0]PWDATA_i,miso_data;
reg ss_i,receive_i,tip_i;
wire [7:0]PRDATA_o;
wire mstr_o,cpol_o,cpha_o,isbfe_o,spiswai_o;
wire [2:0]sppr_o,spr_o;
wire spi_interrupt_request_o;
wire PREADY_o,PSLVERR_o;
wire send_data_o,mosi_data_o;
wire spi_mode_o;

apb_slave_interface DUT( PCLK,PRESET_n,PADDR_i,PWRITE_i,
				PSEL_i,PENABLE_i,PWDATA_i,miso_data, ss_i,receive_i,tip_i,
					PRDATA_o,mstr_o,cpol_o,cpha_o,isbfe_o,spiswai_o,sppr_o,spr_o,
 spi_interrupt_request_o,PREADY_o,PSLVERR_o,send_data_o,mosi_data_o,spi_mode_o);

//Generate  PCLk
initial
begin
PCLK=1'b0;
forever #10 PCLK=~PCLK;
end
//task for teset
task reset();
begin
PRESET_n=1'b0;
#25;
PRESET_n=1'b1;
end
endtask
//task for write
task write(input[2:0]addr,input[7:0]data);
begin
	@(posedge PCLK)
	PADDR_i=addr;
	PWRITE_i=1'b1;
	PSEL_i=1'b1;
	PENABLE_i=1'b0;
	PWDATA_i=data;
	@(posedge PCLK)
	PENABLE_i=1'b1;
	@(posedge PCLK)
	PSEL_i=1'b0;
	PENABLE_i=1'b0;
end
endtask
//task for read
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
endtask
//calling tasks
initial
begin
	PWRITE_i=1'b0;
	PSEL_i=1'b0;
	PENABLE_i=1'b0;
	PWDATA_i=8'd0;
	PADDR_i=3'd0;
	ss_i=1'b0;
	tip_i=~ss_i;
	receive_i=1'b0;
	reset;
	write(3'd0,8'hAA);
	read(3'b000);
	
	write(3'd1,8'hBD);
	read(3'b001);
	
	write(3'd2,8'hFF);
	read(3'b010);
	#20;
	$finish;
end
endmodule
