module ctrlBlock # (
	parameter FilterLength = 16,
	parameter InterpolationK = 2
)
(
	input Rst_i,
	input Clk_i,
	
	input DataNd_i,
	
	output [3:0] DataAddrWr_o,
	output [3:0] DataAddr_o,
	output [3:0] CoeffAddr_o,
	output StartAcc_o,
	
	output DataValid_o
);

	reg [3:0] runNumber;
	reg [3:0] addrWr;
	reg [3:0] dataAddr;
	reg [3:0] coeffAddr;
	reg rdy;
	reg startAcc;
			
	parameter Idle = 0;
	parameter Work = 1;
	reg [3:0] state;
	always @ (posedge Rst_i or posedge Clk_i)
		if (Rst_i)
			begin
				state <= Idle;
				addrWr <= 0;
				rdy <= 0;
				startAcc <= 0;
			end
		else
			case (state)
				Idle : begin
							dataAddr <= addrWr;
							coeffAddr <= 0;
							rdy <= 0;
							runNumber <= 1;
							startAcc <= 0;
							if (DataNd_i)
								begin
									startAcc <= 1;
									state <= Work;
								end
						end
				Work : begin
							startAcc <= 0;
							rdy <= 0;
							if (coeffAddr + InterpolationK < FilterLength)
								begin
									dataAddr <= dataAddr - 1;
									coeffAddr <= coeffAddr + InterpolationK;
								end
							else if (runNumber < InterpolationK)
								begin
									dataAddr <= addrWr;
									coeffAddr <= runNumber;
									startAcc <= 1;
									runNumber <= runNumber + 1;
									rdy <= 1;
									if (runNumber == InterpolationK-1)
										addrWr <= addrWr + 1;
								end
							else
								begin
									if (DataNd_i)
										begin
											state <= Work;
											startAcc <= 1;
											runNumber <= 1;
											dataAddr <= addrWr;
											coeffAddr <= 0;											
										end
									else 
										state <= Idle;
									rdy <= 1;						
								end
						end
				default : state <= Idle;
			endcase 
			
	reg [2:0] rdyShReg;
	always @ (posedge Rst_i or posedge Clk_i)
		if (Rst_i)
			rdyShReg <= 0;
		else
			rdyShReg <= {rdyShReg[1:0], rdy};
			
	reg [2:0] startAccShReg;
	always @ (posedge Rst_i or posedge Clk_i)
		if (Rst_i)
			startAccShReg <= 0;
		else
			startAccShReg <= {startAccShReg[1:0], startAcc};
			
	assign DataAddrWr_o = addrWr;
	assign DataAddr_o = dataAddr;
	assign CoeffAddr_o = coeffAddr;
	assign StartAcc_o = startAccShReg[1];
			
	assign DataValid_o = rdyShReg[1];

endmodule
