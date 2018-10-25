;sr_test2.asm
; coloring the text on the screen
; 'A' cycle throught the colors
; 'Z' cycle the auxillary color
; 'Q' to quit
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
	
; the color loop is very similar to the fill loop except it writes to a
; diffrent area in memory
	lda #0				; initial color
	tax
	tay
	jmp color_top
	
increment
	iny
	tya
	ldx #0

color_top
	sta $9600,x			; store the color in A to the color buffer that is a bunch of nibbles
	inx					; advance to the next color space
	bne color_top

color_bottom
	sta $9700,x			; continue coloring
	tay					; register flipping for indexing with A and cmp with A
	txa
	cmp #$f9			; end of screen
	beq releaseA		; check for release
	tax
	tya
	inx
	bne color_bottom
	
	
; input for controlling the program
releaseZ
	lda $00c5			; get char pressed down
	cmp #33	;Z
	beq	releaseZ
	jmp input
	
releaseA
	lda $00c5			; get char pressed down
	cmp #17	;A
	beq	releaseA								
	
input ;scancodes found pg 179
	lda $00c5			; get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	cmp #17	;A (advance)
	beq	increment
	cmp #33 ;Z
	beq aux
	jmp input
	
aux 	
	lda $900e
	clc
	adc #$10
	sta $900e
	jmp releaseZ
	
exit
	brk