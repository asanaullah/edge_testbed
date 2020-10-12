module camera_axi(
    input clk,
    input rst,
	input [31:0] 			axi_araddr,
	input 			 	axi_arvalid,
	output reg 			axi_arready,
	input [31:0] 			axi_awaddr,
	input 			 	axi_awvalid,
	output reg			axi_awready,
	output reg [31:0] 		axi_rdata,
	output 	reg	 		axi_rvalid,
	input 			 	axi_rready,
	input [31:0] 			axi_wdata,
	input 			 	axi_wvalid,
	output 	reg		 	axi_wready,
	input 				b_ready,
	output 	reg			b_valid,
	output reg [1:0] 		b_response,
	input sda_in,
	output sda_out,
	output sda_sel,
	output scl,
	output ov_rst, 
	output ov_pwdn, 
	input ov_hs, 
	input ov_vs, 
	input [7:0] ov_d, 
	input ov_pclk, 
	output ov_mclk,
	output spi_clk,
	input spi_miso,
	output spi_mosi,
	output spi_cs
);
	parameter I2C_ADDR = 8'h60;
	assign ov_rst = 1'b0; // normal use : pull up high
	assign ov_pwdn = 1'b0; // normal user : low

	wire clk_spi; 
	wire clk_i2c;
	clk_gen clks (.rst(rst), .clk_83M(clk), .clk_spi(clk_spi), .clk_i2c(clk_i2c));
	
	
	reg i2c_start_trigger;
	reg [7:0] i2c_tx_data;
	reg [7:0] i2c_addr;
	reg [7:0] i2c_cmd;
	wire [7:0] i2c_rx_data;
	wire i2c_ack;
	wire i2c_busy;
	wire i2c_finish;
	
	reg spi_start_trigger;
	reg [7:0] spi_tx_data;
	reg [7:0] spi_cmd;
	wire [7:0] spi_rx_data;
	wire spi_busy;
	wire spi_finish;
	reg [7:0] state;
	
	
	always @(posedge clk) begin
		if (rst) begin
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 0;
			b_response <= 0;
			axi_rdata <= 0;
		end else if (state == 0) begin
			if (!i2c_busy && !spi_busy) begin
				axi_arready <= 1;
				axi_awready <= 1;
				axi_wready <= 1;
				axi_rvalid <= 0;
				b_valid <= 0;
			end else begin
				axi_arready <= 0;
				axi_awready <= 0;
				axi_wready <= 0;
				axi_rvalid <= 0;
				b_valid <= 0;
			end
		end else if (state == 8'd1) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 0;
		end else if (state == 8'd2) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 1;
			axi_rdata <= {23'd0,i2c_ack,i2c_rx_data};
			b_valid <= 0;
		end else if (state == 8'd3) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 1;
			axi_rvalid <= 0;
			b_valid <= 0;
		end else if (state == 8'd4) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 0;
		end else if (state == 8'd5) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 1;
		end else if (state == 8'd6) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 0;
		end else if (state == 8'd7) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 1;
			axi_rdata <= {24'd0,spi_rx_data};
			b_valid <= 0;
		end else if (state == 8'd8) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 1;
			axi_rvalid <= 0;
			b_valid <= 0;
		end else if (state == 8'd9) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 0;
		end else if (state == 8'd10) begin	
			axi_arready <= 0;
			axi_awready <= 0;
			axi_wready <= 0;
			axi_rvalid <= 0;
			b_valid <= 1;
		end
	end
		
		
			
	always @(negedge clk) begin
		if (rst) begin
			state <= 0;
			i2c_tx_data <= 0;
			i2c_addr <= 0;
			i2c_cmd <= 0;
			i2c_start_trigger <= 0;
			spi_tx_data <= 0;
			spi_cmd <= 0;
			spi_start_trigger <= 0;
			
		end else if (i2c_start_trigger && i2c_busy) begin
			i2c_start_trigger <= 0;
			
		end else if (spi_start_trigger && spi_busy) begin
			spi_start_trigger <= 0;
			
		end else if (state == 0 && !i2c_busy && !spi_busy) begin
			i2c_start_trigger <= 0;
			if (axi_arvalid) begin
				if (axi_araddr < 32'h00000400) begin
					i2c_addr <= {I2C_ADDR[7:1],1'b1};
					i2c_cmd <= axi_araddr[9:2];
					i2c_start_trigger <= 1'b1;
					state <= 8'd1;
				end else  begin
					spi_cmd <= {1'b0,axi_araddr[8:2]};
					spi_start_trigger <= 1'b1;
					state <= 8'd6;
				end
			end else if (axi_awvalid) begin
				if (axi_awaddr < 32'h00000400) begin
					i2c_addr <= {I2C_ADDR[7:1],1'b0};
					i2c_cmd <= axi_awaddr[9:2];
					state <= 8'd3;
					if (axi_wvalid) begin
						i2c_tx_data <= axi_wdata[7:0];
						i2c_start_trigger <= 1'b1;
						state <= 8'd4;
					end
				end else  begin
					spi_cmd <= {1'b1,axi_awaddr[8:2]};
					state <= 8'd8;
					if (axi_wvalid) begin
						spi_tx_data <= axi_wdata[7:0];
						spi_start_trigger <= 1'b1;
						state <= 8'd9;
					end
				end
			end
			
		end else if (state == 8'd1) begin
			if (i2c_finish)
				state <= 8'd2;
				
		end else if (state == 8'd2) begin
			if (axi_rready)
				state <= 8'd0;
				
		end else if (state == 8'd3) begin
			if (axi_wvalid) begin
				i2c_tx_data <= axi_wdata[7:0];
				i2c_start_trigger <= 1'b1;
				state <= 8'd4;
			end
	
		end else if (state == 8'd4) begin
			if (i2c_finish)
				state <= 8'd5;
		
		end else if (state == 8'd5) begin
			if (b_ready)
				state <= 8'd0;
				
		end else if (state == 8'd6) begin
			if (spi_finish)
				state <= 8'd7;
				
		end else if (state == 8'd7) begin
			if (axi_rready)
				state <= 8'd0;
				
		end else if (state == 8'd8) begin
			if (axi_wvalid) begin
				spi_tx_data <= axi_wdata[7:0];
				spi_start_trigger <= 1'b1;
				state <= 8'd9;
			end
	
		end else if (state == 8'd9) begin
			if (spi_finish)
				state <= 8'd10;
		
		end else if (state == 8'd10) begin
			if (b_ready)
				state <= 8'd0;
		end	
	end
	
	i2c_core i2C(
		.clk(clk_i2c),
		.reset(rst),
		.sda_in(sda_in),
		.sda_out(sda_out),
		.sda_sel(sda_sel),
		.scl(scl),
		
		.i2c_rx_data(i2c_rx_data),
		.i2c_busy(i2c_busy),
		.i2c_ack(i2c_ack),
		.i2c_addr(i2c_addr),
		.i2c_cmd(i2c_cmd),
		.i2c_tx_data(i2c_tx_data),
		.i2c_start_trigger(i2c_start_trigger),
		.i2c_finish(i2c_finish));
		
		
	spi spi_fsm
	  (
	   // Control/Data Signals,
	   .clk(clk_spi),
	   .rst(rst),
	   .tx_cmd(spi_cmd),
	   .tx_data(spi_tx_data),
	   .rx_data(spi_rx_data),
	   .trigger(spi_start_trigger),
	   .busy(spi_busy),
	   .finish(spi_finish),
	   // SPI Interface
	   .spi_clk(spi_clk),
	   .spi_miso(spi_miso),
	   .spi_mosi(spi_mosi),
	   .spi_cs(spi_cs)
	   );
	
endmodule


module clk_gen(input rst,input clk_83M,output clk_spi,output clk_i2c);
	reg [31:0] div_clk;
	initial div_clk <= 0;
	assign clk_spi = div_clk[3];
	assign clk_i2c = div_clk[16];	
	always @(posedge clk_83M) begin
		div_clk <= div_clk + 32'd1;
	end
endmodule
	

module i2c_core(
	input clk,
	input reset,
	input sda_in,
	output sda_out,
	output sda_sel,
	output scl,
	
	output reg [7:0] i2c_rx_data,
	output  i2c_busy,
	output reg i2c_ack,
	input [7:0] i2c_addr,
	input [7:0] i2c_cmd,
	input [7:0] i2c_tx_data,
	input i2c_start_trigger,
	output i2c_finish
  );
  

  wire [154:0] big_reg_w;
  wire [154:0] big_reg_r;
  reg [154:0] big_reg;
  reg rw;
  reg [7:0] state;
  
assign scl = ~ state[1];
 assign sda_out =  big_reg[8'd154 - state];
 assign sda_sel =  (((state >=  8'd35 ) && (state <= 8'd38) ) || ((state >=  8'd 71) && (state <= 8'd74)) || ((state >=  8'd115 ) && (state <= 8'd150))) ? 1'b1 : 
									(((state >=  8'd107) && (state <= 8'd110) ) ?  ~rw :
									 (((state >=  8'd111) && (state <= 8'd114) ) ?  rw :
									1'b0));
 assign i2c_finish =  (state == 8'd114) ?  ~rw :  ((state == 8'd154) ? 1'b1 : 1'b0);
 wire capture_data_input = ((state >=  8'd115 ) && (state <= 8'd145)) ? 1'b1 : 1'b0;
 wire capture_ack = (state >=  8'd35 ) && (state <= 8'd38) ? 1'b1: 1'b0;
  assign i2c_busy = (state == 8'd0) ?  1'b0 : 1'b1;
  
  always @(posedge scl) begin
	if (capture_data_input)
			i2c_rx_data <= {i2c_rx_data[6:0], sda_in};
	if (capture_ack)
			i2c_ack <= sda_in;
   end
   
  initial begin
  	state = 0;
  	big_reg = {155{1'b1}};
	rw = 0;
  end
  
  always @(posedge  clk ) begin   //8
		if (reset) begin
				state <= 0;
				big_reg <= {155{1'b1}};
				rw <= 0;
		end else if (i2c_finish) begin
				state <= 0;
				big_reg <= {155{1'b1}};
				rw <= 0;
		end else if (state == 0) begin
				state <= {7'd0,i2c_start_trigger};
				rw <= i2c_addr[0];
				big_reg <= (i2c_addr[0]) ? big_reg_r: big_reg_w;
		end else
				state <= state + 8'd1;
end
	

  assign big_reg_r = {1'b1, 2'd0, {4{i2c_addr[7]}},  {4{i2c_addr[6]}}, {4{i2c_addr[5]}}, {4{i2c_addr[4]}}, {4{i2c_addr[3]}}, {4{i2c_addr[2]}}, {4{i2c_addr[1]}}, 4'd0,  
										4'b1111,  
										{4{i2c_cmd[7]}},  {4{i2c_cmd[6]}}, {4{i2c_cmd[5]}}, {4{i2c_cmd[4]}}, {4{i2c_cmd[3]}}, {4{i2c_cmd[2]}}, {4{i2c_cmd[1]}}, {4{i2c_cmd[0]}}, 
										4'b1111,
										2'b11, 2'b00,
										{4{i2c_addr[7]}},  {4{i2c_addr[6]}}, {4{i2c_addr[5]}}, {4{i2c_addr[4]}}, {4{i2c_addr[3]}}, {4{i2c_addr[2]}}, {4{i2c_addr[1]}}, {4{i2c_addr[0]}},
										4'b1111,
										32'hFFFF_FFFF,
										4'b1111,
										2'b00,
										2'b11};
										
	  assign big_reg_w = {1'b1, 2'd0, {4{i2c_addr[7]}},  {4{i2c_addr[6]}}, {4{i2c_addr[5]}}, {4{i2c_addr[4]}}, {4{i2c_addr[3]}}, {4{i2c_addr[2]}}, {4{i2c_addr[1]}}, {4{i2c_addr[0]}},  
										4'b1111,  
										{4{i2c_cmd[7]}},  {4{i2c_cmd[6]}}, {4{i2c_cmd[5]}}, {4{i2c_cmd[4]}}, {4{i2c_cmd[3]}}, {4{i2c_cmd[2]}}, {4{i2c_cmd[1]}}, {4{i2c_cmd[0]}}, 
										4'b1111,
										{4{i2c_tx_data[7]}},  {4{i2c_tx_data[6]}}, {4{i2c_tx_data[5]}}, {4{i2c_tx_data[4]}}, {4{i2c_tx_data[3]}}, {4{i2c_tx_data[2]}}, {4{i2c_tx_data[1]}}, {4{i2c_tx_data[0]}},
										4'b1111,
										2'b00,
										42'h3FF_FFFF_FFFF};
										
endmodule


module spi
  (
   // Control/Data Signals,
   input clk,
   input rst,
   input [7:0] tx_cmd,
   input [7:0] tx_data,
   output reg [7:0] rx_data,
   input trigger,
   output busy,
   output finish, 
   
   output spi_clk,
   input spi_miso,
   output spi_mosi,
   output  spi_cs
 ); 


  
 
  
  wire reset = rst;
  

  reg [64:0] data_reg;
  reg [64:0] clk_reg;
  reg [7:0] state;
  
 assign spi_cs = (state == 8'd0) ?  1'b1 : 1'b0;
 assign spi_mosi =  data_reg[state];
 assign spi_clk =   clk_reg[state];
 assign finish =  (state >= 8'd64) ?  1'b1 : 1'b0;
 wire capture_data_input = (state > 0) ? 1'b1 : 1'b0;
 assign busy = (state == 8'd0) ?  1'b0 : 1'b1;
  
  always @(posedge spi_clk) begin
	if (capture_data_input)
			rx_data <= {rx_data[6:0], spi_miso};
   end
   
  initial begin
	  state = 0;
	  data_reg = 0;
	  clk_reg = 0;
  end
  
  always @(posedge  clk ) begin   //8
		if (reset) begin
				state <= 0;
				data_reg <= 0;
				clk_reg <= 0;
		end else if (finish) begin
				state <= 0;
				data_reg <= 0;
				clk_reg <= 0;		
		end else if (state == 0) begin
				state <= {7'd0,trigger};
				data_reg <= {
				{4{tx_data[0]}},  {4{tx_data[1]}}, {4{tx_data[2]}}, {4{tx_data[3]}}, {4{tx_data[4]}}, {4{tx_data[5]}}, {4{tx_data[6]}}, {4{tx_data[7]}},
                {4{tx_cmd[0]}},  {4{tx_cmd[1]}}, {4{tx_cmd[2]}}, {4{tx_cmd[3]}}, {4{tx_cmd[4]}}, {4{tx_cmd[5]}}, {4{tx_cmd[6]}}, {5{tx_cmd[7]}}				
				};
				clk_reg <= {{16{4'b0110}} , 1'b0};
		end else
				state <= state + 8'd1;
end
								
endmodule
