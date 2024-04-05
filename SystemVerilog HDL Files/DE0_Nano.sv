
//=======================================================
//  This code is written by developer Artem Druzhinin
//=======================================================

module DE0_Nano (

	//////////// CLOCK //////////
	CLOCK_50,
	
	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	GPIO_0,
	
	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	GPIO_1
);

//=======================================================
//  PARAMETER declarations
//=======================================================

parameter AD9226_MSB = 11;
parameter Fs = 1_250_000;
parameter Fs_offset = Fs / 42;
parameter Fs_fact = Fs + Fs_offset;
parameter Fs_MSB = 20;
parameter offset_MSB = 4;
parameter cor_buf_size = 64;
parameter cor_buf_size_MSB = 10;

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;

//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
inout 		    [19:0]		GPIO_0;

//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
inout 		    [19:0]		GPIO_1;


//=======================================================
//  REG/WIRE declarations
//=======================================================


wire AD9226_CLK;
wire UART_clk;
reg signed [AD9226_MSB:0] AD9226_0_BITS_r = 0;
reg signed [AD9226_MSB:0] AD9226_1_BITS_r = 0;
wire signed [AD9226_MSB:0] AD9226_0_BITS;
wire signed [AD9226_MSB:0] AD9226_1_BITS;
wire signed [AD9226_MSB:0] Filter_0_bits;
wire signed [AD9226_MSB:0] Filter_1_bits;
reg [Fs_MSB:0] clk_counter = 0;
reg signed [AD9226_MSB:0] Filter_bits_max = 0;
reg [Fs_MSB:0] max_clk = 0;
reg [Fs_MSB:0] max_clk_r = 2048;
wire signed [offset_MSB:0] offset_01;
reg start_cor_r = 0;
reg start_UART_Tx = 0;
wire ready_offset;
wire cor_buf_full;
wire cor_buf_write;
wire start_cor;
wire [cor_buf_size_MSB:0] cor_buf_wr_address;
wire [cor_buf_size_MSB:0] rd_address;
wire [cor_buf_size_MSB:0] rd_address_0;
wire signed [AD9226_MSB:0] buffer_val_0;
wire signed [AD9226_MSB:0] buffer_val_1;
reg [3:0] UART_Tx_bit = 8;
reg UART_Tx = 1;
reg signed [7:0] UART_Tx_bits = 0;
reg start_w = 0;

//=======================================================
//  Structural coding
//=======================================================

PLL PLL_inst (
	CLOCK_50,
	AD9226_CLK,
	UART_clk
);

assign GPIO_0[7] = AD9226_CLK;
assign GPIO_1[7] = AD9226_CLK;

always @(posedge AD9226_CLK) begin
	AD9226_0_BITS_r <= GPIO_0[19:8];
	AD9226_1_BITS_r <= {GPIO_1[8], GPIO_1[9], GPIO_1[10], GPIO_1[11],
							GPIO_1[12], GPIO_1[13], GPIO_1[14], GPIO_1[15], 
							GPIO_1[16], GPIO_1[17], GPIO_1[18], GPIO_1[19]};	
end

assign AD9226_0_BITS = AD9226_0_BITS_r;
assign AD9226_1_BITS = AD9226_1_BITS_r;

Filter #(
	AD9226_MSB
) Filter_0_inst (
	CLOCK_50,
	AD9226_0_BITS,
	Filter_0_bits
);

Filter #(
	AD9226_MSB
) Filter_1_inst (
	CLOCK_50,
	AD9226_1_BITS,
	Filter_1_bits	
);

always @(posedge AD9226_CLK)
	if (clk_counter <  Fs_fact) begin
		clk_counter <= clk_counter + 1'b1;
		if (Filter_1_bits > Filter_bits_max) begin
			Filter_bits_max <= Filter_1_bits;
			max_clk <= clk_counter;
		end
	end else begin
		clk_counter <= 0;
		Filter_bits_max <= 0;
		max_clk_r <= max_clk;
	end

reg [Fs_MSB - 1:0] delay = 0;

always @(posedge AD9226_CLK)
	if (!start_cor_r) begin
		if (delay < Fs / 2) 
			delay <= delay + 1;
		else 
			if (Filter_1_bits > 5) begin
				start_cor_r <= 1;
				delay <= 0;
			end
	end else 
		if (ready_offset)
			start_cor_r <= 0;

assign start_cor = start_cor_r;

cor_shift #(
	cor_buf_size,
	cor_buf_size_MSB
) shift_inst (
	AD9226_CLK,
	start_cor,
   cor_buf_write,
   cor_buf_wr_address,
	cor_buf_full
);

cor_buffer #(
	cor_buf_size,
	cor_buf_size_MSB,
	AD9226_MSB
) buffer_0 (
	AD9226_CLK,
	cor_buf_write,
	cor_buf_wr_address,
	rd_address_0,
	Filter_0_bits,
	buffer_val_0
);

cor_buffer #(
	cor_buf_size,
	cor_buf_size_MSB,
	AD9226_MSB
) buffer_1 (
	AD9226_CLK,
	cor_buf_write,
	cor_buf_wr_address,
	rd_address,
	Filter_1_bits,
	buffer_val_1
);

cor #(
	cor_buf_size,
	cor_buf_size_MSB,
	AD9226_MSB,
	offset_MSB
) cor_inst (
	AD9226_CLK,
	cor_buf_full,
	buffer_val_0,
	buffer_val_1,
	rd_address,
	rd_address_0,
	offset_01,
	ready_offset
);

always @(posedge AD9226_CLK) 
	if (ready_offset)
		start_w <= 1;
	else if (!UART_Tx_bit)
		start_w <= 0;
	
always @(posedge UART_clk) begin
	start_UART_Tx <= start_w;
   if (start_UART_Tx && (UART_Tx_bit == 8)) begin
      UART_Tx_bit <= 0;
      UART_Tx <= 0;
		UART_Tx_bits <= offset_01;
   end else begin
		if (UART_Tx_bit < 8) begin
			UART_Tx <= UART_Tx_bits[UART_Tx_bit];
			UART_Tx_bit <= UART_Tx_bit + 1'b1;
		end else 
			UART_Tx <= 1;
	end
end

assign GPIO_1[3] = UART_Tx;
					 
endmodule
