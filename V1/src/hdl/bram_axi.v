`timescale 1ps/1ps

module bram_axi(
clk,rst,
axi_araddr,axi_arvalid,axi_arready,
axi_awaddr,axi_awvalid,axi_awready,
axi_rdata,axi_rvalid,axi_rready,
axi_wdata,axi_wstrb,axi_wvalid,axi_wready,
b_ready,b_valid,b_response
);


parameter ADDR_WIDTH = 10;
parameter DATA_WIDTH = 32;

input clk;
input rst;
input 		[ADDR_WIDTH-1:0] 	axi_araddr;
input 			 		axi_arvalid;
output	reg 				axi_arready;
input 		[ADDR_WIDTH-1:0] 	axi_awaddr;
input 			 		axi_awvalid;
output	reg				axi_awready;
output	reg 	[DATA_WIDTH-1:0] 	axi_rdata;
output	reg	 			axi_rvalid;
input 			 		axi_rready;
input 		[DATA_WIDTH-1:0] 	axi_wdata;
input 		[(DATA_WIDTH>>3)-1:0] 	axi_wstrb;
input 			 		axi_wvalid;
output	reg				axi_wready;
input 					b_ready;
output	reg				b_valid;
output	[1:0] 			b_response;



reg [ADDR_WIDTH-1:0] axi_araddr_buff;
reg axi_arready_internal;
reg axi_rvalid_internal;
reg [ADDR_WIDTH-1:0] axi_awaddr_buff;
reg [DATA_WIDTH-1:0] axi_wdata_buff;
reg [(DATA_WIDTH>>3)-1:0] axi_wstrb_buff;

assign b_response = 0;
//////////////////////////////////////////////////////////  MEMORY /////////////////////////////////////

reg [DATA_WIDTH-1:0] mem [0: (2**ADDR_WIDTH)-1];

integer i;
initial begin
	for (i = 0 ; i < (2**ADDR_WIDTH); i=i+1) begin
	mem[i] = 0;		
	end
end

/////////////////////////////////////////////////////////   READ ///////////////////////////////////////

always @(posedge clk) begin
	axi_rdata = mem[axi_araddr_buff];
	if (rst) begin
		axi_arready <= 0;
		axi_rvalid <= 0;
	end else begin
		axi_arready <= axi_arready_internal;
		axi_rvalid <= axi_rvalid_internal;
	end
end


always @(negedge clk) begin
	if (rst)
		axi_rvalid_internal <= 1'b0;
	else if (axi_rvalid_internal && axi_rready)
		axi_rvalid_internal <= 1'b0;
	else if (axi_arready_internal == 0)
		axi_rvalid_internal <= 1'b1;
end




always @(negedge clk) begin
	if (rst) begin
		axi_arready_internal <= 1;
		axi_araddr_buff <= 0;
	end else if (axi_arvalid && axi_arready_internal) begin
		axi_arready_internal <= 0;
		axi_araddr_buff <= axi_araddr;
	end else if (axi_rvalid_internal && axi_rready) begin
		axi_arready_internal <= 1'b1;
	end
end

/////////////////////////////////////////////////////////////////////// WRITE //////////////////////////////////////////////////


reg [DATA_WIDTH-1:0] write_data;
reg [DATA_WIDTH-1:0] write_data_masked;
reg [2:0] w_state;
	
integer j;
always @(*) begin
	for (j=0; j < (DATA_WIDTH>>3); j=j+1) begin
		write_data_masked[(j<<3)+:8] = axi_wstrb_buff[j] ? axi_wdata_buff[(j<<3)+:8] : write_data[(j<<3)+:8];
	end
end

always @(posedge clk) begin
	if (rst) 
		b_valid <= 0;
	else if (w_state == 3'd4)
		b_valid <= 1'b1;
	else 
		b_valid <= 1'b0;
end
	

reg axi_wready_internal;
reg axi_awready_internal;

always @(posedge clk) begin
	axi_wready <= axi_wready_internal;
	axi_awready <= axi_awready_internal;
end

always @(negedge clk) begin
	if (rst) begin 
		axi_awaddr_buff <= 0;
		axi_awready_internal	<= 0;
		axi_wdata_buff <= 0;
		axi_wready_internal	<= 0;
		w_state <= 0;	
	end else if (w_state == 0) begin
		axi_wready_internal	<= 1;
		axi_awready_internal	<= 1;
		if (axi_awvalid) begin
			axi_awaddr_buff <= axi_awaddr;
			axi_awready_internal	<= 0;
			w_state <= 3'd1;
			if (axi_wvalid) begin
				axi_wdata_buff <=  axi_wdata;
				axi_wstrb_buff <= axi_wstrb;
				axi_wready_internal	<= 0;
				w_state <= 3'd2;
			end
		end	
	end else if (w_state == 3'd1) begin
		if (axi_wvalid) begin
			axi_wdata_buff <=  axi_wdata;
			axi_wstrb_buff <= axi_wstrb;
			axi_wready_internal	<= 0;
			w_state <= 3'd2;
		end		
	end else if (w_state == 3'd2) begin
		write_data <= mem[axi_awaddr_buff];
		w_state <= 3'd3;			
	end else if (w_state == 3'd3) begin
		mem[axi_awaddr_buff] <= write_data_masked; 
		w_state <= 3'd4;
	end else if (w_state == 3'd4) begin
		if (b_ready) 
			w_state <= 3'd0;
	end
end
endmodule

