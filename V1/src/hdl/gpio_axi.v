`timescale 1ps/1ps
//`define SIMULATION

module gpio_axi(
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
output [1:0] 		b_response,

////  io
input  [3:0] sw,
output reg [7:0] led
);

assign b_response = 0;
parameter ADDR_WIDTH = 1;
parameter DATA_WIDTH = 8; 

/////////////////////////////////////////////////////////   READ ///////////////////////////////////////
reg [ADDR_WIDTH-1:0] axi_araddr_buff;

reg read_start;
reg axi_arready_internal;
reg axi_rvalid_internal;

always @(*)
	axi_rdata = {28'd0, sw};

always @(negedge clk) begin
	if (rst)
		axi_rvalid_internal <= 1'b0;
	else if (axi_rvalid_internal && axi_rready)
		axi_rvalid_internal <= 1'b0;
	else if (read_start && (axi_arready_internal == 0))
		axi_rvalid_internal <= 1'b1;
end



always @(posedge clk) begin
	if (rst) begin
		axi_arready <= 0;
		axi_rvalid <= 0;
	end else begin
		axi_arready <= axi_arready_internal;
		axi_rvalid <= axi_rvalid_internal;
	end
end

always @(negedge clk) begin
	if (rst) begin
		axi_arready_internal <= 0;
		axi_araddr_buff <= 0;
		read_start <= 0;
	end else if (read_start == 0) begin
		read_start <= 1'b1;
		axi_arready_internal <= 1'b1;
	end else if (axi_arvalid && axi_arready_internal) begin
		axi_arready_internal <= 0;
		axi_araddr_buff <= axi_araddr[ADDR_WIDTH+1:2];
	end else if (axi_rready && axi_rvalid_internal) begin
		axi_arready_internal <= 1'b1;
	end
end


/////////////////////////////////////////////////////////////////////// WRITE //////////////////////////////////////////////////


reg [ADDR_WIDTH-1:0] axi_awaddr_buff;
reg [DATA_WIDTH-1:0] axi_wdata_buff;

reg [3:0] write_start; // need to delay writes to avoid overwriting instruction memory -- can remove this later once write feature to isntr mem removed

always @(posedge clk) begin
	if (rst) 
		b_valid <= 0;
	else if (write_start[2] && !axi_awready && !axi_wready) begin
		led <= axi_wdata_buff;
		b_valid <= 1'b1;
	end else if (write_start[2] && (axi_awready || axi_wready))
		b_valid <= 1'b0;
end


always @(negedge clk) begin
	if (rst) 
		write_start <= 0;
	else if (write_start < 4'd4)
		write_start <= write_start + 4'd1;
end


always @(negedge clk) begin
	if (rst) begin 
		axi_awaddr_buff <= 0;
		axi_awready	<= 0;
	end else if (write_start[2]) begin
		if (axi_awvalid && axi_awready) begin
			axi_awaddr_buff <= axi_awaddr[ADDR_WIDTH+1:2];
			axi_awready <= 0;
		end else if (!axi_awready && !axi_wready && b_ready)
			axi_awready <= 1'b1;	
	end
end



always @(negedge clk) begin
	if (rst) begin
		axi_wdata_buff <= 0;
		axi_wready	<= 0;
	end else if (write_start[2]) begin
		if (axi_wvalid && axi_wready) begin
			axi_wdata_buff <= axi_wdata[DATA_WIDTH-1:0];
			axi_wready <= 0;
		end else if (!axi_awready && !axi_wready)
			axi_wready <= 1'b1;	
	end
end


endmodule
