`timescale 10 ns / 10 ns

module DE0_Nano_tb;

parameter AD9226_MSB = 11;

integer AD9226_0 = $fopen("AD9226_0.txt", "r");
integer AD9226_1 = $fopen("AD9226_1.txt", "r");
integer scan_0;
integer scan_1;
reg [AD9226_MSB:0] AD9226_0_BITS = 0;
reg [AD9226_MSB:0] AD9226_1_BITS = 0;
reg CLOCK_50 = 0;
wire [19:0] GPIO_0;
wire [19:0] GPIO_1;

initial 
   forever #1 CLOCK_50 = ~CLOCK_50;

always @(posedge GPIO_0[7])
   scan_0 = $fscanf(AD9226_0, "%d\n", AD9226_0_BITS);

always @(posedge GPIO_1[7])
   scan_1 = $fscanf(AD9226_1, "%d\n", AD9226_1_BITS);

assign GPIO_0[6:0] = 0;
assign GPIO_1[2:0] = 0;
assign GPIO_1[6:4] = 0;
assign GPIO_0[19:8] = AD9226_0_BITS;
assign GPIO_1[19:8] = {AD9226_1_BITS[0], AD9226_1_BITS[1], AD9226_1_BITS[2], AD9226_1_BITS[3],
							AD9226_1_BITS[4], AD9226_1_BITS[5], AD9226_1_BITS[6], AD9226_1_BITS[7], 
							AD9226_1_BITS[8], AD9226_1_BITS[9], AD9226_1_BITS[10], AD9226_1_BITS[11]};

DE0_Nano DE0_Nano_inst(
	CLOCK_50,
	GPIO_0,
	GPIO_1
);

endmodule
