module buffer (
   clk,
	address,
	current_bits,
	buffer_bits
);

parameter Order_MSB = 5; 
parameter ADC_MSB = 11;
parameter Order = 39;

input clk;
input [Order_MSB:0] address;
input signed [ADC_MSB:0] current_bits;
output signed [ADC_MSB:0] buffer_bits;

reg signed [ADC_MSB:0] buffer[Order:0];

logic [Order_MSB:0] i;
initial
	for (i = 0; i < Order + 1; i = i + 1'b1)
		buffer[i] = 0;
		
reg signed [ADC_MSB:0] prev_bits = 0;

assign buffer_bits = prev_bits;

always @(posedge clk) begin
	prev_bits <= buffer[address];
	buffer[address] <= current_bits;			
end
		
endmodule 
