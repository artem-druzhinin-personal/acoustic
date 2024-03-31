module cor_shift (
   clk,
   start_cor,
   write,
   wr_address,
	full
);

parameter buf_size = 500;
parameter buf_size_MSB = 8;

input clk;
input start_cor;
output write;
output [buf_size_MSB:0] wr_address;
output full;

reg start = 0;
reg [buf_size_MSB:0] cur_address = 0;

always @(posedge clk)
	if (start_cor) begin
		if (!start) begin
			start <= 1;
			cur_address <= 0;
		end else
			if (cur_address < buf_size - 1)
				cur_address <= cur_address + 1'b1;
	end else begin
		start <= 0; 
		cur_address <= 0;
	end

assign full = cur_address == buf_size - 1;
assign write = start & !full;
assign wr_address = cur_address;

endmodule 
