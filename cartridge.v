module cartridge(
				
				input MasterClk,
				
				input PPU_A0,
				input PPU_A1,
				input PPU_A2,
				input PPU_A3,
				input PPU_A4,
				input PPU_A5,
				input PPU_A6,
				input PPU_A7,
				input PPU_A8,
				input PPU_A9,
				input PPU_A10,
				input PPU_A11,
				input PPU_A12,
				input PPU_A13,
				inout reg PPU_D0,
				inout reg PPU_D1,
				inout reg PPU_D2,
				inout reg PPU_D3,
				inout reg PPU_D4,
				inout reg PPU_D5,
				inout reg PPU_D6,
				inout reg PPU_D7,
				
				input PPU_RD,
				input PPU_WR,
				
				output reg CIRAM_A10,
				output reg CIRAM_CE
				);
				
	`define BYTE reg[7:0]
	assign CIRAM_CE = ~PPU_A13;
	assign CIRAM_A10 = PPU_A10;		// Vertical Mirroring
	BYTE 	PPU_Memory[0:8191];
	
	`define ppuDataBus {PPU_D7,PPU_D6,PPU_D5,PPU_D4,PPU_D3,PPU_D2,PPU_D1,PPU_D0}
	`define ppuAddressBus {PPU_A12,PPU_A11,PPU_A10,PPU_A9,PPU_A8,PPU_A7,PPU_A6,PPU_A5,PPU_A4,PPU_A3,PPU_A2,PPU_A1,PPU_A0}

	wire clk;
	cartridgeClkDivider cartclk(masterClk, clk);
	always@ (posedge clk) begin
		if(~PPU_A13) begin
			if(PPU_RD)	ppuDataBus = localMemory[ppuAddressBus];
			else		localMemory[ppuAddressBus] = ppuDataBus;
		end
	end
	
endmodule