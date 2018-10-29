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
	
set_volume 
	lda #0			;initialize song note index
	sta note_index
	lda #$0f		;load 15 (max volume) into Accumulator
	sta $900e		;set max volume
	
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
	
	jsr begintimer1
	
play_loop
	jsr begintimer
	jsr readclock1
after
	jsr Input
	cmp #0
	beq play_loop
	jsr MovePlayer
	jmp play_loop

Input
	lda $c5		; read scancode
Up
	cmp #9  		;'W' Scancode
	bne Down 					
	lda #0
	clc
	adc #$80
	jmp Input_retrun
Down
	cmp #41 		;'S' Scancode
	bne Left
	lda #0
	clc
	adc #$40
	jmp Input_retrun
Left
	cmp #17 		;'A' Scancode
	bne Right
	lda #0
	clc
	adc #$20
	jmp Input_retrun
Right	
	cmp #18 		;'D' Scancode
	bne nothing
	lda #0
	clc
	adc #$10
	jmp Input_retrun
	; expand here for more input upto 4 with the same byte
nothing
	lda #0
Input_retrun
	sta lastInput
	rts
	
MovePlayer
	ldy #1
	jsr clear_old_pos
	lda lastInput 	;get the controls
	asl
	bcs MoveUp
	asl
	bcs MoveDown
	asl
	bcs	MoveLeft
	asl
	bcs MoveRight
	rts
	
	;This is commented the others follow similar logic
MoveUp
	lda p_pos,y			; load the location
	sec
	sbc #22				; move by one row
	bcc	MoveUpBorder	; check if you cross the upper lower border
	sta p_new_pos,y		; if you didn't store the new locaiton
	jmp FinishMove
MoveUpBorder
	lda p_pos			; check if you are in the top or bottom
	beq	FinishMove		; if you are in the top then you cant move up
	lda #0				; you are now in the top
	sta p_new_pos		
	lda p_pos,y
	sec
	sbc #22				; move up one row 
	sta p_new_pos,y
	jmp FinishMove
	
MoveDown
	lda p_pos,y
	clc
	adc #22
	bcs	MoveDownBorder
	sta p_new_pos,y
	jmp FinishMove
MoveDownBorder
	lda p_pos
	bne	FinishMove
	lda #1
	sta p_new_pos
	lda p_pos,y
	clc
	adc #22
	sta p_new_pos,y
	jmp FinishMove
	
MoveLeft
	lda p_pos,y
	sec
	sbc #1
	bcc MoveLeftBorder
	sta p_new_pos,y
	jmp FinishMove
MoveLeftBorder
	lda p_pos
	beq	FinishMove
	lda #0
	sta p_new_pos
	lda #$ff
	sta p_new_pos,y
	jmp FinishMove
	
MoveRight
	lda p_pos,y
	clc
	adc #1
	bcs MoveRightBorder
	sta p_new_pos,y
	jmp FinishMove
MoveRightBorder
	lda p_pos
	bne	FinishMove
	lda #1
	sta p_new_pos
	lda	#0
	sta p_new_pos,y
	jmp FinishMove
	
FinishMove
	jsr check_collision
	jsr draw_pos
	rts

check_collision
	lda p_new_pos
	bne CollideBottom
	ldx p_new_pos,y
	lda	#$1e00,x
	cmp #32;space
	beq no_collide
	cmp #48;0
	beq no_collide
	jmp collide
	
CollideBottom
	ldx p_new_pos,y
	lda	#$1f00,x
	cmp #32
	beq no_collide
	cmp #48;0
	beq no_collide
	jmp collide
	
collide
	lda p_pos
	sta p_new_pos
	lda p_pos,y
	sta p_new_pos,y
	rts

no_collide
	lda p_new_pos
	sta p_pos
	lda p_new_pos,y
	sta p_pos,y
	rts
	
clear_old_pos
	lda p_pos
	bne bottom
	ldx p_pos,y
	lda #32
	sta	#$1e00,x
	rts
bottom
	ldx p_pos,y
	lda #32
	sta	#$1f00,x
	rts
	
draw_pos
	lda p_pos
	bne newbottom
	ldx p_pos,y
	lda #50			;charcode for 2
	sta	#$1e00,x
	rts
newbottom
	ldx p_pos,y
	lda #50
	sta	#$1f00,x
	rts	
	
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
	
begintimer
	jsr $ffde	;read time from system clock and store in zero page
	;store time in zero page memory (high byte is omitted)
	sta $fb		;orig a = low
	stx $fc		;orig x = middle
	sty $fd		;orig y = hi
	
readclock ;read time from clock and save it into 3 bytes
	jsr $ffde	;read time from system clock
	
subtraction		;perform subtraction and store somewhere
	sta $fe		;save new A to zero page
	tya			;transfer high byte of new time (Y) into accumulator
	sbc $fd		;subtract original high byte value
	sbc conshi		;subtract high byte of constant
	bcc readclock	;if negative, get time and start again
	txa			;transfer middle byte of new time into accumulator
	sbc $fc		;subtract original middle byte value
	sbc consmid		;subtract middle byte of constant
	bcc readclock	;if negative, get time and start again
	lda $fe		;load low byte of new value back into accumulator
	sbc $fb		;subtract low byte of orig time from it
	sbc conslow ;subtract low byte of constant
	bcc readclock	;if negative, get time and start again
	rts
	
begintimer1
	jsr $ffde	;read time from system clock and store in zero page
	;store time in zero page memory (high byte is omitted)
	sta orig_low		;orig a = low
	stx orig_mid		;orig x = middle
	sty orig_hi		;orig y = hi
	
readclock1 ;read time from clock and save it into 3 bytes
	jsr $ffde	;read time from system clock
	
subtraction1		;perform subtraction and store somewhere
	pha			;push new A to stack
	tya			;transfer high byte of new time (Y) into accumulator
	sbc orig_hi		;subtract original high byte value
	sbc conshi1		;subtract high byte of constant
	bcc no_good	;if negative, get time and start again
	txa			;transfer middle byte of new time into accumulator
	sbc orig_mid		;subtract original middle byte value
	sbc consmid1	;subtract middle byte of constant
	bcc no_good ;if negative, get time and start again
	pla		;load low byte of new value back into accumulator from stack
	sbc orig_low		;subtract low byte of orig time from it
	sbc conslow1 ;subtract low byte of constant
	bcc no_good	;if negative, get time and start again
	
timeout1
	ldx note_index
	lda the_song,x
	sta $900a		;play note
	inx				;increment note index
	stx note_index
	lda note_index
	sbc #8
	beq reset_song1
	jsr begintimer1					;get new original time
	
reset_song1
	lda #0
	sta note_index
	jsr begintimer1

no_good 
	jsr after
	
conshi:				;high byte of constant timer value
	dc.b $00
consmid:			;middle byte of constant timer value
	dc.b $00
conslow:			;low byte of constant timer value
	dc.b $05
	
l1col1:
	dc.b $ff,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$8f,$80,$80,$80,$80,$80,$80,$80,$80,$ff
l1col2:
	dc.b $ff,$00,$00,$0f,$10,$10,$10,$10,$10,$10,$10,$0f,$00,$00,$00,$0f,$00,$00,$00,$00,$00,$ff
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

p_new_pos
	dc.b $00,$00
	
p_pos
	dc.b $00,$20
	
lastInput
	dc.b $00
	
conshi1:				;high byte of constant timer value
	dc.b $00
consmid1:			;middle byte of constant timer value
	dc.b $00
conslow1:			;low byte of constant timer value
	dc.b $1e
	;$1e = 30 = 0.5 seconds
the_song:
	dc.b #167,#159,#228,#219,#215,#231,#228,#191
orig_low:
	dc.b
orig_mid:
	dc.b
orig_hi:
	dc.b
note_index:
	dc.b