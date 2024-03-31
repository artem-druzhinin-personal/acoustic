module mult (
   clk,
	address,
	coef_bits,
	buffer_bits,
	Filter_bits
);

parameter Order_MSB = 5;
parameter Filter_MSB = 15;
parameter ADC_MSB = 11;
parameter mult_MSB = Filter_MSB + ADC_MSB + 1;

input clk;
input [Order_MSB:0] address;
input signed [Filter_MSB:0] coef_bits;
input signed [ADC_MSB:0] buffer_bits;
output signed [ADC_MSB:0] Filter_bits;

reg signed [mult_MSB:0] mult = 0;
reg signed [mult_MSB:0] sum = 0;
reg signed [ADC_MSB:0] shift = 0;

always @(posedge clk) begin
	mult <= coef_bits * buffer_bits;
	if (address) 
		sum <= sum + mult;
	else begin
		sum <= mult;
		shift <= sum[mult_MSB - 1-:ADC_MSB + 1];
	end
end

assign Filter_bits = shift;

endmodule
