`timescale 1ps/1ps
module crossbar_axi(
			clk,
			rst,
			
			rv_axi_araddr,
			rv_axi_arvalid,
			rv_axi_arprot,
			rv_axi_arready,
			rv_axi_awaddr,
			rv_axi_awvalid,
			rv_axi_awprot,
			rv_axi_awready,
			rv_axi_rdata,
			rv_axi_rvalid,
			rv_axi_rready,
			rv_axi_wdata,
			rv_axi_wstrb,
			rv_axi_wvalid,
			rv_axi_wready,
			rv_b_ready,
			rv_b_valid,
			rv_b_response,
			address_ranges,
			axi_araddr,
			axi_arvalid,
			axi_arready,
			axi_awaddr,
			axi_awvalid,
			axi_awready,
			axi_rdata,
			axi_rvalid,
			axi_rready,
			axi_wdata,
			axi_wstrb,
			axi_wvalid,
			axi_wready,
			b_ready,
			b_valid,
			b_response);
											
			parameter ENDPOINTS = 2;
			parameter BUSWIDTH = 32;
			
			
			
			input 	clk;
			input	rst;
			
			input 	[31:0]			rv_axi_araddr;
			input				rv_axi_arvalid;
			input	[2:0]			rv_axi_arprot;
			output				rv_axi_arready;
			input 	[31:0]			rv_axi_awaddr;
			input				rv_axi_awvalid;
			input 	[2:0]			rv_axi_awprot;
			output				rv_axi_awready;
			output	[BUSWIDTH-1:0]		rv_axi_rdata;
			output				rv_axi_rvalid;
			input				rv_axi_rready;
			input 	[BUSWIDTH-1:0]		rv_axi_wdata;
			input 	[3:0]			rv_axi_wstrb;
			input				rv_axi_wvalid;
			output				rv_axi_wready;
			input				rv_b_ready;
			output				rv_b_valid;
			output	[1:0]			rv_b_response;								

			
			
			output  reg	[(32*ENDPOINTS)-1:0]			axi_araddr;
			output 	[ENDPOINTS-1:0]			axi_arvalid;
			input 		[ENDPOINTS-1:0]			axi_arready;
			output	reg 	[(32*ENDPOINTS)-1:0]			axi_awaddr;
			output 	[ENDPOINTS-1:0]			axi_awvalid;
			input 		[ENDPOINTS-1:0]			axi_awready;
			input   	[(BUSWIDTH*ENDPOINTS)-1:0]  		axi_rdata;
			input 		[ENDPOINTS-1:0]			axi_rvalid;
			output 	[ENDPOINTS-1:0]			axi_rready;
			output		[(BUSWIDTH*ENDPOINTS)-1:0]  		axi_wdata;
			output		[(4*ENDPOINTS)-1:0]  			axi_wstrb;
			output 	[ENDPOINTS-1:0]			axi_wvalid;
			input 		[ENDPOINTS-1:0]			axi_wready;
			output 	[ENDPOINTS-1:0]			b_ready;
			input 		[ENDPOINTS-1:0]			b_valid;
			input 		[(2*ENDPOINTS)-1:0]			b_response;
    			input 		[(64*ENDPOINTS)-1:0]			address_ranges;
	
		

		
		//  Determine selection index - we will use a one hot encoder here which will be '1' for the selected end point and '0' for all others
		reg [ENDPOINTS-1:0] read_onehot;
		reg [ENDPOINTS-1:0] write_onehot;
		integer i;
		always @(*) begin
			for (i = 0; i < ENDPOINTS; i=i+1) begin
				if ((rv_axi_araddr >= address_ranges[i*64 +:32]) && (rv_axi_araddr <= address_ranges[i*64 + 32 +:32])) 
					read_onehot[i] = 1'b1;
				else	
					read_onehot[i] = 1'b0;
					
				if ((rv_axi_awaddr >= address_ranges[i*64 +:32]) && (rv_axi_awaddr <= address_ranges[i*64 + 32 +:32])) 
					write_onehot[i] = 1'b1;
				else	
					write_onehot[i] = 1'b0;
			end
		end
		
		
		// Subtracting the base addresses
	    	wire  	[(32*ENDPOINTS)-1:0]	rv_axi_araddr_sub;
		wire  	[(32*ENDPOINTS)-1:0]	rv_axi_awaddr_sub;
		
		always @(*) begin
			for (i = 0; i < ENDPOINTS; i=i+1) begin
				axi_araddr[i*32 +:32] 	=   	rv_axi_araddr_sub[i*32 +: 32]	- address_ranges[i*64 +: 32];
				axi_awaddr[i*32 +:32] 	=    	rv_axi_awaddr_sub[i*32 +: 32]  - address_ranges[i*64 +: 32]; 
			end
		end
		
		
		// Now lets connect the signals 
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(32)) 	araddr  	(.onehot(read_onehot),.datain(rv_axi_araddr),.dataout(rv_axi_araddr_sub));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(1))  	arvalid  	(.onehot(read_onehot), .datain(rv_axi_arvalid), .dataout(axi_arvalid));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(1))  	rready  	(.onehot(read_onehot), .datain(rv_axi_rready), .dataout(axi_rready));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(32)) 	awaddr 	(.onehot(write_onehot), .datain(rv_axi_awaddr), .dataout(rv_axi_awaddr_sub));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(1))  	awvalid 	(.onehot(write_onehot), .datain(rv_axi_awvalid), .dataout(axi_awvalid));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(BUSWIDTH)) 	wdata    	(.onehot(write_onehot), .datain(rv_axi_wdata), .dataout(axi_wdata));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(4)) 		wstrb 		(.onehot(write_onehot), .datain(rv_axi_wstrb), .dataout(axi_wstrb));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		wvalid  	(.onehot(write_onehot), .datain(rv_axi_wvalid), .dataout(axi_wvalid));
		crossbar_decoder #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		axi_b_ready 	(.onehot(write_onehot), .datain(rv_b_ready), .dataout(b_ready));
		
		
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		arready	(.onehot(read_onehot), .datain(axi_arready), .dataout(rv_axi_arready));
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(BUSWIDTH)) 	rdata 		(.onehot(read_onehot), .datain(axi_rdata), .dataout(rv_axi_rdata));
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		rvalid 	(.onehot(read_onehot), .datain(axi_rvalid), .dataout(rv_axi_rvalid));
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		awready  	(.onehot(write_onehot), .datain(axi_awready), .dataout(rv_axi_awready));
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		wready 	(.onehot(write_onehot), .datain(axi_wready), .dataout(rv_axi_wready));
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(1)) 		axi_b_valid    (.onehot(write_onehot), .datain(b_valid), .dataout(rv_b_valid));
		crossbar_mux #(.ENDPOINTS(ENDPOINTS), .SIZE(2)) 		axi_b_response (.onehot(write_onehot), .datain(b_response), .dataout(rv_b_response));

endmodule

module crossbar_decoder(onehot, datain, dataout);

	parameter ENDPOINTS = 2;
	parameter SIZE = 1;
    integer i;
	
	input [ENDPOINTS-1:0] onehot;
	input  [SIZE-1:0] datain;
	output reg [(SIZE*ENDPOINTS)-1:0] dataout;
	
	always @(*) begin
        dataout[SIZE-1:0] = (onehot>>1) ? 0 : (onehot[0] ? datain : 0);
		for (i=1; i < ENDPOINTS; i=i+1) begin 
			dataout[i*SIZE +: SIZE] =   onehot[i] ? datain : 0;
		end
	end

endmodule


module crossbar_mux(onehot, datain, dataout);
	parameter ENDPOINTS = 2;
	parameter SIZE = 1;
	
	
	input [ENDPOINTS-1:0] onehot;
	input  [(SIZE*ENDPOINTS)-1:0] datain;
	output reg [SIZE-1:0] dataout;

	integer i;
	
	always @(*) begin
	       dataout = (onehot >> 1) ? 0 : datain[0+:SIZE];
		for (i = 1; i < ENDPOINTS; i=i+1) begin
		    if (onehot[i]) begin
		          dataout = datain[i*SIZE +: SIZE];
	           end
		end
	end

endmodule
