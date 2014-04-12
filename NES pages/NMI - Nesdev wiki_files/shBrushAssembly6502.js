// 6502/65816 brush for SyntaxHilighter by thefox//aspekt 2013.

;(function()
{
    // CommonJS
    typeof(require) != 'undefined' ? SyntaxHighlighter = require('shCore').SyntaxHighlighter : null;

    function Brush()
    {
        var mnemonics = 'adc and asl bit clc cld cli clv cmp cpx cpy dec dex dey eor inc inx iny lda ldx ldy lsr nop ora pha php pla plp rol ror sbc sec sed sei sta stx sty tax tay tsx txa txs tya bpl bmi bvc bvs bcc bcs bne beq jmp jsr rts rti brk alr anc arr axs dcp isc las lax rla rra sax slo sre brl cop jml jsl mvn mvp pea pei per phb phd phk plb pld rep rtl sep stp tcd tcs tdc tsc txy tyx wai wdm xba xce bge blt cpa dea ina swa tad tas tda tsa bra phx phy plx ply stz trb tsb';

        var registers = 'a x y';
        
        this.regexList = [
                { regex: new RegExp(this.getKeywords(mnemonics), 'gmi'),        css: 'keyword' }, // Instruction mnemonics
                { regex: new RegExp(this.getKeywords(registers), 'gmi'),        css: 'keyword' }, // Registers
                { regex: SyntaxHighlighter.regexLib.doubleQuotedString,	        css: 'string' },
                { regex: SyntaxHighlighter.regexLib.singleQuotedString,	        css: 'string' },
                { regex: /;.*$/gm,                                              css: 'comments' },
                { regex: /\.\w+\b/gi,                                           css: 'color1' }, // Assembler directives
                { regex: /@\w+\b/gi,                                            css: 'color3' }, // Cheap labels
                { regex: /(\b[\d]+|\$[a-fA-F0-9_]+|\%[0-1_]+)\b/gi,             css: 'value' },  // Numbers
                ];
    };

    Brush.prototype = new SyntaxHighlighter.Highlighter();
    Brush.aliases   = ['6502', 'asm'];

    SyntaxHighlighter.brushes.Assembly6502 = Brush;

    // CommonJS
    typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();
