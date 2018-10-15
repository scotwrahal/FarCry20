;sr_test3.asm
; changing the characters on the screen
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
	
	lda #255			; the location for the memory to be read from
	sta $9005			; change where the chracters are read
	ldx #0
	ldy #32				; 4 characters x 8 lines per character
	
load
	lda char,x			; load the characters into the right place in memory
	sta $1c00,x			; This is the location that will be read from
	inx
	dey
	bne load

	; from here it is just using other test program code to show it off 
	; except the data at the bottom
	
	lda #0				; fill character start
	ldx #0	
	
fill
	sta $1e00,x			; store in character of screen
	adc #1
	and #3				; only 4 characters
	inx
	bne fill
	
fill2
	sta $1f00,x			; continue filling screen
	tay					; register flipping for indexing with A and cmp with A
	txa
	cmp #$f9			; end of screen
	beq color			; start coloring if done
	tax
	tya
	clc
	adc #1				; increment the character to be written
	and #3
	inx
	bne fill2
	
color
	lda #0				; color select
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
	beq input			; check for release
	tax
	tya
	inx
	bne color_bottom
	
	
input ;scancodes found pg 179
	lda $00c5				; get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	jmp input
	
exit	
	brk
	
char:				; character 1 smiley
	dc.b 60
	dc.b 66
	dc.b 165
	dc.b 129
	dc.b 165
	dc.b 153
	dc.b 66
	dc.b 60
	
char2:				;character 2
	dc.b $c3
	dc.b $3c
	dc.b $c3
	dc.b $3c
	dc.b $c3
	dc.b $3c
	dc.b $c3
	dc.b $3c
	
char3:				;character 3
	dc.b $13
	dc.b $31
	dc.b $13
	dc.b $31
	dc.b $13
	dc.b $31
	dc.b $13
	dc.b $31
	
char4:				;character 4
	dc.b $69
	dc.b $96
	dc.b $69
	dc.b $96
	dc.b $69
	dc.b $96
	dc.b $69
	dc.b $96