/*	 ___________________________________________
	|											|
	|			  ____  ____  _   _ 			|
	|			 |  _ \|  _ \| | | |			|
	|			 | |_) | |_) | | | |			|
	|			 |  __/|  __/| |_| |			|
	|			 |_|   |_|    \___/ 			|
	|		The Picture Processing Unit			|
	|											|
	|___________________________________________|
	
	It mainly contains of:
		8 kilobytes of ROM or RAM on the game cartridge (external) 
			Two external 4 kB tile sets (aka pattern tables) with space for 256 tiles each (usually one for the sprites and the other one for the nametable)
			each tile is 16 bytes (2 bits per pixel)
			
			the 16 bytes are divided into 2 sets of 8 bytes:
				$0000-$0FFF, nicknamed "left", and $1000-$1FFF, nicknamed "right"
				each group of 8 bytes represents the tile as:
					1)	the byte number is the row number
					2)	the bit  number is the column number.
				Therefore, each pixel is represented using the 2 bits from the "left" and the "right" sets
				If the 2 bits are 0 then the pixel is considered transparent
		2 kilobytes of RAM in the console (internal)
			each 1 kb is used to store tile layout and auxiliary colour information for background graphics (nametable + attribute table):
			A nametable is like a 2D array with the dimensions of the screen, each element in it is the index of the tile that should be displayed
			on the corresponding location on the screen

			The size of each nametable = 32*30 = 960 bytes
			The remaining 64 bytes(which is 1024 - 960 bytes) are reserved for the attribute table
			Each 2 bits of the attribute table are used as the upper 2 bits of the colour of a 2x2 
			block of tiles (the lower 2 bits exist in the pattern table)
			
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			For each byte of the 64 bytes of the attribute table:-
			
				   (0,0)  (1,0) 0|  (2,0)  (3,0) 1
				   (0,1)  (1,1)  |  (2,1)  (3,1)
				   --------------+----------------
				   (0,2)  (1,2) 2|  (2,2)  (3,2) 3
				   (0,3)  (1,3)  |  (2,3)  (3,3)
				  ______________________________________________________________
				  Bits   Function                        Tiles
				  --------------------------------------------------------------
				  7,6    Upper color bits for square 3   (2,2),(3,2),(2,3),(3,3)    
				  5,4    Upper color bits for square 2   (0,2),(1,2),(0,3),(1,3)
				  3,2    Upper color bits for square 1   (2,0),(3,0),(2,1),(3,1)
				  1,0    Upper color bits for square 0   (0,0),(1,0),(0,1),(1,1)
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Therefore, we only have a total of 4 bits to represent a colour (16 total colours)
			
_____________________________________________________________________________________________________________________________________________________________



				 .--\/--.					 
		  R/W -> |01  40| -- +5
		   D0 <> |02  39| -> ALE
		   D1 <> |03  38| <> AD0
		   D2 <> |04  37| <> AD1
		   D3 <> |05  36| <> AD2
		   D4 <> |06  35| <> AD3
		   D5 <> |07  34| <> AD4
		   D6 <> |08  33| <> AD5
		   D7 <> |09  32| <> AD6
		   A2 -> |10  31| <> AD7
		   A1 -> |11  30| -> A8
		   A0 -> |12  29| -> A9
		  /CS -> |13  28| -> A10
		 EXT0 <> |14  27| -> A11
		 EXT1 <> |15  26| -> A12
		 EXT2 <> |16  25| -> A13
		 EXT3 <> |17  24| -> /RD
		  CLK -> |18  23| -> /WR
		 /INT <- |19  22| <- /RST
		  GND -- |20  21| -> VOUT
				 `------'
		 
*/

// 1 ppu frame = 89342 ppu clock cycles
// master clock speed 21.477272  (+-) 40 Hz
// ppu clock speed = 21.477272 / 4.0

module ppu(
			input  masterClk,
			input  rst, 
			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// Transfer data from/to the Cartridge:
			// the 14 pins AD0 - AD7 and A8 - A13 for the address bus
			// the 8 pins AD0 - AD7 are also used to transfer the data
			inout  reg AD0, 
			inout  reg AD1,
			inout  reg AD2,
			inout  reg AD3,
			inout  reg AD4,
			inout  reg AD5,
			inout  reg AD6,
			inout  reg AD7,
			output reg A8,
			output reg A9,
			output reg A10,
			output reg A11,
			output reg A12,
			output reg A13,
			
			output reg RD,
			output reg WR,
			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			// Transfer data from/to the CPU:
			// Data bus
			inout  reg D0,
			inout  reg D1,
			inout  reg D2,
			inout  reg D3,
			inout  reg D4,
			inout  reg D5,
			inout  reg D6,
			inout  reg D7,
			// Choose Which register using these 3 inputs:
			input  A0,	// Connected to CPU A0
			input  A1,  // Connected to CPU A1
			input  A2,  // Connected to CPU A2
			// Indicate whether the PPU is reading or writing to CPU
			input  RD_WR,  // 0 write, 1 read
			// connected to CPU NMI pin:
			output reg INT,
			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			output reg ALE,
			output reg vout, 
			input  CS,
			inout  EXT0,
			inout  EXT1,
			inout  EXT2,
			inout  EXT3,
			);
	wire clk;
	ppuClockDivider clkdiv( masterClk , clk );

	reg[7:0] cRegs[0:7];
	`define PPUCTRL   cRegs[0]
	`define PPUMASK   cRegs[1]
	`define PPUSTATUS cRegs[2]
	`define OAMADDR   cRegs[3]
	`define OAMDATA   cRegs[4]
	`define PPUSCROLL cRegs[5]
	`define PPUADDR   cRegs[6]
	`define PPUDATA   cRegs[7]
	
	
	
	reg[7:0] sprite_RAM [0:255];	//	to store the sprites
	reg[7:0] palette_RAM [0:31];	/*	used for colour palette storage
											16 colours ( 0-15) for background:	bytes 0, 4, 8 and 12 cannot be used
											16 colours (16-31) for sprites:		bytes 4, 8 and 12 cannot be used
																				byte 0 defines the global background colour for both sprites and the background.
									*/
	reg[7:0] HScroll;
	reg[7:0] VScroll;
	reg [13:0] ppuAddress;
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// registers for rendering the BG
	
	reg [14:0] VRAM_Address;
	reg [14:0] VRAM_tempAddress;
	reg [2:0] fineX_Scroll;
	reg firstOrSecondWrite;
	
	reg [15:0] tile1;
	reg [15:0] tile2;
	reg [7:0] pallette1;
	reg [7:0] pallette2;
	
	// registers for rendering the Sprites
	
	reg[7:0] secondary_sprite_RAM [0:31];
	reg[7:0] spritesBitmapRegisters [0:16];
	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	`define dataBus {AD7,AD6,AD5,AD4,AD3,AD2,AD1,AD0}
	`define externalAddressBus {A13,A12,A11,A10,A9,A8,AD7,AD6,AD5,AD4,AD3,AD2,AD1,AD0}
	`define cpuDataBus {D7,D6,D5,D4,D3,D2,D1,D0}
	`define regIndex {A2,A1,A0}
	
	reg gotFirstWrite`PPUADDR, gotFirstWrite`PPUSCROLL;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\
	
	
	// Subroutines for the sprite ram
	task GetSpriteIndex;
		input [7:0] spriteNumber;
		output [7:0] patternTableIndex;
		begin
			patternTableIndex = sprite_RAM[(spriteNumber << 2'b10) + 1'd1];
		end
	end
	task GetY;
		input [7:0] spriteNumber;
		output [7:0] Y;
		begin
			Y = sprite_RAM[spriteNumber << 2'b10];
		end
	end
	task GetX;
		input [7:0] spriteNumber;
		output [7:0] X;
		begin
			X = sprite_RAM[(spriteNumber << 2'b10) + 1'd3];
		end
	end
	task GetUpper2BitsColors;
		input [7:0] spriteNumber;
		output [1:0] upperColor;
		reg [7:0] byte2;
		begin
			byte2 = sprite_RAM[(spriteNumber << 2'b10) + 1'd2];
			upperColor = byte2[1:0]
		end
	end
	task IsLowPriority;
		input [7:0] spriteNumber;
		output pri;
		reg [7:0] byte2;
		begin
			byte2 = sprite_RAM[(spriteNumber << 2'b10) + 1'd2];
			pri = byte2[1'd5]
		end
	end
	task IsHorizontallyFlipped;
		input [7:0] spriteNumber;
		output h;
		reg [7:0] byte2;
		begin
			byte2 = sprite_RAM[(spriteNumber << 2'b10) + 1'd2];
			h = byte2[1'd6]
		end
	end
	task IsVerticallyFlipped;
		input [7:0] spriteNumber;
		output v;
		reg [7:0] byte2;
		begin
			byte2 = sprite_RAM[(spriteNumber << 2'b10) + 1'd2];
			v = byte2[1'd7]
		end
	end
	
	// Subroutines for `PPUCTRL
	task GetBaseNameTableAddress;
		output [15:0]ntaddr;
		reg [1:0]ntindex;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			ntindex = temp[1:0];
			ntaddr = 4'h2000 + (ntindex * 4'h0400);
		end
	end
	task IsNMIEnabled;
		output r;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			r = temp[1'd7];
		end
	end
	task GetSpritePatternTableAddress;
		output [15:0]ptaddr;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			ptaddr = (temp[3'b011])? 4'h0000:4'h1000;
		end
	end
	task GetBGPatternTableAddress;
		output [15:0]ptaddr;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			ptaddr = (!temp[3'b100])? 4'h0000:4'h1000;
		end
	end
	task Is8x16;
		output s;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			s = temp[3'b101];
		end
	end
	task GetMasterSlaveSel;
		output s;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			s = temp[3'b110];
		end
	end
	task GetIncrementValue;
		output [7:0] incValue;
		reg[7:0] temp;
		begin
			temp = `PPUCTRL;
			incValue = (temp[3'b110])? 8'b00100000:8'b00000001;
		end
	end
	
	// Subroutines for `PPUMASK
	task IsGrayScale;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b000];
		end
	end
	task IsShowingBGOnLeft;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b001];
		end
	end
	task IsShowingSpritesOnLeft;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b010];
		end
	end
	task IsShowingBG;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b011];
		end
	end
	task IsShowingSprites;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b100];
		end
	end
	task IsIntensifyRed;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b101];
		end
	end
	task IsIntensifyGreen;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b110];
		end
	end
	task IsIntensifyBlue;
		output g;
		reg[7:0] temp;
		begin
			temp = `PPUMASK;
			g = temp[3'b111];
		end
	end
	
	// Subroutines for `PPUSTATUS
	task SetVBlank;
		input r;
		reg[7:0] temp;
		begin
			temp = `PPUSTATUS;
			temp[3'b111] = r;
			`PPUSTATUS = temp;
			if(IsNMIEnabled())
				INT = r;
		end
	end
	task SetSprite0Hit;
		input r;
		reg[7:0] temp;
		begin
			temp = `PPUSTATUS;
			temp[3'b110] = r;
			`PPUSTATUS = temp;
		end
	end
	task SetSpriteOverFlow;
		input r;
		reg[7:0] temp;
		begin
			temp = `PPUSTATUS;
			temp[3'b101] = r;
			`PPUSTATUS = temp;
		end
	end
	task PPUStatusRead;
		begin
			// Reset stuff
		end
	end
	
	task writeOAMData;
		begin // replace * by condition
			sprite_RAM[`OAMADDR] = `OAMDATA;
			`OAMADDR = `OAMADDR + GetIncrementValue();
		end
	end
	task writeScrollData;
		begin
			if(gotFirstWrite`PPUSCROLL)
				VScroll = `PPUSCROLL;
			else
				HScroll = `PPUSCROLL;
			gotFirstWrite`PPUSCROLL = !gotFirstWrite`PPUSCROLL;
		end
	end
	task writePPUData;
		begin
			if( ppuAddress[13:8] == 6'b111111) begin
				// palette ram
				palette_ram[ppuAddress[4:0]] = `PPUDATA;
			end
			else begin
				externalAddressBus = ppuAddress[13:0];
				// delay here
				dataBus = `PPUDATA;
				WR = 1'b0;
				RD = 1'b1;
				ppuAddress = ppuAddress + GetIncrementValue();
			end
		end
	end
	task writePPUAddress;
		begin
			ppuAddress = (gotFirstWrite`PPUADDR)? {ppuAddress[15:8] , `PPUADDR}:{`PPUADDR , ppuAddress[7:0]|8'b00000000};
			gotFirstWrite`PPUADDR = !gotFirstWrite`PPUADDR;
		end
	end
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\
	
	integer i,currentCycle,currentScanline;
	always@(posedge clk or negedge rst) begin
		if(~rst) begin // reset all to zero
			HScroll <= 8'b00000000;
			VScroll   <= 8'b00000000;
			ppuAddress <= 4'h0000;
			for(i=0; i<256; i++)
				sprite_RAM[i] <= 8'b00000000;
			for(i=0; i<32; i++)
				palette_RAM[i] <= 8'b00000000;
			`PPUCTRL   <= 8'b00000000;
			`PPUMASK   <= 8'b00000000;
			`PPUSCROLL <= 8'b00000000;
			gotFirstWrite`PPUADDR   <= 1'b0;
			gotFirstWrite`PPUSCROLL <= 1'b0;
			INT <= 1'b0;
			RD <= 1'b0;
			WR <= 1'b0;
			currentCycle = 1'b0;
			currentScanline = 1'b0;
		end
		else begin

			// rendering the scene
			case(currentCycle % 8)
				0:	begin
						
					end
				1:	begin
						
					end
				2:	begin
						
					end
				3:	begin
						
					end
				4:	begin
						
					end
				5:	begin
						
					end
				6:	begin
						
					end
				7:	begin
						
					end
			endcase
			
			if(currentScanline == GetY(6'b000000))
				SetSprite0Hit(1'b1);
			if(currentScanline == 261 && currentCycle == 1) begin
				SetVBlank(1'b0);
				SetSprite0Hit(1'b0);
			end
			if(currentScanline == 241 && currentCycle == 1)
				SetVBlank(1'b1);
			currentCycle = (currentCycle + 1) % 341;
			currentScanline = (currentCycle == 0)? ((currentScanline + 1) % 262):currentScanline;
			
			/*
			if(*) begin			// there should be a condition to enable that 
				if(RD_WR) begin						// Read
					cpuDataBus = cRegs[regIndex];
					case (regIndex)
						3'b010: PPUStatusRead();
					end
				end
				else begin							// Write
						cRegs[regIndex] = cpuDataBus;
						case (regIndex)
							3'b100: writeOAMData();		// `OAMDATA index
							3'b101: writeScrollData();	// `PPUSCROLL index
							3'b110: writePPUAddress();	// `PPUADDR index
							3'b111: writePPUData();		// `PPUDATA index
						end
				end
			end
			*/	
		end
	end
	
endmodule;