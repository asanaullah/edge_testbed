`timescale 1ps/1ps
//`define SIMULATION
module progloader_axi(
clk,rst,urx,reprogram,w_processing,busy,

axi_awaddr,axi_awvalid,axi_awready,
axi_wdata,axi_wstrb,axi_wvalid,axi_wready,
b_ready,b_valid,b_response
);


parameter MEM_ADDR_SIZE = 32;
parameter DATA_WIDTH = 32;





input 				clk;
input 				rst;
input 				urx;
input 				reprogram;
input				w_processing;

output				busy;





output	reg 	[MEM_ADDR_SIZE-1:0]			axi_awaddr;
output	reg						axi_awvalid;
input							axi_awready;
output	reg 	[DATA_WIDTH-1:0]			axi_wdata;
output   	[(DATA_WIDTH>>3)-1:0]			axi_wstrb;
output	reg						axi_wvalid;
input							axi_wready;
output	reg						b_ready;
input							b_valid;
input 		[1:0]					b_response;



assign axi_wstrb = {(DATA_WIDTH>>3){1'b1}};
assign busy = (state > 0) ? 1'b1 : 1'b0;


reg [7:0] state;
wire rx_dv;
wire [7:0] rx_byte;
reg [7:0] rx_byte_buff;
reg [DATA_WIDTH-1:0] mem_data;


always @(posedge clk) begin
	if (rst) begin
		axi_wvalid <= 0;
		axi_awvalid <= 0;
		b_ready <= 0;
	
	end else if ((state == 0) && reprogram && w_processing) begin
		b_ready <= 1'b1;
		axi_wvalid <= axi_wready ? 1'b1 : 0;
		axi_awvalid <= axi_awready ? 1'b1 : 0;
		
	end else if (state == 0) begin
		axi_wvalid <= 0;
		axi_awvalid <= 0;
		b_ready <= 0;
		
	end else if (state == 8'd1) begin
		mem_data  <= {24'd0,rx_byte_buff};
		
	end else if (state == 8'd2) begin
		mem_data <= mem_data | {16'h0,rx_byte_buff, 8'd0};
		
	end else if (state == 8'd3) begin
		mem_data <= mem_data | {8'd0,rx_byte_buff, 16'd0};
		
	end else if (state == 8'd4) begin
		axi_awaddr <= mem_data | {rx_byte_buff,24'd0};
		
	end else if (state == 8'd5) begin
		mem_data  <= {24'd0,rx_byte_buff};
		
	end else if (state == 8'd6) begin
		mem_data <= mem_data | {16'h0,rx_byte_buff, 8'd0};
		
	end else if (state == 8'd7) begin
		mem_data <= mem_data | {8'd0,rx_byte_buff, 16'd0};
		
	end else if (state == 8'd8) begin
		axi_wdata <= mem_data | {rx_byte_buff,24'd0};
        axi_wvalid <= 1'b1;
        axi_awvalid <= 1'b1;
		
	end else if (state == 8'd9) begin
		axi_wvalid <= 1'b0;
		
	end else if (state == 8'd10) begin
		axi_awvalid <= 1'b0;
		
	end else if (state == 8'd11) begin
		axi_wvalid <= 1'b0;
		axi_awvalid <= 1'b0;
		b_ready <= 1'b1;
	end
end


always @(negedge clk) begin
		
	if (rst) begin
		state <= 0;	
		
	end else if ((state == 0) && w_processing) begin
		
	
	end else if (reprogram) begin
	
		if (rx_dv) begin
			state <= state + 8'd1; 
			rx_byte_buff <= rx_byte;
			
		end else if (state == 8'd8) begin	
			if (axi_wready && axi_awready)
				state <= 8'd11;
			else if (axi_wready)
				state <= 8'd9;
			else if (axi_awready)
				state <= 8'd10;
				
		end else if (state == 8'd9) begin
			if (axi_awready)
				state <= 8'd11;
				
		end else if (state == 8'd10) begin
			if (axi_wready)
				state <= 8'd11;
				
		end else if (state == 8'd11) begin
			if (b_valid)
				state <= 8'd0;
		end
	end
end
	
	
			


`ifdef SIMULATION
        reg [7:0] uart_state;
        reg rx_dv_reg;
        initial rx_dv_reg = 0;
        assign rx_dv = rx_dv_reg;
        reg [31:0] pc;
        initial pc = 0;
        reg [7:0] rx_byte_reg;
        reg [7:0] instrs [0: 1048575];
        
        initial $readmemh("firmware.hex", instrs);
        assign rx_byte = rx_byte_reg; 
	always @(posedge clk) begin
		if (rst || !reprogram) begin
			uart_state <= 0;
			pc <= 0;
		end else if (rx_dv_reg) begin
			rx_dv_reg <= 0;
		end else if (uart_state == 0) begin
			if (state == 0)
				uart_state <= uart_state + 8'd1;
		end else if (uart_state == 8'd1) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[7:0];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd2) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[15:8];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd3) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[23:16];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd4) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= pc[31:24];
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd5) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd6) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd7) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= uart_state + 8'd1;
			
		end else if (uart_state == 8'd8) begin
			rx_dv_reg <= 1'b1;
			rx_byte_reg <= instrs[pc];
			pc <= pc+ 32'd1;
			uart_state <= 8'd0;
		end
	end
     
        
`else
        uart_rx_bram  #(.CLKS_PER_BIT(8'd83)) rx(. i_Clock(clk),.i_Rx_Serial(urx),.o_Rx_DV(rx_dv),.o_Rx_Byte(rx_byte));

`endif			
		

endmodule


//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_rx_bram 
  (
   input        i_Clock,
   input        i_Rx_Serial,
   output       o_Rx_DV,
   output [7:0] o_Rx_Byte
   );
  parameter CLKS_PER_BIT   = 8'd83;
  parameter s_IDLE         = 3'b000;
  parameter s_RX_START_BIT = 3'b001;
  parameter s_RX_DATA_BITS = 3'b010;
  parameter s_RX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
   
  reg           r_Rx_Data_R = 1'b1;
  reg           r_Rx_Data   = 1'b1;
   
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total
  reg [7:0]     r_Rx_Byte     = 0;
  reg           r_Rx_DV       = 0;
  reg [2:0]     r_SM_Main     = 0;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock)
    begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
   
   
  // Purpose: Control RX state machine
  always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)          // Start bit detected
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
        // Check middle of start bit to make sure it's still low
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule // uart_rx
