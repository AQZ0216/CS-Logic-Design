`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
`define S3 2'b11

module Det(clk,i,j,reset,read,write,read_data,write_data,finish);
	
	input clk;
	input reset;
	input [19:0] read_data;
	
	output reg [19:0] i, j;
	output reg read, write;
	output reg [39:0] write_data;
	output finish;
	
	reg [19:0] next_i, next_j;
	reg [39:0] next_write_data;
	
	reg [1:0] state, next_state;
	reg [19:0] cnt, next_cnt;	
	wire [19:0] row_column;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			i <= 20'd0;
			j <= 20'd0;
			write_data <= 40'd0;
			state <= `S0;
			cnt <= 20'd0
		end
		else
		begin
			i <= next_i;
			j <= next_j;
			write_data <= next_write_data;
			state <= next_state;
			cnt <= next_cnt;
		end
	end
	
	assign finish = (state == `S3) ? 1'b1: 1'b0;
	
	assign row_column = (state == `S0) ? read_data : row_column;
	 
	always @*
	begin
		next_i = i;
		next_j = j;
		next_write_data = write_data;
		next_state = state;
		next_cnt = cnt;
		
		case(state)
			`S0: begin
				read = 1'b1;
				write = 1'b1;
				next_state = `S1;
			end
			`S1: begin
				read = 1'b1;
				write = 1'b0;
				
				next_write_data = write_data + read_data;
				
				if(j == row_column - 20'd1)
				begin
					if(cnt == row_column - 20'd1)
					begin
						next_state = `S2;
						next_cnt = 20'd0;
						next_i = 20'd0;
						next_j = 20'd0;
					end
					else
					begin
						next_cnt = cnt + 20'd1;
						next_i = cnt + 20'd1;
						next_j = 20'd0;
					end
				end
				else if(i == row_column - 20'd1)
				begin
					next_i = 20'd0;
					next_j = j + 20'd1;
				end
				else
				begin
					next_i = i + 20'd1;
					next_j = j + 20'd1;
				end
			end
			`S2: begin
				read = 1'b1;
				write = 1'b0;
				
				next_write_data = write_data - read_data;
				
				if(j == row_column - 20'd1)
				begin
					if(cnt == row_column - 20'd1)
						next_state = `S3;
					else
					begin
						next_cnt = cnt + 20'd1;
						next_i = cnt + 20'd1;
						next_j = 20'd0;
					end
				end
				else if(i == 20'd0)
				begin
					next_i = row_column - 20'd1;
					next_j = j + 20'd1;
				end
				else
				begin
					next_i = i - 20'd1;
					next_j = j + 20'd1;
				end
			end
			`S3: begin
				read = 1'b0;
				write = 1'b1;
			end
		endcase
	end
	
endmodule
