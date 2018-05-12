`define S0 2'b00 //read the scale of a, b matrix
`define S1 2'b01 //read the value of a
`define S2 2'b10 //read the value of b
`define S3 2'b11 //write

module MM(clk,i,j,reset,read,write,index,read_data,write_data,finish);
	input clk;
	input reset;
	input [19:0] read_data;
	
	output reg [19:0] i, j;
	output reg read, write;
	output reg index;
	output reg [39:0] write_data;
	output reg finish;
	
	reg [19:0] next_i, next_j;
	reg [39:0] write_data;
	wire next_finish;
	
	reg [1:0] state, next_state;
	
	wire [19:0] a; //to record the value of a temporary
	
	wire [19:0] m1_row;
	wire [19:0] m1_column;
	wire [19:0] m2_column;
	reg [19:0] row, column, next_row, next_column;
	
	always @(posedge clk or posedge reset) //D flip-flop
	begin
		if(reset == 1'b1)
    		begin
			i <= 20'd0;
			j <= 20'd0;
			write_data <= 40'd0;
			row <= 20'b0;
			column <= 20'b0;
			state <= `S0;
			finish <= 1'd0;
		end
		else
		begin
			i <= next_i;
			j <= next_j;
			write_data <= next_write_data;
			row <= next_row;
			column <= next_column;
			state <= next_state;
			finish <= next_finish;
		end
	end
    
	assign next_finish = (state == `S3 && row == m1_row - 20'd1 && column == m2_column - 20'd1) ? 1'b1 : 1'b0;
	
	assign m1_row = (state == `S0 && i == 20'd0) ? read_data : m1_row;
	assign m1_column = (state == `S0 && i == 20'd1) ? read_data : m1_column;
	assign m2_column = (state == `S0 && i == 20'd2) ? read_data : m2_column;
	assign a = (state == `S1) ? read_data : a; //to record the value of a temporary
	
	always @*
	begin
		next_i = i;
		next_j = j;
		next_write_data = write_data;
		next_row = row;
		next_column = column;
		next_state = state;
		
		case(state)
			`S0: begin //read the scale of a, b matrix
				read = 1'b1;
				write = 1'b1;
				
				if(i == 20'd2)
				begin
					next_state = `S1;
					next_i = 20'd0;
				end
				else
					next_i = i + 20'd1;
			end
			
			`S1: begin //read the value of a
				read = 1'b1;
				write = 1'b0;
				index = 1'b0;
				
				next_state = `S2;
				
				next_i = j; //the i of b will equal to the j of a
				next_j = column; //the j of b will equal to the j of c
			end
			
			`S2: begin //read the value of b, and multiply a and b
				read = 1'b1;
				write = 1'b0;
				index = 1'b1;
				
				next_write_data = write_data + { {20{a[19]}}, a} * { {20{read_data[19]}}, read_data}; //multiply a and b, which needs sign extension
				
				if(i == m1_column - 20'd1)
					next_state = `S3;
				else
				begin
					next_i = row; //the i of a will equal to the i of c
					next_j = i + 20'd1;
					next_state = `S1;
				end
			end	
			
			`S3: begin //write
				read = 1'b0;
				write = 1'b1;
				index = 1'b0;
				
				next_state = `S1;
				next_j = 20'd0;
				next_write_data = 40'd0;
				
				if(column == m2_column - 20'd1) //change the row and column
				begin
					next_i = row +20'd1;
					next_row = row +20'd1;
					next_column = 20'd0;
				end
				else
				begin
					next_i = row;
					next_row = row;
					next_column = column + 20'd1;
				end
			end
			
		endcase
	end
	
endmodule
