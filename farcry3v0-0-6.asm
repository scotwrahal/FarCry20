;farcry3
	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234	
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 in ascii (beginning of assembly code)
	dc.b 		0                   ;null terminator for SYS statement  
end_basic
	dc.w		0					;indicating end of BASIC stub	
	
load_colour
	lda #$dd						;$dd yields light green playfield, dark green border
	sta $900f						;load value into screen and border colour register (p. 175)
	
clear_screen ;may be a line short! 23 vertical bytes & only accounts for 22
	ldx #0				;set x,y coordinates to 0,0
	ldy #0
	clc					;indicate "set mode" for plot cursor position routine
	jsr $fff0			;call plot cursor position routine (p. 184)
clr_loop
	lda #32							;load ascii 'space' into Accumulator
	jsr $ffd2						;print
	inx
	cpx #242						;repeat 242 times (one half of screen)
	bne clr_loop
	ldx #0
	iny
	cpy #2							;repeat outer loop twice (top and bottom of screen)
	bne clr_loop
	;reset cursor position
	
load_level
	;load column 1
	ldx #0				;set x,y coordinates to 0,0
	ldy #0
	clc					;indicate "set mode" for plot cursor position routine
	jsr $fff0			;call plot cursor position routine (p. 184)
	ldx #0				;initialize inner loop counter to 0
	lda #0				;initialize column offset
	sta column_offset	
	lda #8
	sta horizontal_bit_max
	lda #1				;indicates column 1
	pha					;push column # to stack
	jsr load_column
	
	;load column 2
	ldx #0				;set x,y coordinates to 0,8
	ldy #8				;initialize y coordinate of cursor to 8
	clc					;indicate "set mode" for plot cursor position routine
	jsr $fff0			;call plot cursor position routine (p. 184)
	ldx #0
	lda #8
	sta column_offset
	lda #8
	sta horizontal_bit_max
	lda #2				;indicates column 2
	pha
	jsr load_column
	
	;load column 3
	ldx #0				;set x,y coordinates to 0,16
	ldy #16				;initialize y coordinate of cursor to 8
	clc					;indicate "set mode" for plot cursor position routine
	jsr $fff0			;call plot cursor position routine (p. 184)
	ldx #0
	lda #16
	sta column_offset
	lda #6
	sta horizontal_bit_max
	lda #3				;indicates column 3
	pha
	jsr load_column

;falls into an infinite loop after loading the map
inf
	jmp inf
	
	
;begin level load code
load_column
	lda #0							;inner loop runs 8 times
	sta $fb							;store 7 in zero page $fb
	pla
	sta return_address_low
	pla
	sta return_address_hi
	pla
	cmp #1
	beq load_level_column_one
	cmp #2
	beq load_level_column_two
	cmp #3
	beq load_level_column_three

shift_and_print
	lda $fc
	jsr shift_right_seven			;logical shift right by 7
	clc
	adc #48							;get ascii for 1 or 0
	jsr $ffd2						;print 1 or 0
	lda $fc							;load current byte from zero page
	asl								;arithmetic shift left accumulator
	sta $fc							;save current byte back into zero page
	lda $fb
	clc
	adc #1
	sta $fb
	cmp horizontal_bit_max							;perform shift "horizontal_bit_max" times
	bne shift_and_print
	ldy column_offset
	inx
	clc					;indicate "set mode" for plot cursor position routine
	jsr $fff0			;call plot cursor position routine (p. 184)
	txa
	cmp #22
	bne load_column
	
	rts
	
load_level_column_one
	lda l1col1,x					;load byte into a from l1col1 at index x
	sta $fc							;save byte in zero page $fc
	lda #1							;save which column again
	pha
	lda return_address_hi
	pha
	lda return_address_low
	pha
	jmp shift_and_print
	
load_level_column_two
	lda l1col2,x					;load byte into a from l1col1 at index x
	sta $fc							;save byte in zero page $fc
	lda #2							;save which column again
	pha
	lda return_address_hi
	pha
	lda return_address_low
	pha
	jmp shift_and_print
	
load_level_column_three
	lda l1col3,x					;load byte into a from l1col1 at index x
	sta $fc							;save byte in zero page $fc
	lda #3							;save which column again
	pha
	lda return_address_hi
	pha
	lda return_address_low
	pha
	jmp shift_and_print
	
shift_right_seven
	lsr
	lsr 
	lsr 
	lsr 
	lsr 
	lsr 
	lsr 
	rts
	
l1col1:
	dc.b $ff,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$ff
l1col2:
	dc.b $ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff
l1col3:
	dc.b $fc,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$fc
column_offset:
	dc.b
return_address_low:
	dc.b
return_address_hi:
	dc.b
horizontal_bit_max:
	dc.b