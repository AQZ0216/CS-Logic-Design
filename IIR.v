`define a5	25'b00000000000010011111001
`define a4	25'b00000000000010101100111
`define a3	25'b00000000000100110100111
`define a2	25'b00000000000100110100111
`define a1	25'b00000000000010101100111
`define a0	25'b00000000000010011111001
`define b4	25'b00000101100001000001100
`define b3	25'b00001000000001011010000
`define b2	25'b00000110101111100000000
`define b1	25'b00000011010011101111001
`define b0	25'b00000000110000100101100

module IIR(clk,rst,load,DIn,RAddr,data_done,WEN,Yn,WAddr,Finish);

	input clk ,rst;
	input data_done;
	input [15:0] DIn;
	
	output WEN, load;
	output reg Finish;
	output [15:0] Yn;
	output reg [19:0] RAddr, WAddr;
	
	wire [19:0] next_RAddr, next_WAddr;
	wire next_Finish;
	
	reg [24:0] s0, s1, s2, s3, s4;
	reg [24:0] new_s0, new_s1, new_s2, new_s3, new_s4;
	wire [24:0] next_s0, next_s1, next_s2, next_s3, next_s4;
	wire [24:0] next_new_s0, next_new_s1, next_new_s2, next_new_s3, next_new_s4;
	wire [31:0] sum;
	
	always @(posedge clk or posedge rst)
	begin
		if(rst == 1'b1)
		begin
			RAddr <= 20'd0;
			WAddr <= 20'd0;
			Finish <= 1'b0;
			s0 <= 25'd0;
			s1 <= 25'd0;
			s2 <= 25'd0;
			s3 <= 25'd0;
			s4 <= 25'd0;
			new_s0 <= 25'd0;
			new_s1 <= 25'd0;
			new_s2 <= 25'd0;
			new_s3 <= 25'd0;
			new_s4 <= 25'd0;
		end
		else
		begin
			RAddr <= next_RAddr;
			WAddr <= next_WAddr;
			Finish <= next_Finish;
			s0 <= next_s0;
			s1 <= next_s1;
			s2 <= next_s2;
			s3 <= next_s3;
			s4 <= next_s4;
			new_s0 <= next_new_s0;
			new_s1 <= next_new_s1;
			new_s2 <= next_new_s2;
			new_s3 <= next_new_s3;
			new_s4 <= next_new_s4;
		end
	end
	
	assign WEN = (RAddr>20'b0) ? 1'b1 : 1'b0; 
	assign load = 1'b1;
	
	assign next_Finish = (data_done == 1'b1) ? 1'b1 : 1'b0;
	assign next_RAddr = RAddr + 20'b1;
	assign next_WAddr = RAddr;
	
	assign next_s0 = s1;
	assign next_s1 = s2;
	assign next_s2 = s3;
	assign next_s3 = s4;
	assign next_s4 = {{2{DIn[15]}}, DIn, {7{1'b0}}};
	
	assign next_new_s0 = new_s1;
	assign next_new_s1 = new_s2;
	assign next_new_s2 = new_s3;
	assign next_new_s3 = new_s4;
	assign next_new_s4 = sum[31:7]; 
	
	assign sum = `a0*s0 + `a1*s1 + `a2*s2 + `a3*s3 + `a4*s4 + `a5*{{2{DIn[15]}}, DIn, {7{1'b0}}}
		+ `b0*new_s0 - `b1*new_s1 + `b2*new_s2- `b3*new_s3 + `b4*new_s4;
	
	assign Yn = sum[31:16];
	
endmodule
