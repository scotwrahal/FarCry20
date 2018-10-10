;sr_test0.asm
	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234
	
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 in ascii
	dc.b 		0                   ;null terminator for SYS statement  

end_basic
	dc.w		0					;indicating end of BASIC stub
	
	;;;;;;;;;;;;;;;;;;;;The start of assembly;;;;;;;;;;;;;;;;;;;;;;;;;
	
	lda #0					;fill character
	ldx #0
fill
	sta $1e00,x				;store in character of screen
	clc
	adc #1					;increment the character to be written
	inx
	bne fill

fill2
	sta $1f00,x				;continue filling screen
	tay
	txa
	cmp #$f9				;end of screen
	beq color				;start coloring if done
	tax
	tya
	clc
	adc #1					;increment the character to be written
	inx
	bne fill2
	
; the color loop is very similar to the fill loop except it writes to a
; diffrent area in memory
color
	lda #0
	ldx #0
	tay
	jmp color_top
	
increment
	iny
	tya
	ldx #0

color_top
	sta $9600,x
	inx
	bne color_top

color_bottom
	sta $9700,x
	tay
	txa
	cmp #$f9		;end of screen
	beq release
	tax
	tya
	inx
	bne color_bottom
	
	
; input for the user to control the program
release
	lda $00c5						;get char pressed down
	cmp #17	;A
	beq	release							
	jmp input		
	
input
	lda $00c5						;get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	cmp #17	;A (advance)
	beq	increment					;until "A"
	jmp input
	
exit
	brk								;end
	
	
	;aux color 36878