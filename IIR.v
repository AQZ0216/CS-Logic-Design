`define a5	32'b00000000000000000000010011111001
`define a4	32'b00000000000000000000010101100111
`define a3	32'b00000000000000000000100110100111
`define a2	32'b00000000000000000000100110100111
`define a1	32'b00000000000000000000010101100111
`define a0	32'b00000000000000000000010011111001
`define b4	32'b11111111111111010011110111110100
`define b3	32'b00000000000001000000001011010000
`define b2	32'b11111111111111001010000100000000
`define b1	32'b00000000000000011010011101111001
`define b0	32'b11111111111111111001111011010100

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
	
	reg [15:0] s0, s1, s2, s3, s4;
	reg [15:0] new_s0, new_s1, new_s2, new_s3, new_s4;
	wire [15:0] next_s0, next_s1, next_s2, next_s3, next_s4;
	wire [15:0] next_new_s0, next_new_s1, next_new_s2, next_new_s3, next_new_s4;
	wire [31:0] ans;
	
	always @(posedge clk or posedge rst)
	begin
		if(rst == 1'b1)
		begin
			RAddr <= 20'd0;
			WAddr <= 20'd0;
			Finish <= 1'b0;
			s0 <= 16'd0;
			s1 <= 16'd0;
			s2 <= 16'd0;
			s3 <= 16'd0;
			s4 <= 16'd0;
			new_s0 <= 16'd0;
			new_s1 <= 16'd0;
			new_s2 <= 16'd0;
			new_s3 <= 16'd0;
			new_s4 <= 16'd0;
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
	assign next_s4 = DIn;
	
	assign next_new_s0 = new_s1;
	assign next_new_s1 = new_s2;
	assign next_new_s2 = new_s3;
	assign next_new_s3 = new_s4;
	assign next_new_s4 = Yn;
	
	assign ans = `a0*{{16{s0[15]}}, s0} + `a1*{{16{s1[15]}}, s1} + `a2*{{16{s2[15]}}, s2} + `a3*{{16{s3[15]}}, s3} + `a4*{{16{s4[15]}}, s4} + `a5*{{16{DIn[15]}}, DIn} 
		- `b0*{{16{new_s0[15]}}, new_s0} - `b1*{{16{new_s1[15]}}, new_s1} - `b2*{{16{new_s2[15]}}, new_s2} - `b3*{{16{new_s3[15]}}, new_s3} - `b4*{{16{new_s4[15]}}, new_s4}; 
	assign Yn = ans[31:16];
	
endmodule
