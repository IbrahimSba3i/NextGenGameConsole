`include "cartridge.v"

module cpu( mainClk );
	input mainClk;
	wire clk;
	
	//~~~~~~~ CPU Registers ~~~~~~~~
	reg [7:0] accum;
	reg [7:0] stackPointer;
	reg [7:0] indexX;
	reg [7:0] indexY;
	reg [7:0] statusRegister;
	reg [15:0] PC;
	//~~~~~~~ CPU Memory ~~~~~~~~
	reg [7:0] mem[0:2047]; // 2 kb internal ram
	reg [7:0] cartridgeMem[0:63487]; // 62 kb cartridge ram/rom
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~
	cpuClockDivider clkDiv( mainClk , clk );
	
	ppu PicturePU( mainClk , cartridgeMem[6144:6151] );
	
	initial begin
	
	end
	
	always@(*) begin
	
	end
	
	always@(posedge clk) begin
		
	end
	
endmodule;