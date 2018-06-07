module IIR(clk,rst,load,DIn,RAddr,data_done,WEN,Yn,WAddr,Finish);

	input clk ,rst;
	input data_done;
	input signed [15:0] DIn;
	
	output WEN, load;
	output reg Finish;
	output reg signed [15:0] Yn;
	output reg [19:0] RAddr, WAddr;
	
	wire [19:0] next_RAddr, next_WAddr;
	wire next_Finish;
	wire signed [15:0] next_Yn;
	
	reg signed [24:0] s0, s1, s2, s3, s4;
	wire signed [24:0] s5;
	reg signed [24:0] new_s0, new_s1, new_s2, new_s3, new_s4;
	wire signed [24:0] next_s0, next_s1, next_s2, next_s3, next_s4;
	wire signed [24:0] next_new_s0, next_new_s1, next_new_s2, next_new_s3, next_new_s4;
	wire signed [24:0] weight_s0, weight_s1, weight_s2, weight_s3, weight_s4, weight_s5;
	wire signed [24:0] weight_new_s0, weight_new_s1, weight_new_s2, weight_new_s3, weight_new_s4;
	wire signed [24:0] sum;
	
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
			Yn <= 16'b0;
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
			Yn <= next_Yn;
		end
	end
	
	assign WEN = (RAddr>20'b0) ? 1'b1 : 1'b0; 
	assign load = 1'b1;
	
	assign s5 = {{2{DIn[15]}}, DIn, {7{1'b0}}};
	
	assign next_Finish = (data_done == 1'b1) ? 1'b1 : 1'b0;
	assign next_RAddr = RAddr + 20'b1;
	assign next_WAddr = RAddr;
	
	assign next_s0 = s1;
	assign next_s1 = s2;
	assign next_s2 = s3;
	assign next_s3 = s4;
	assign next_s4 = s5;
	
	assign next_new_s0 = {{2{new_s1[15]}}, new_s1, {7{1'b0}}};
	assign next_new_s1 = {{2{new_s2[15]}}, new_s2, {7{1'b0}}};
	assign next_new_s2 = {{2{new_s3[15]}}, new_s3, {7{1'b0}}};
	assign next_new_s3 = {{2{new_s4[15]}}, new_s4, {7{1'b0}}};
	assign next_new_s4 = {{2{sum[15]}}, sum, {7{1'b0}}}; 
	
	assign weight_s5 = (s5>>>6) + (s5>>>9) + (s5>>>10) + (s5>>>11) + (s5>>>12) + (s5>>>13) + (s5>>>16);
	assign weight_s4 = (s4>>>6) + (s4>>>8) + (s4>>>10) + (s4>>>11) + (s4>>>14) + (s4>>>15) + (s4>>>16);
	assign weight_s3 = (s3>>>5) + (s3>>>8) + (s3>>>9) + (s3>>>11) + (s3>>>14) + (s3>>>15) + (s3>>>16);
	assign weight_s2 = (s2>>>5) + (s2>>>8) + (s2>>>9) + (s2>>>11) + (s2>>>14) + (s2>>>15) + (s2>>>16);
	assign weight_s1 = (s1>>>6) + (s1>>>8) + (s1>>>10) + (s1>>>11) + (s1>>>14) + (s1>>>15) + (s1>>>16);
	assign weight_s0 = (s0>>>6) + (s0>>>9) + (s0>>>10) + (s0>>>11) + (s0>>>12) + (s0>>>13) + (s0>>>16);
	assign weight_new_s4 = (new_s4<<<1) + (new_s4>>>1) + (new_s4>>>2) + (new_s4>>>7) + (new_s4>>>13) + (new_s4>>>14);
	assign weight_new_s3 = (new_s3<<<2) + (new_s3>>>7) + (new_s3>>>9) + (new_s3>>>10) + (new_s3>>>12);
	assign weight_new_s2 = (new_s2<<<1) + (new_s2) + (new_s2>>>2) + (new_s2>>>4) + (new_s2>>>5) + (new_s2>>>6) + (new_s2>>>7) + (new_s4>>>8);
	assign weight_new_s1 = (new_s1) + (new_s1>>>1) + (new_s1>>>3) + (new_s1>>>6) + (new_s1>>>7) + (new_s1>>>8) + (new_s1>>>10) + (new_s1>>>11) + (new_s1>>>12) + (new_s1>>>13) + (new_s1>>>16);
	assign weight_new_s0 = (new_s0>>>2) + (new_s0>>>3) + (new_s0>>>8) + (new_s0>>>11) + (new_s0>>>13) + (new_s0>>>14);
	
	assign sum = weight_s5 + weight_s4 + weight_s3 + weight_s2 + weight_s1 + weight_s0 
		+ weight_new_s4 - weight_new_s3 + weight_new_s2 - weight_new_s1 + weight_new_s0;
	
	assign next_Yn = {sum[24], sum[21:7]};
	
endmodule
