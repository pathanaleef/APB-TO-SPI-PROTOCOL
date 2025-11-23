module spi_baud_generator_tb();
reg PCLK,PRESET_n;
reg [1:0]spi_mode_i;
reg  spiswai_i;
reg [2:0]sppr_i,spr_i;
reg  cpol_i,cpha_i,ss_i;
wire sclk_o,miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o;
wire [11:0]BaudRateDivisor_o;
spi_baud_generator DUT(PCLK,PRESET_n,spi_mode_i,spiswai_i,sppr_i,spr_i,cpol_i,cpha_i,ss_i,sclk_o,miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,BaudRateDivisor_o);
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
spi_mode_i=2'd0;
spiswai_i=1'b0;
sppr_i=1'b0;
spr_i=1'b0;
cpol_i=1'b0;
cpha_i=1'b0;
ss_i=1'b1;
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
//task for driving spi_modes
task spi_modes(input[1:0]i,input j,k);
begin
spi_mode_i=i;
spiswai_i=j;
ss_i=k;
end
endtask
//task for driving sppr_i,spr_i
task sppr_spr(input [2:0]m,n);
begin 
sppr_i=m;
spr_i=n;
end
endtask
//task for driving cpol,cpha
task cpol_cpha(input x,y);
begin
cpol_i=x;
cpha_i=y;
end
endtask
//calling tasks
initial
begin
initialize;
reset;
spi_modes(2'b00,1'b0,1'b0);
sppr_spr(3'b000,3'b001);
cpol_cpha(1'b1,1'b1);
end
endmodule

