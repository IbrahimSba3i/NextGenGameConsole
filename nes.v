`define BYTE reg[7:0]

module nesConsole( masterClk, rst );
	
	input  wire masterClk, rst;
	
	cpu proc();
	
	wire PPU_AD0, PPU_AD1, PPU_AD2, PPU_AD3, PPU_AD4, PPU_AD5, PPU_AD6, PPU_AD7, PPU_A8, PPU_A9, PPU_A10, PPU_A11, PPU_A12, PPU_A13, PPU_RD, PPU_WR, PPU_D0, PPU_D1, PPU_D2, PPU_D3, PPU_D4, PPU_D5, PPU_D6, PPU_D7, PPU_A0, PPU_A1, PPU_A2, RD_WR, INT, ALE, vout, CS, PPU_EXT0, PPU_EXT1, PPU_EXT2, PPU_EXT3, CIRAM_A10, CIRAM_CE;
		
	ppu pict(PPU_AD0, PPU_AD1, PPU_AD2, PPU_AD3, PPU_AD4, PPU_AD5, PPU_AD6, PPU_AD7, PPU_A8, PPU_A9, PPU_A10, PPU_A11, PPU_A12, PPU_A13, PPU_RD, PPU_WR, PPU_D0, PPU_D1, PPU_D2, PPU_D3, PPU_D4, PPU_D5, PPU_D6, PPU_D7, PPU_A0, PPU_A1, PPU_A2, RD_WR, INT, ALE, vout, CS, PPU_EXT0, PPU_EXT1, PPU_EXT2, PPU_EXT3);
	
	cartridge cart(PPU_AD0, PPU_AD1, PPU_AD2, PPU_AD3, PPU_AD4, PPU_AD5, PPU_AD6, PPU_AD7, PPU_A8, PPU_A9, PPU_A10, PPU_A11, PPU_A12, PPU_A13, PPU_AD0, PPU_AD1, PPU_AD2, PPU_AD3, PPU_AD4, PPU_AD5, PPU_AD6, PPU_AD7, PPU_RD, PPU_WR, CIRAM_A10, CIRAM_CE);
	ppuMemory ppumem(PPU_AD0, PPU_AD1, PPU_AD2, PPU_AD3, PPU_AD4, PPU_AD5, PPU_AD6, PPU_AD7, PPU_A8, PPU_A9, CIRAM_A10, PPU_AD0, PPU_AD1, PPU_AD2, PPU_AD3, PPU_AD4, PPU_AD5, PPU_AD6, PPU_AD7, PPU_RD, PPU_WR, CIRAM_CE);
	
endmodule;