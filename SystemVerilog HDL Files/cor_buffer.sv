module cor_buffer (
   clk,
   write,
   wr_address,
	rd_address,
   cur_val,
	buffer_val
);

parameter buf_size = 500;
parameter buf_size_MSB = 8;
parameter ADC_MSB = 11;

input clk;
input write;
input [buf_size_MSB:0] wr_address;
input [buf_size_MSB:0] rd_address;
input [ADC_MSB:0] cur_val;
output [ADC_MSB:0] buffer_val;
	
reg [ADC_MSB:0] buffer[buf_size - 1:0];
reg [ADC_MSB:0] prev_val = 0;

assign buffer_val = prev_val;

always @(posedge clk) begin
   if (write)
		buffer[wr_address] <= cur_val;
	prev_val <= buffer[rd_address];
end

endmodule 
