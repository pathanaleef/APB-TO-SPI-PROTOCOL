module spi_slave_select_tb();
reg PCLK,PRESET_n;
reg [1:0]spi_mode_i;
reg  spiswai_i,mstr_i,send_data_i;
reg [11:0]BaudRateDivisor_i;
wire receive_data_o,ss_o,tip_o;
spi_slave_select DUT(PCLK,PRESET_n,mstr_i,spiswai_i,spi_mode_i,send_data_i,BaudRateDivisor_i,receive_data_o,ss_o,tip_o);
//Generate  PCLk
initial
begin
PCLK=1'b0;
forever #10 PCLK=~PCLK;
end
//task for initialization
task initialize();
begin
PRESET_n=1'b1;
mstr_i=1'b1;
spi_mode_i=2'd0;
spiswai_i=1'b0;
send_data_i=1'b0;
BaudRateDivisor_i=12'd0;
end
endtask
//task for teset
task reset();
begin
PRESET_n=1'b0;
#25;
PRESET_n=1'b1;
end
endtask
//task for driving input modes
task inputs(input i,j,input[1:0]k,input [11:0]y);
begin
mstr_i=i;
spiswai_i=j;
spi_mode_i=k;
BaudRateDivisor_i=y;
end
endtask
//task for send data
task senddata(input x);
begin
send_data_i=x;
end
endtask
//calling tasks
initial
begin
initialize;
reset;
inputs(1'b1,1'b0,2'b00,12'd2);
senddata(1'b1);
#20;
senddata(1'b0);
end
endmodule

