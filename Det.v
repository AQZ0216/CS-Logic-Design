`define S0 2'b00
`define S1 2'b01

module MM(clk,i,j,reset,read,write,read_data,write_data,finish);
	
	input clk;
	input reset;
	input [19:0] read_data;
	
	output [19:0] i, j;
	output read, write;
	output [39:0] write_data;
	output finish;
	
	reg [1:0] state, next_state;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			state <= `S0;	
		end
		else
		begin
			state <= next_state;
		end
	end
	
	always @*
	begin
		case(state)
			`S0: begin
				
			end
		endcase
	end
	
endmodule
