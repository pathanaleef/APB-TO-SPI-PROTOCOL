module top(input PCLK,
	   input PRESET_n,
	   input[2:0]PADDR_i,
	   input PWRITE_i,
	   input PSEL_i,
	   input PENABLE_i,
	   input[7:0]PWDATA_i,
   	input miso_i,
     	output ss_o,
	   output sclk_o,
	   output spi_interrupt_request_o,
	   output mosi_o,
   	output[7:0]PRDATA_o,
   	output PREADY_o,
	   output PSLVERR_o);
//internal wires for spi baud rate generator
wire[1:0]spi_mode;
wire spiswai;
wire [2:0]sppr,spr;
wire cpol,cpha;
wire miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0;
wire [11:0]BaudRateDivisor;
//internal wires for shift register
wire send_data,lsbfe;
wire[7:0]data_mosi;
wire receive_data;
wire [7:0]data_miso;
//internal wires for shift apb slave interface
//wire [7:0]miso_data;
wire tip;
wire mstr;



spi_baud_generator M1(  .PCLK(PCLK),//from top module
								.PRESET_n(PRESET_n),// from top module
								.spi_mode_i(spi_mode),//from apb_slave
								.spiswai_i(spiswai),//from apb_slave
								.sppr_i(sppr),//from apb_slave
								.spr_i(spr),//from apb_slave
								.cpol_i(cpol),//from apb_slave
								.cpha_i(cpha),//from apb_slave
								.ss_i(ss_o),//from SS 
								.sclk_o(sclk_o),// from top module
								.miso_receive_sclk_o(miso_receive_sclk),//input to shifter
								.miso_receive_sclk0_o(miso_receive_sclk0),//input to shifter
								.mosi_send_sclk_o(mosi_send_sclk),//input to shifter
								.mosi_send_sclk0_o(mosi_send_sclk0),//input to shifter
								.BaudRateDivisor_o(BaudRateDivisor));//input to SS


shift_register M2(.PCLK(PCLK),// from top module
						.PRESET_n(PRESET_n),// from top module
						.ss_i(ss_o),//output from SS block and input to APB slave
						.send_data_i(send_data),//output from APB interface
						.lsbfe_i(lsbfe),//output from APB interface
						.cpha_i(cpha),//output from APB interface
						.cpol_i(cpol),//output from APB interface
						.miso_receive_sclk_o(miso_receive_sclk),//output from BG block
						.miso_receive_sclk0_o(miso_receive_sclk0),//output from BG block
						.mosi_send_sclk_o(mosi_send_sclk),//output from BG block
						.mosi_send_sclk0_o(mosi_send_sclk0),//output from BG block
						.data_mosi_i(data_mosi),
						.miso_i(miso_i),//output from top module
						.receive_data_i(receive_data),
						.mosi_o(mosi_o),//output from top module
						.data_miso_o(data_miso));//input to APB interface



apb_slave_interface M3(.PCLK(PCLK),// from top test bench
							  .PRESET_n(PRESET_n),// from top test bench
							  .PADDR_i(PADDR_i),// from top test bench
							  .PWRITE_i(PWRITE_i),// from top test bench
							  .PSEL_i(PSEL_i),// from top test bench
							  .PENABLE_i(PENABLE_i),// from top test bench
							  .PWDATA_i(PWDATA_i),// from top test bench
							  .miso_data_i(data_miso),//output from shift register
							  .ss_i(ss_o),//output from SS
							  .receive_data_i(receive_data),//output from SS
							  .tip_i(tip),//output from SS
							  .PRDATA_o(PRDATA_o),//top module output
							  .mstr_o(mstr),//input to SS block
							  .cpol_o(cpol),//input to BG
							  .cpha_o(cpha),//input to BG
							  .lsbfe_o(lsbfe),
							  .spiswai_o(spiswai),
							  .sppr_o(sppr),
							  .spr_o(spr),
							  .spi_interrupt_request_o(spi_interrupt_request_o),//top module output
							  .PREADY_o(PREADY_o),//top module output
							  .PSLVERR_o(PSLVERR_o),//top module output
							  .send_data_o(send_data),
							  .mosi_data_o(data_mosi),
							  .spi_mode_o(spi_mode));


spi_slave_select M4(.PCLK(PCLK),// from top module
						  .PRESET_n(PRESET_n),// from top module
						  .mstr_i(mstr),//output from APB interface
						  .spiswai_i(spiswai),//output from APB interface
						  .spi_mode_i(spi_mode),//output from APB interface
						  .send_data_i(send_data),//output from APB interface
						  .BaudRateDivisor_i(BaudRateDivisor),//output from BG block
						  .receive_data_o(receive_data),//input to shifter
						  .ss_o(ss_o),//input to shift_register and BG block
						  .tip_o(tip));//input to APB interface


endmodule

