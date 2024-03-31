module coef (
    clk,
	 address,
	 coef_bits
);

parameter Order_MSB = 5;
parameter Filter_MSB = 15;
parameter Order = 39;

input clk;
input [Order_MSB:0] address;
output signed [Filter_MSB:0] coef_bits;

reg signed [Filter_MSB:0] Numerator[Order:0];

initial begin
	Numerator[0] =	-16'd360;
	Numerator[1] =	-16'd383;
	Numerator[2] =	-16'd550;
	Numerator[3] =	-16'd730;
	Numerator[4] =	-16'd906;
	Numerator[5] =	-16'd1061;
	Numerator[6] =	-16'd1173;
	Numerator[7] =	-16'd1222;
	Numerator[8] =	-16'd1193;
	Numerator[9] =	-16'd1073;
	Numerator[10] = -16'd858;
	Numerator[11] = -16'd552;
	Numerator[12] = -16'd168;
	Numerator[13] = 16'd272;
	Numerator[14] = 16'd741;
	Numerator[15] = 16'd1206;
	Numerator[16] = 16'd1631;
	Numerator[17] = 16'd1984;
	Numerator[18] = 16'd2237;
	Numerator[19] = 16'd2369;
	Numerator[20] = 16'd2369;
	Numerator[21] = 16'd2237;
	Numerator[22] = 16'd1984;
	Numerator[23] = 16'd1631;
	Numerator[24] = 16'd1206;
	Numerator[25] = 16'd741;
	Numerator[26] = 16'd272;
	Numerator[27] = -16'd168;
	Numerator[28] = -16'd552;
	Numerator[29] = -16'd858;
	Numerator[30] = -16'd1073;
	Numerator[31] = -16'd1193;
	Numerator[32] = -16'd1222;
	Numerator[33] = -16'd1173;
	Numerator[34] = -16'd1061;
	Numerator[35] = -16'd906;
	Numerator[36] = -16'd730;
	Numerator[37] = -16'd550;
	Numerator[38] = -16'd383;
	Numerator[39] = -16'd360;
end
		
reg signed [Filter_MSB:0] data_out = 0;

always @ (posedge clk)
    data_out <= Numerator[address];
	 
assign coef_bits = data_out;

endmodule
