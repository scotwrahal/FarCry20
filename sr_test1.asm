;sr_test1.asm
; filling the screen with characters 
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
	
	lda #0					; fill character
	ldx #0
fill
	sta $1e00,x				; store in character of screen
	clc
	adc #1					; increment the character to be written
	inx
	bne fill
	

fill2
	sta $1f00,x				; continue filling screen
	tay						; register flipping for indexing with A and cmp with A
	txa
	cmp #$f9				; end of screen
	beq input				;start coloring if done
	tax
	tya
	clc
	adc #1					; increment the character to be written
	inx
	bne fill2
	
input ;scancodes found pg 179
	lda $00c5				; get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	jmp input
	
exit
	brk								;end