module Filter (
	clk,
	ADC_bits,
	Filter_bits
);

parameter ADC_MSB = 11;
parameter Filter_MSB = 15;
parameter Order = 39;
parameter Order_MSB = 5;

input clk;
input signed [ADC_MSB:0] ADC_bits;
output signed [ADC_MSB:0] Filter_bits;

reg [Order_MSB:0] address_r = 0;
wire [Order_MSB:0] address;
wire signed [ADC_MSB:0] buffer_bits;
wire signed [ADC_MSB:0] current_bits;
wire signed [Filter_MSB:0] coef_bits;

always @(posedge clk)
	if (address_r < Order)
		address_r <= address_r + 1'b1;
	else 
		address_r <= 0;

assign address = address_r;
assign current_bits = address ? buffer_bits
										: ADC_bits;

buffer #(
	Order_MSB,
	ADC_MSB, 
	Order
) buffer_inst (
	clk,
	address,
	current_bits,
	buffer_bits
);

coef #(
	Order_MSB,
	Filter_MSB,
	Order
) coef_inst (
	clk,
	address,
	coef_bits
);

mult #(
	Order_MSB,
	Filter_MSB,
	ADC_MSB
) mult_inst (
	clk,
	address,
	coef_bits,
	buffer_bits,
	Filter_bits
);
					 
endmodule
