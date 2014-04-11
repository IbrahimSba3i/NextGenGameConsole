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
	
	It mainly contains 10 kilobytes of memory:
		8 kilobytes of ROM or RAM on the game cartridge (external) 
			Two external 4 kB tile sets (aka pattern tables) with space for 256 tiles each (usually one for the sprites and the other one for the nametable)
			each tile is 16 bytes (2 bits per pixel)
		2 kilobytes of RAM in the console (internal)
			each 1 kb is used to store tile layout and auxiliary colour information for background graphics (nametable + attribute table):
			A nametable is like a 2D array with the dimensions of the screen, each element in it is the index of the tile that should be displayed
			on the corresponding location on the screen
					~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					byte nametable[30][32];
					tile patterntable[256];
					for( i=0 -> 30 )
						for( j=0 -> 32 )
							screen[i][j].tile  = patterntable[ nametable[i][j] ];
					~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
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
			
			
*/
`include "cartridge.v"

'define width  256
'define height 240

module ppu( clk , cRegs);
	input clk;
	
	input reg [7:0] cRegs[0:7];		/*	8 control registers that are used to control the PPU they are accessed  
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
											16 colours for background:	bytes 0, 4, 8 and 12 cannot be used
											16 colours for sprites:		bytes 4, 8 and 12 cannot be used
																		byte 0 defines the global background colour for both sprites and the background.
											Therefore the actual number of usable colours is 25
									*/
									
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\
	
	
	always@(posedge clk) begin
		
	end
	
endmodule;