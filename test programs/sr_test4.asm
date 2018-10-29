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
	
	lda	#50
	sta $ff
	lda #7
	sta $fe
	
	lda #0
	ldx #$ff
	jsr draw

	
input ;scancodes found pg 179
	lda $00c5				; get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	jmp input
exit
	brk

;draw
	; A: top/bottom location 0 = top
	; X: locaiton
	
	; FF: color code
	; FE: caracter code
draw
	cmp #0
	bne drawBottom
	lda $fe
	sta	#$1e00,x
	lda $ff
	sta $9600,x
	rts
drawBottom
	lda $fe
	sta	#$1f00,x
	lda $ff
	sta $9700,x
	rts