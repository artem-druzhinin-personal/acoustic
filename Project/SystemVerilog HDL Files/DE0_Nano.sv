
//=======================================================
//  This code is written by developer Artem Druzhinin
//=======================================================

module DE0_Nano(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,
	
	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	GPIO_0
);

//=======================================================
//  PARAMETER declarations
//=======================================================

parameter AD9226_LQFP_MSB = 11;

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;

//////////// LED //////////
output		     [6:0]		LED;

//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
inout 		    [19:0]		GPIO_0;


//=======================================================
//  REG/WIRE declarations
//=======================================================


reg [AD9226_LQFP_MSB:0] AD9226_LQFP_BITS;
wire AD9226_LQFP_CLK;


//=======================================================
//  Structural coding
//=======================================================

PLL PLL_inst(
	.inclk0(CLOCK_50),
	.c0(AD9226_LQFP_CLK)
);

assign GPIO_0[7] = AD9226_LQFP_CLK;

always @(posedge AD9226_LQFP_CLK) begin
	AD9226_LQFP_BITS = GPIO_0[19:8];
end

assign LED[6:0] = AD9226_LQFP_BITS[11:6] 
					 + AD9226_LQFP_BITS[5:0];

					 
endmodule
