`timescale 1ps / 1ps
module singleMaccInterpolatorImpulse_tb;

	// Inputs
	reg Rst_i;
	reg CoeffClk_i;
	reg [3:0] CoeffAddr_i;
	reg [17:0] CoeffData_i;
	reg CoeffWr_i;
	reg Clk_i;
	reg [17:0] Data_i;
	reg DataNd_i;

	// Outputs
	wire [17:0] Data_o;
	wire DataValid_o;

	// Instantiate the Unit Under Test (UUT)
	singleMaccInterpolator # (
		.InterpolationK(2)
	)
	uut 
	(
		.Rst_i(Rst_i), 
		.CoeffClk_i(CoeffClk_i), 
		.CoeffAddr_i(CoeffAddr_i), 
		.CoeffData_i(CoeffData_i), 
		.CoeffWr_i(CoeffWr_i), 
		.Clk_i(Clk_i), 
		.Data_i(Data_i), 
		.DataNd_i(DataNd_i), 
		.Data_o(Data_o), 
		.DataValid_o(DataValid_o)
	);

	initial begin
		Rst_i = 1;
		CoeffClk_i = 0;
		CoeffAddr_i = 0;
		CoeffData_i = 0;
		CoeffWr_i = 0;
		Clk_i = 0;
		Data_i = 0;
		DataNd_i = 0;
		#100;
		Rst_i <= 0;
	end
      
	parameter period = 5000;
	always # (period / 2) Clk_i <= ~Clk_i;
	
	integer simCnt = 0;
	always @ (posedge Clk_i) simCnt <= simCnt + 1;
	
	always @ (posedge Clk_i)
		if (simCnt % 16 == 0)
			begin
				DataNd_i <= 1;
				if (simCnt == 16*100)
					Data_i <= 18'h1FFFF;
				else
					Data_i = 0;
			end
		else
			DataNd_i <= 0;
			
	reg [17:0] dataOutTest;
	always @ (posedge Clk_i)
		if (DataValid_o)
			dataOutTest <= Data_o;
		
endmodule

