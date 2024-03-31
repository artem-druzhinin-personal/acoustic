module cor (
	clk,
	full,
	buffer_val_0,
	buffer_val_1,
	rd_address,
	rd_address_0,
	max_offset1,
	ready
);

parameter buf_size = 500;
parameter buf_size_MSB = 8;
parameter ADC_MSB = 11;
parameter offset_MSB = 4;

input clk;
input full;
input signed [ADC_MSB:0] buffer_val_0;
input signed [ADC_MSB:0] buffer_val_1;
output [buf_size_MSB:0] rd_address;
output [buf_size_MSB:0] rd_address_0;
output signed [offset_MSB:0] max_offset1;
output ready;

reg start = 0;
reg ready_r = 0;
reg [buf_size_MSB:0] cur_address = 13;
reg signed [offset_MSB:0] cur_offset = -5'd13;
reg signed [40:0] sum1 = 0;
reg signed [40:0] max1 = 0;
reg signed [offset_MSB:0] max_offset_r1;
reg signed [offset_MSB:0] max_offset_o1;
wire signed [12:0] sum_adr = $signed(cur_address) + $signed(cur_offset);

always @(posedge clk) begin
	if (full) begin
		if (!start) begin
			ready_r <= 0;
			start <= 1;
			cur_address <= 14;
			sum1 <= 0;
			max1 <= 0;
			cur_offset <= -5'd13;
		end else begin
			if (cur_address < buf_size - 16) begin
				if (cur_address == 14) begin
					if (sum1 > max1) begin
						max1 <= sum1;
						max_offset_r1 <= cur_offset - 1'b1;
					end
					sum1 <= buffer_val_0 * buffer_val_1;
				end else
					sum1 <= sum1 + buffer_val_0 * buffer_val_1;
				cur_address <= cur_address + 1'b1;
			end else begin
				sum1 <= sum1 + buffer_val_0 * buffer_val_1;
				if (cur_offset < 14) begin
					cur_offset <= cur_offset + 1'b1;
					cur_address <= 13;
				end else begin
					ready_r <= 1;
					max_offset_o1 <= max_offset_r1;
				end
			end
		end
	end else begin 
		start <= 1'b0;
		ready_r <= 1'b0;
		start <= 1'b0;
		cur_address <= 9'd13;
		sum1 <= 1'b0;
		max1 <= 1'b0;
		cur_offset = -5'd13;
	end
end

assign rd_address_0 = cur_address;
assign rd_address = sum_adr;
assign max_offset1 = max_offset_o1;
assign ready = ready_r;

endmodule 