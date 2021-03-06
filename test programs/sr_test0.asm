;sr_test0.asm
; Allows the user to set the color of the screen and background 
; cycle thorugh using 'A'
; Press 'Q' to exit the program
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

	lda #00							;load 00 for the screen color
	sta $900f						;push to the screen color address
	
input
	lda $00c5						;get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	cmp #17	;A
	beq	increment					;until "A"
	cmp #34 ;C
	beq trippy
	jmp input

inc
	lda $900f
	clc
	adc #1							;increment the color
	sta $900f						;push to the screen color address
	rts
	
increment
	jsr inc
	
release
	lda $00c5						;get char pressed down
	cmp #17	;A
	beq	release							
	jmp input						
		
trippy
	jsr inc
	jmp input
	
exit
	lda #27
	sta $900f	
	brk								;end