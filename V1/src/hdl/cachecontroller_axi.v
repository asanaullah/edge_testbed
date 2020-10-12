`timescale 1ps/1ps
module cachecontroller_axi(
clk,rst,w_processing,

axi_araddr,axi_arvalid,axi_arready,
axi_awaddr,axi_awvalid,axi_awready,
axi_rdata,axi_rvalid,axi_rready,
axi_wdata,axi_wstrb,axi_wvalid,axi_wready,
b_ready,b_valid,b_response,

ddr_axi_araddr,ddr_axi_arvalid,ddr_axi_arready,
ddr_axi_awaddr,ddr_axi_awvalid,ddr_axi_awready,
ddr_axi_rdata,ddr_axi_rvalid,ddr_axi_rready,
ddr_axi_wdata,ddr_axi_wstrb,ddr_axi_wvalid,ddr_axi_wready,
ddr_b_ready,ddr_b_valid,ddr_b_response,

table_axi_araddr,table_axi_arvalid,table_axi_arready,
table_axi_awaddr,table_axi_awvalid,table_axi_awready,
table_axi_rdata,table_axi_rvalid,table_axi_rready,
table_axi_wdata,table_axi_wstrb,table_axi_wvalid,table_axi_wready,
table_b_ready,table_b_valid,table_b_response,

L1_axi_araddr,L1_axi_arvalid,L1_axi_arready,
L1_axi_awaddr,L1_axi_awvalid,L1_axi_awready,
L1_axi_rdata,L1_axi_rvalid,L1_axi_rready,
L1_axi_wdata,L1_axi_wstrb,L1_axi_wvalid,L1_axi_wready,
L1_b_ready,L1_b_valid,L1_b_response
);


parameter CACHE_ADDR_SIZE = 10;
parameter MEM_ADDR_SIZE = 28;
parameter DATA_WIDTH = 32;
parameter CACHE_TABLE_DATA_WIDTH = MEM_ADDR_SIZE-CACHE_ADDR_SIZE-2;




input clk;
input rst;
output 				w_processing;

input 		[MEM_ADDR_SIZE-1:0] 			axi_araddr;
input 			 				axi_arvalid;
output	reg 						axi_arready;
input 		[MEM_ADDR_SIZE-1:0] 			axi_awaddr;
input 			 				axi_awvalid;
output	reg						axi_awready;
output	reg 	[DATA_WIDTH-1:0] 			axi_rdata;
output	reg	 					axi_rvalid;
input 			 				axi_rready;
input 		[DATA_WIDTH-1:0] 			axi_wdata;
input 		[(DATA_WIDTH>>3)-1:0] 			axi_wstrb;
input 			 				axi_wvalid;
output	reg						axi_wready;
input 							b_ready;
output	reg						b_valid;
output	reg 	[1:0] 					b_response;


output	reg 	[MEM_ADDR_SIZE-1:0]			ddr_axi_araddr;
output	reg						ddr_axi_arvalid;
input							ddr_axi_arready;
output	reg 	[MEM_ADDR_SIZE-1:0]			ddr_axi_awaddr;
output	reg						ddr_axi_awvalid;
input							ddr_axi_awready;
input 		[DATA_WIDTH-1:0]			ddr_axi_rdata;
input							ddr_axi_rvalid;
output	reg						ddr_axi_rready;
output	reg 	[DATA_WIDTH-1:0]			ddr_axi_wdata;
output   	[(DATA_WIDTH>>3)-1:0]			ddr_axi_wstrb;
output	reg						ddr_axi_wvalid;
input							ddr_axi_wready;
output	reg						ddr_b_ready;
input							ddr_b_valid;
input 		[1:0]					ddr_b_response;

output	reg 	[CACHE_ADDR_SIZE-1:0]			table_axi_araddr;
output	reg						table_axi_arvalid;
input							table_axi_arready;
output	reg 	[CACHE_ADDR_SIZE-1:0]			table_axi_awaddr;
output	reg						table_axi_awvalid;
input							table_axi_awready;
input 		[CACHE_TABLE_DATA_WIDTH-1:0]		table_axi_rdata;
input							table_axi_rvalid;
output	reg						table_axi_rready;
output	reg 	[CACHE_TABLE_DATA_WIDTH-1:0]		table_axi_wdata;
output   	[(CACHE_TABLE_DATA_WIDTH>>3)-1:0]	table_axi_wstrb;
output	reg						table_axi_wvalid;
input							table_axi_wready;
output	reg						table_b_ready;
input							table_b_valid;
input 		[1:0]					table_b_response;


output	reg 	[CACHE_ADDR_SIZE-1:0]			L1_axi_araddr;
output	reg						L1_axi_arvalid;
input							L1_axi_arready;
output	reg 	[CACHE_ADDR_SIZE-1:0]			L1_axi_awaddr;
output	reg						L1_axi_awvalid;
input							L1_axi_awready;
input 		[DATA_WIDTH-1:0]			L1_axi_rdata;
input							L1_axi_rvalid;
output	reg						L1_axi_rready;
output	reg 	[DATA_WIDTH-1:0]			L1_axi_wdata;
output	reg 	[(DATA_WIDTH>>3)-1:0]			L1_axi_wstrb;
output	reg						L1_axi_wvalid;
input							L1_axi_wready;
output	reg						L1_b_ready;
input							L1_b_valid;
input 		[1:0]					L1_b_response;






assign ddr_axi_wstrb = 4'b1111;
assign table_axi_wstrb = 2'b11;



/////////////////////////////////////////////////////////   Memories ///////////////////////////////////


reg [(2**CACHE_ADDR_SIZE)-1 : 0] oneshot;



/////////////////////////////////////////////////////////// Variables ///////////////////////////////////

// State machine counter
reg [7:0] state;

// Buffering inputs from the CPU
reg [DATA_WIDTH:0] axi_wdata_buff;
reg [(DATA_WIDTH>>3)-1:0] axi_wstrb_buff;


wire [CACHE_ADDR_SIZE-1:0] hash_key;
reg [CACHE_ADDR_SIZE-1:0] unhash_key;

wire [MEM_ADDR_SIZE-CACHE_ADDR_SIZE-1-2:0] hash_value;
reg [MEM_ADDR_SIZE-CACHE_ADDR_SIZE-1-2:0] unhash_value;

reg [MEM_ADDR_SIZE-1:0] hash_addr;
wire [MEM_ADDR_SIZE-1:0] unhash_addr;

reg [31:0] mem_data;
reg [MEM_ADDR_SIZE-CACHE_ADDR_SIZE-1-2:0] value_table;


hash #(.MEM_ADDR_SIZE(MEM_ADDR_SIZE),.CACHE_ADDR_SIZE(CACHE_ADDR_SIZE)) hash_function (.addr(hash_addr),.key(hash_key),.value(hash_value));
unhash #(.MEM_ADDR_SIZE(MEM_ADDR_SIZE),.CACHE_ADDR_SIZE(CACHE_ADDR_SIZE)) unhash_function (.addr(unhash_addr),.key(unhash_key),.value(unhash_value));

assign w_processing = state[7];
always @(posedge clk) begin
	
		
	if (rst) begin
		axi_arready <= 1'b0; axi_rvalid <= 1'b0; axi_rdata <= 32'd0;
		axi_awready <= 1'b0; axi_wready <= 1'b0; b_valid <= 1'b0; b_response <= 2'b0; 
		
		oneshot <= 0;	value_table <= 0;	mem_data <= 0;
		axi_wdata_buff<= 0; axi_wstrb_buff<= 0;
		hash_addr <= 0; unhash_key <= 0; unhash_value <= 0;
		
		
		ddr_axi_arvalid <= 1'b0; ddr_axi_araddr <= 28'd0; ddr_axi_rready <= 1'b0; 
		ddr_axi_awvalid <= 1'b0; ddr_axi_awaddr <= 28'd0; 
		ddr_axi_wdata <= 32'd0; ddr_axi_wvalid <= 1'b0; 
		ddr_b_ready <= 1'b0;
		
		table_axi_arvalid <= 1'b0; table_axi_araddr <= 28'd0; table_axi_rready <= 1'b0; 
		table_axi_awvalid <= 1'b0; table_axi_awaddr <= 28'd0; 
		table_axi_wdata <= 32'd0; table_axi_wvalid <= 1'b0; 
		table_b_ready <= 1'b0;
		
		L1_axi_arvalid <= 1'b0; L1_axi_araddr <= 28'd0; L1_axi_rready <= 1'b0; 
		L1_axi_awvalid <= 1'b0; L1_axi_awaddr <= 28'd0; 
		L1_axi_wdata <= 32'd0; L1_axi_wvalid <= 1'b0; L1_axi_wstrb <= 0;
		L1_b_ready <= 1'b0;
		
			
	end else if (state == 8'd0) begin
		 		
		axi_arready <= 1'b0; axi_rvalid <= 1'b0; axi_rdata <= 32'd0;
		axi_awready <= 1'b0; axi_wready <= 1'b0; b_valid <= 1'b0; b_response <= 2'b0; 
		
		value_table <= 0;	mem_data <= 0;
		axi_wdata_buff<= 0; axi_wstrb_buff<= 0;
		hash_addr <= 0; unhash_key <= 0; unhash_value <= 0;
		
		
		ddr_axi_arvalid <= 1'b0; ddr_axi_araddr <= 28'd0; ddr_axi_rready <= 1'b0; 
		ddr_axi_awvalid <= 1'b0; ddr_axi_awaddr <= 28'd0; 
		ddr_axi_wdata <= 32'd0; ddr_axi_wvalid <= 1'b0; 
		ddr_b_ready <= 1'b0;
		
		table_axi_arvalid <= 1'b0; table_axi_araddr <= 28'd0; table_axi_rready <= 1'b0; 
		table_axi_awvalid <= 1'b0; table_axi_awaddr <= 28'd0; 
		table_axi_wdata <= 32'd0; table_axi_wvalid <= 1'b0; 
		table_b_ready <= 1'b0;
		
		L1_axi_arvalid <= 1'b0; L1_axi_araddr <= 28'd0; L1_axi_rready <= 1'b0; 
		L1_axi_awvalid <= 1'b0; L1_axi_awaddr <= 28'd0; 
		L1_axi_wdata <= 32'd0; L1_axi_wvalid <= 1'b0; L1_axi_wstrb <= 0;
		L1_b_ready <= 1'b0;
		
			
	end else if (state == 8'd1) begin
		axi_arready <= 1'b1;
		hash_addr <= axi_araddr;
			
	end else if (state == 8'd2) begin
		axi_arready <= 0;
		L1_axi_araddr <= hash_key;
		L1_axi_arvalid <= 1'b1;
		L1_axi_rready <= 0;
		table_axi_araddr <= hash_key;
		table_axi_arvalid <= 1'b1;
		table_axi_rready <= 0;
		
	end else if (state == 8'd3) begin
		if (L1_axi_arready) 
			L1_axi_arvalid <= 1'b0;
		if (table_axi_arready) 
			table_axi_arvalid <= 1'b0;		
		if (L1_axi_rvalid && table_axi_rvalid && !L1_axi_arvalid && !table_axi_arvalid) begin
			L1_axi_rready <= 1'b1;	
			table_axi_rready <= 1'b1;	
			mem_data <= L1_axi_rdata;
			value_table <= table_axi_rdata;
		end
				
	end else if (state == 8'd4) begin		
		L1_axi_rready <= 1'b0;	
		table_axi_rready <= 1'b0;
		
	end else if (state == 8'd5) begin
		axi_rdata <= mem_data;
		axi_rvalid <= 1'b1;

	end else if (state == 8'd6) begin
		unhash_value <= value_table;
		unhash_key <= hash_key;
		
	end else if (state == 8'd7) begin
		ddr_axi_awaddr <= unhash_addr;
		ddr_axi_awvalid <= 1'b1;
		ddr_axi_wdata <= mem_data;
		ddr_axi_wvalid <= 1'b1;
		
	end else if (state == 8'd8) begin
		ddr_axi_wvalid <= 1'b0;
			
	end else if (state == 8'd9) begin
		ddr_axi_awvalid <= 1'b0;
			
	end else if (state == 8'd10) begin
		ddr_axi_wvalid <= 0;
		ddr_axi_awvalid <= 0;
		ddr_b_ready <= 1'b1;

	end else if (state == 8'd11) begin
		ddr_b_ready <= 1'b0;
		ddr_axi_araddr <= hash_addr;
		ddr_axi_arvalid <= 1'b1;
	
	end else if (state == 8'd12) begin
		ddr_axi_rready <= 1'b1;
		ddr_axi_arvalid <= 1'b0;
		
	end else if (state == 8'd13) begin
		ddr_axi_rready <= 1'b0;		
		axi_rdata 	<= ddr_axi_rdata;
		axi_rvalid   <= 1'b1;		
		L1_axi_awaddr  <= hash_key;
		L1_axi_awvalid <= 1'b1;
		L1_axi_wdata   <= ddr_axi_rdata;
		L1_axi_wvalid <= 1'b1;
		L1_b_ready     <= 1'b1;
		L1_axi_wstrb  <= {(DATA_WIDTH>>3){1'b1}};		
		table_axi_awaddr  <= hash_key;
		table_axi_awvalid <= 1'b1;
		table_axi_wdata   <= hash_value;
		table_axi_wvalid <= 1'b1; 
		table_b_ready     <= 1'b1;
	
		
		oneshot[hash_key] <= 1'b1;
		
	end else if (state == 8'd14) begin
		if (axi_rready)
			axi_rvalid <= 1'b0;
		
		if (L1_axi_awready) 
			L1_axi_awvalid <= 1'b0; 
		
		if (L1_axi_wready) 
			L1_axi_wvalid <= 1'b0; 
		
		if (L1_b_valid) 
			L1_b_ready <= 1'b0; 
		
		if (table_axi_awready) 
			table_axi_awvalid <= 1'b0; 
		
		if (table_axi_wready) 
			table_axi_wvalid <= 1'b0; 
		
		if (table_b_valid) 
			table_b_ready <= 1'b0; 
		
					
	end else if (state == 8'd128) begin
		axi_wready <= 1'b1;
		axi_awready <= 1'b1;
		if (axi_wvalid) begin
			axi_wdata_buff <= axi_wdata;
			axi_wstrb_buff <= axi_wstrb;	
		end
			
	end else if (state == 8'd129) begin
		hash_addr <= axi_awaddr;
		axi_wready <= 1'b0;
		axi_awready <= 1'b0;
		
	end else if (state == 8'd130) begin
		axi_wready <= 1'b1;
		axi_awready <= 1'b1;
		if (axi_awvalid) begin
			hash_addr <= axi_awaddr;
		end
		
	end else if (state == 8'd131) begin
		axi_wdata_buff <= axi_wdata;
		axi_wstrb_buff <= axi_wstrb;
		axi_wready <= 1'b0;
		axi_awready <= 1'b0;

	end else if (state == 8'd132) begin
		axi_wready <= 1'b1;
		axi_awready <= 1'b1;
		hash_addr <= axi_awaddr;
		axi_wdata_buff <= axi_wdata;
		axi_wstrb_buff <= axi_wstrb;
			
	end else if (state == 8'd133) begin
		axi_wready <= 1'b0;
		axi_awready <= 1'b0;
		
	end else if (state == 8'd134) begin
		L1_axi_araddr <= hash_key;
		L1_axi_arvalid <= 1'b1;
		L1_axi_rready <= 0;
		table_axi_araddr <= hash_key;
		table_axi_arvalid <= 1'b1;
		table_axi_rready <= 0;
		
	end else if (state == 8'd135) begin
		if (L1_axi_arready) 
			L1_axi_arvalid <= 1'b0;
		if (table_axi_arready) 
			table_axi_arvalid <= 1'b0;		
		if (L1_axi_rvalid && table_axi_rvalid && !L1_axi_arvalid && !table_axi_arvalid) begin
			L1_axi_rready <= 1'b1;	
			table_axi_rready <= 1'b1;	
			mem_data <= L1_axi_rdata;
			value_table <= table_axi_rdata;
		end		
		
	end else if (state == 8'd136) begin
		L1_axi_rready <= 1'b0;
		table_axi_rready <= 1'b0;
		unhash_value <= value_table;
		unhash_key <= hash_key;
	
	end else if (state == 8'd137) begin
		L1_axi_awaddr  <= hash_key;
		L1_axi_awvalid <= 1'b1;
		L1_axi_wdata   <= axi_wdata_buff;
		L1_axi_wvalid <= 1'b1;
		L1_b_ready     <= 1'b1;
		L1_axi_wstrb  <= axi_wstrb_buff;
		
		table_axi_awaddr  <= hash_key;
		table_axi_awvalid <= 1'b1;
		table_axi_wdata   <= hash_value;
		table_axi_wvalid <= 1'b1; 
		table_b_ready     <= 1'b1;
		
		oneshot[hash_key] <= 1'b1;
				
	end else if (state == 8'd138) begin	
		if (L1_axi_awready) 
			L1_axi_awvalid <= 1'b0; 
		
		if (L1_axi_wready) 
			L1_axi_wvalid <= 1'b0; 
		
		if (L1_b_valid) 
			L1_b_ready <= 1'b0; 
		
		if (table_axi_awready) 
			table_axi_awvalid <= 1'b0; 
		
		if (table_axi_wready) 
			table_axi_wvalid <= 1'b0; 
		
		if (table_b_valid) 
			table_b_ready <= 1'b0; 
		
		if ((!table_b_ready || table_b_valid) && (!L1_b_ready ||  L1_b_valid) && (b_ready))
			b_valid <= 1'b1;
		
	
	end else if (state == 8'd139) begin
		ddr_axi_wdata <= mem_data;
		ddr_axi_awaddr <= unhash_addr;
		ddr_axi_awvalid <= 1'b1;
		ddr_axi_wvalid <= 1'b1;
		
	end else if (state == 8'd140) begin
		ddr_axi_wvalid <= 1'b0;
			
	end else if (state == 8'd141) begin
		ddr_axi_awvalid <= 1'b0;
			
	end else if (state == 8'd142) begin
		ddr_b_ready <= 1'b1;
		value_table <= hash_value;
		ddr_axi_wvalid <= 1'b0;
		ddr_axi_awvalid <= 1'b0;
		
    	end
end

	
	
always @(negedge clk) begin
	if (rst ) begin
		state <= 0;

	end else if (state == 8'd0) begin
		if (axi_arvalid) 
			// cpu wants to read
			state <= 8'd1;
		else if (axi_awvalid && axi_wvalid)
			// cpu wants to write
			state <= 8'd130;
		else if (axi_awvalid) 
			// cpu wants to write but has only sent the address (no data)
			state <= 8'd129;
		else if (axi_wvalid) 
			// cpu wants to write but has only sent the data (no address)
			state <= 8'd128;
			
	end else if (state == 8'd1) begin
		// axi_arready <= 1'b1;
		// axi_araddr_buff <= axi_araddr;
		// hash_addr <= axi_araddr;
		state <= 8'd2;
			
	end else if (state == 8'd2) begin
		// read data from mem and table
		// axi_araddr <= 0;
		// L1_axi_araddr <= hash_key;
		// L1_axi_arvalid <= 1'b1;
		// L1_axi_rready <= 0;
		// table_axi_araddr <= hash_key;
		// table_axi_arvalid <= 1'b1;
		// table_axi_rready <= 0;
		state <= 8'd3;
		
	end else if (state == 8'd3) begin
		// if (L1_axi_arready) 
		//	L1_axi_arvalid <= 1'b0;
		// if (table_axi_arready) 
		//	table_axi_arvalid <= 1'b0;		
		// if (L1_axi_rvalid && table_axi_rvalid && !L1_axi_arvalid && !table_axi_arvalid) begin
		//	L1_axi_rready <= 1'b1;	
		//	table_axi_rready <= 1'b1;	
		//	mem_data <= L1_axi_rdata;
		//	value_table <= table_axi_rdata;
		// end
		if (L1_axi_rvalid && table_axi_rvalid && !L1_axi_arvalid && !table_axi_arvalid && L1_axi_rready && table_axi_rready)
			state <= 8'd4;
	
				
	end else if (state == 8'd4) begin		
		//	L1_axi_rready <= 1'b0;	
		//	table_axi_rready <= 1'b0;
		if ((hash_value == value_table) && oneshot[hash_key]) begin
			// if available in mem
			state <= 8'd5;
		end else if (oneshot[hash_key]) begin
			// else if there is existing data in mem but not for our address, prepare to writeback the data to DRAM 
			state <= 8'd6;
		end else begin
			// else, read from dram into mem
			state <= 8'd11; 
		end	
			
			
	end else if (state == 8'd5) begin
		// axi_rdata <= mem_data;
		// axi_rvalid <= 1'b1;
		if (axi_rready) begin
			state <= 8'd0;
		end
	
	end else if (state == 8'd6) begin
		// unhash_value <= value_table;
		// unhash_key <= hash_key;
		state <= 8'd7;
		
	end else if (state == 8'd7) begin
		// ddr_axi_awaddr <= unhash_addr;
		// ddr_axi_awvalid <= 1'b1;
		// ddr_axi_wdata <= mem_data;
		// ddr_axi_wvalid <= 1'b1;
		
		// if both awready and wready and 1
		if (ddr_axi_awready && ddr_axi_wready) 
			state <= 8'd10;
		// else if ddr is only ready to recieve address
		else if (ddr_axi_awready)
			state <= 8'd9;
		// else if ddr is only ready to recieve data
		else if (ddr_axi_wready)
			state <= 8'd8;
		// else do nothing and wait
		
	end else if (state == 8'd8) begin
		//ddr_axi_wvalid <= 1'b0;
		if (ddr_axi_awready)
			state <= 8'd10;
			
	end else if (state == 8'd9) begin
		//ddr_axi_awvalid <= 1'b0;
		if (ddr_axi_wready)
			state <= 8'd10;
			
	end else if (state == 8'd10) begin
		// ddr_axi_wvalid <= 0;
		// ddr_axi_awvalid <= 0;
		// ddr_b_ready <= 1'b1;
		if (ddr_b_valid)
			state <= 8'd11;
	
	end else if (state == 8'd11) begin
		// ddr_b_ready <= 1'b0;
		// ddr_axi_araddr <= axi_araddr_buff[MEM_ADDR_SIZE-1:0];
		// ddr_axi_arvalid <= 1'b1;
		if (ddr_axi_arready) 
			state <= 8'd12;
	
	end else if (state == 8'd12) begin
		// ddr_axi_rready <= 1'b1;
		// ddr_axi_arvalid <= 1'b0;
		if (ddr_axi_rvalid)
			state <= 8'd13;
			
	end else if (state == 8'd13) begin
		//ddr_axi_rready <= 1'b0;
		
		//axi_rdata 	<= ddr_axi_rdata;
		//axi_rvalid   <= 1'b1;
		
		//L1_axi_awaddr  <= hash_key;
		//L1_axi_awvalid <= 1'b1;
		//L1_axi_wdata   <= ddr_axi_rdata;
		//L1_axi_wvalid <= 1'b1;
		//L1_b_ready     <= 1'b1;
		//L1_axi_wstrb  <= {(DATA_WIDTH>>3){1}};
		
		//table_axi_awaddr  <= hash_key;
		//table_axi_awvalid <= 1'b1;
		//table_axi_wdata   <= hash_value;
		//table_axi_wvalid <= 1'b1; 
		//table_b_ready     <= 1'b1;
	
		
		//oneshot[hash_key] <= 1'b1;
		
		state <= 8'd14;
			
	end else if (state == 8'd14) begin
		// if (axi_rready)
		//	axi_rvalid <= 1'b0;
		
		// if (L1_axi_awready) 
		//	L1_axi_awvalid <= 1'b0; 
		
		// if (L1_axi_wready) 
		//	L1_axi_wvalid <= 1'b0; 
		
		// if (L1_b_valid) 
		//	L1_b_ready <= 1'b0; 
		
		// if (table_axi_awready) 
		//	table_axi_awvalid <= 1'b0; 
		
		// if (table_axi_wready) 
		//	table_axi_wvalid <= 1'b0; 
		
		// if (table_b_valid) 
		//	table_b_ready <= 1'b0; 
		
		// check if vlaue has changed, or is expected to change at the next clock edge
		if ((!table_b_ready || table_b_valid) && (!L1_b_ready ||  L1_b_valid) && (!axi_rvalid || axi_rready))	
			// done with read, return to state 0
			state <= 8'd0;
			
			
	end else if (state == 8'd128) begin
		// axi_wready <= 1'b1;
		// axi_awready <= 1'b1;
		// if (axi_wvalid) begin
		//	axi_wdata_buff <= axi_wdata;
		//	axi_wstrb_buff <= axi_wstrb;	
		// end
		if (axi_awvalid)
			state <= 8'd129;
			
	end else if (state == 8'd129) begin
		// axi_awaddr_buff <= axi_awaddr;
		// hash_addr <= axi_awaddr;
		// axi_wready <= 1'b0;
		// axi_awready <= 1'b0;
		state <= 8'd134;
			
	end else if (state == 8'd130) begin
		// axi_wready <= 1'b1;
		// axi_awready <= 1'b1;
		// if (axi_awvalid) begin
		//	axi_awaddr_buff <= axi_awaddr;
		// 	hash_addr <= axi_awaddr;
		// end
		if (axi_wvalid)
			state <= 8'd131;
			
	end else if (state == 8'd131) begin
		// axi_wdata_buff <= axi_wdata;
		// axi_wstrb_buff <= axi_wstrb;
		// axi_wready <= 1'b0;
		// axi_awready <= 1'b0;
		state <= 8'd134;
		
	end else if (state == 8'd132) begin
		// axi_wready <= 1'b1;
		// axi_awready <= 1'b1;
		// axi_awaddr_buff <= axi_awaddr;
		// hash_addr <= axi_awaddr;
		// axi_wdata_buff <= axi_wdata;
		// axi_wstrb_buff <= axi_wstrb;
		state <= 8'd133;
			
	end else if (state == 8'd133) begin
		// axi_wready <= 1'b0;
		// axi_awready <= 1'b0;
		state <= 8'd134;
		
	end else if (state == 8'd134) begin
		// read data from mem and table
		// axi_araddr <= 0;
		// L1_axi_araddr <= hash_key;
		// L1_axi_arvalid <= 1'b1;
		// L1_axi_rready <= 0;
		// table_axi_araddr <= hash_key;
		// table_axi_arvalid <= 1'b1;
		// table_axi_rready <= 0;
		state <= 8'd135;
		
	end else if (state == 8'd135) begin
		// if (L1_axi_arready) 
		//	L1_axi_arvalid <= 1'b0;
		// if (table_axi_arready) 
		//	table_axi_arvalid <= 1'b0;		
		// if (L1_axi_rvalid && table_axi_rvalid && !L1_axi_arvalid && !table_axi_arvalid) begin
		//	L1_axi_rready <= 1'b1;	
		//	table_axi_rready <= 1'b1;	
		//	mem_data <= L1_axi_rdata;
		//	value_table <= table_axi_rdata;
		// end
		if (L1_axi_rvalid && table_axi_rvalid && !L1_axi_arvalid && !table_axi_arvalid && L1_axi_rready && table_axi_rready)
			state <= 8'd136;		
		
	end else if (state == 8'd136) begin
		// L1_axi_rready <= 1'b0;
		// table_axi_rready <= 1'b0;
		// unhash_value <= value_table;
		// unhash_key <= hash_key;
		if (!((hash_value != value_table) && oneshot[hash_key]))
			state <= 8'd137;
		else
			state <= 8'd139;
	
	end else if (state == 8'd137) begin
	
		//L1_axi_awaddr  <= hash_key;
		//L1_axi_awvalid <= 1'b1;
		//L1_axi_wdata   <= ddr_axi_rdata;
		//L1_axi_wvalid <= 1'b1;
		//L1_b_ready     <= 1'b1;
		//L1_axi_wstrb  <= axi_wstrb_buff;
		
		//table_axi_awaddr  <= hash_key;
		//table_axi_awvalid <= 1'b1;
		//table_axi_wdata   <= hash_value;
		//table_axi_wvalid <= 1'b1; 
		//table_b_ready     <= 1'b1;
		
		//oneshot[hash_key] <= 1'b1;
			state <= 8'd138;
				
	end else if (state == 8'd138) begin	
		// if (L1_axi_awready) 
		//	L1_axi_awvalid <= 1'b0; 
		
		// if (L1_axi_wready) 
		//	L1_axi_wvalid <= 1'b0; 
		
		// if (L1_b_valid) 
		//	L1_b_ready <= 1'b0; 
		
		// if (table_axi_awready) 
		//	table_axi_awvalid <= 1'b0; 
		
		// if (table_axi_wready) 
		//	table_axi_wvalid <= 1'b0; 
		
		// if (table_b_valid) 
		//	table_b_ready <= 1'b0; 
		
		// if ((!table_b_ready || table_b_valid) && (!L1_b_ready ||  L1_b_valid) && (axi_b_ready))
		//	axi_b_valid <= 1'b1;
		
		// check if vlaue has changed, or is expected to change at the next clock edge
		if ((!table_b_ready || table_b_valid) && (!L1_b_ready ||  L1_b_valid) && (b_valid))	
			state <= 8'd0;
	
	end else if (state == 8'd139) begin
		// ddr_axi_wdata <= mem_data;
		// ddr_axi_awaddr <= unhash_addr;
		// ddr_axi_awvalid <= 1'b1;
		// ddr_axi_wvalid <= 1'b1;
		// if both awready and wready and 1
		if (ddr_axi_awready && ddr_axi_wready) 
			state <= 8'd142;
		// else if ddr is only ready to recieve address
		else if (ddr_axi_awready)
			state <= 8'd141;
		// else if ddr is only ready to recieve data
		else if (ddr_axi_wready)
			state <= 8'd140;
		// else do nothing and wait
		
	end else if (state == 8'd140) begin
		// ddr_axi_wvalid <= 1'b0;
		if (ddr_axi_awready)
			state <= 8'd142;
			
	end else if (state == 8'd141) begin
		// ddr_axi_awvalid <= 1'b0;
		if (ddr_axi_wready)
			state <= 8'd142;
			
	end else if (state == 8'd142) begin
		// ddr_b_ready <= 1'b1;
		// value_table <= hash_value;
		// ddr_axi_wvalid <= 1'b0;
		// ddr_axi_awvalid <= 1'b0;
		if (ddr_b_valid) 
			state <= 8'd136;
    end
end
			
			
			
		

endmodule




module hash(
	addr,
	key,
	value
);

parameter MEM_ADDR_SIZE = 28;
parameter CACHE_ADDR_SIZE = 10;

input [MEM_ADDR_SIZE-1:0] addr;		// byte address in 
output [CACHE_ADDR_SIZE-1:0] key;
output [MEM_ADDR_SIZE-CACHE_ADDR_SIZE-3:0] value;

assign key = addr[CACHE_ADDR_SIZE+1:2];
assign value = addr[MEM_ADDR_SIZE-1:CACHE_ADDR_SIZE+2];

endmodule

module unhash(
	addr,
	key,
	value
);

parameter MEM_ADDR_SIZE = 28;
parameter CACHE_ADDR_SIZE = 10;

output [MEM_ADDR_SIZE-1:0] addr;
input [CACHE_ADDR_SIZE-1:0] key;
input [MEM_ADDR_SIZE-CACHE_ADDR_SIZE-3:0] value;

assign addr = {value, key, 2'b00};

endmodule
