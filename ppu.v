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
*/
`include "cartridge.v"

module ppu( clk , cRegs);
	input clk;
	
	input reg [7:0]cRegs[0:7];		/*	8 control registers that are used to control the PPU they are accessed  
										from the CPU's address space in the addresses $2000 through $2007
									*/
	reg [7:0]sprite_RAM [0:255];	/*	used for sprite attribute storage
										it is divided among 64 sprites each of 4 bytes: (only 8 per scan line)
											byte 0:		Y it is used to specify the row (from the top of the screen)
											byte 1:		the index of the sprite(tile) in the pattern table
											byte 2:		bit 0,1:-		the upper 2 colour bits
														bit 2,3,4:-		unknown
														bit 5:-			sprite priority:	0= High priority, in front of nametables
																							1= Low priority, behind nametables
														bit 6:-			Horizontal flip
														bit 7:-			Vertical flip			
											byte 3:		X it is used to specify the column (index from the from the left side of the screen)
									*/
	reg [7:0]palette_RAM [0:31];	/*	used for colour palette storage
											16 colours ( 0-15) for background:	bytes 0, 4, 8 and 12 cannot be used
											16 colours (16-31) for sprites:		bytes 4, 8 and 12 cannot be used
																				byte 0 defines the global background colour for both sprites and the background.
											Therefore the actual number of usable colours is 25
									*/
									
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\
	initial begin
	
	end
	always@(cRegs) begin
		// deal with the changes in the registers
	end
	always@(posedge clk) begin
					/*
					// pseudo-code
					
					byte nametable[30][32];
					tile patterntable[256];		// a tile is a 2D array of 2bits
					color_tile screen[30][32]	// a color_tile is a 2D array of 4bits
					for( int i=0; i<30; i++)
						for( int j=0; j<32; j++){
							for( int k=0; k<8; k++)
								for( int l=0; l<8; l++){
									if(patterntable[ nametable[i][j] ][k][l] == 2'b00)
										screen[i][j][k][l] = transparent;
									else
										screen[i][j][k][l] = {attribute_table[i/2][j/2], patterntable[ nametable[i][j] ][k][l]} // concatenation 
									//	i and j indices of the tile
									//	k and l indices of pixel within a tile
									}
											
							}
						}
					*/
	end
	
endmodule;