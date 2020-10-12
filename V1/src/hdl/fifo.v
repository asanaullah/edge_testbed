module fifo (
clk,
rst,
data_in,
data_in_valid,
data_out,
data_out_ready,
data_out_valid);

parameter DATA_WIDTH = 8;
parameter BUFFER_LOG_SIZE = 5;
parameter BUFFER_SIZE = 2**BUFFER_LOG_SIZE;

input 				clk;
input 				rst;
input [DATA_WIDTH-1:0] 		data_in;
input 				data_in_valid;
input 				data_out_ready;
output 	reg			data_out_valid;
output reg [DATA_WIDTH-1:0]	data_out;


reg [DATA_WIDTH-1:0] ring_buffer [0:BUFFER_SIZE-1];
reg [BUFFER_LOG_SIZE-1:0] w_pointer;
reg [BUFFER_LOG_SIZE-1:0]  r_pointer;



always @(negedge clk) begin
	if (rst) begin
		w_pointer <= 0;
	end else if (data_in_valid) begin
		ring_buffer[w_pointer] <= data_in;
		w_pointer <= w_pointer + {{BUFFER_LOG_SIZE-1{1'b0}},1'b1};
	end
end


always @(negedge clk) begin
	if (rst) 
		data_out <= 0;
	else
		data_out <= ring_buffer[r_pointer];
end

always @(posedge clk) begin
	if (rst) begin
		r_pointer <= 0;
		data_out_valid <= 0;
	end else if (data_out_ready && data_out_valid) begin
		r_pointer <= r_pointer +  {{BUFFER_LOG_SIZE-1{1'b0}},1'b1};
		data_out_valid <= (r_pointer +  {{BUFFER_LOG_SIZE-1{1'b0}},1'b1} == w_pointer) ?  1'b0 : 1'b1;
	end else
		data_out_valid <= (w_pointer == r_pointer) ? 1'b0 : 1'b1;
	
end

endmodule
