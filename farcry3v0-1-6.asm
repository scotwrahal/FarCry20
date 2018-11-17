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

start:
	lda #255	;point to custom character set
	sta $9005
load_8x8:
	ldx #0					;index of bitmap line
write_byte_line:
	lda jason_right0,x		;load line from offset of first bitmap
	sta $1c08,x
	inx
	txa
	sbc #39					;*(8*(number of bitmaps) - 1)
	bne write_byte_line		;loop until all bitmaps loaded into custom char memory

load_colour
	lda #$dd						;$dd yields light green playfield, dark green border
	sta $900f						;load value into screen and border colour register (p. 175)
	
	lda #2							; this will select what level you want loaded
	jsr load_level
	
set_timers
	jsr updateClock
	; for all updatable entities make their clock the current clock
	lda clock
	sta player_clock
	
play_loop
	jsr updateClock
	jsr input		
	jsr movePlayer
	jmp play_loop
	
; $fc tracks the byte
; $ff tracks current bit
; $fd fe will store the level address
load_level
	sta holder
	pha
	txa
	pha
	tya
	pha
	lda $fc
	pha
	lda $ff
	pha
	lda holder
	
	
	
	asl 				; multiply by 2	
	tay
	lda level_mem,y
	sta $fd
	iny
	lda level_mem,y
	sta $fe
	
; start at 0 0
	lda #0
	sta $fc				; store the byte number
	ldx #0
load_row
	; check if you are done
	pha
	lda $fc
	cmp #66					; check if you have loaded 66 bytes
	beq level_load_done
	pla
	
	jsr	loadByte	; load the first byte of the row
	
	ldy #8			; the number of bits in the first byte
Byte1	
	asl $ff			; get the value for the next bit
	bcs	B11			; branch for terrain and ground
B10
	jsr drawTerrain	; 0 = terrain
	jmp B1next
B11						
	jsr drawGround	; 1 = ground
B1next
	clc
	inx				; increment the position
	dey
	bne	Byte1		; repeat till the byte is done
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jsr	loadByte
	ldy	#8
Byte2
	asl $ff
	bcs	B21
B20
	jsr drawTerrain
	jmp B2next
B21
	jsr drawGround
B2next
	clc
	inx				; increment the position
	bne	B2skip		; boundery happens on a b2 so need to check that
	lda #1
B2skip	
	dey
	bne	Byte2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	jsr	loadByte
	ldy #6
Byte3
	asl $ff
	bcs	B31
B30
	jsr drawTerrain
	jmp B3next
B31
	jsr drawGround
B3next
	clc
	inx
	dey
	bne	Byte3
	jmp load_row
	
	
level_load_done
	pla			; extra pull for preserving the position
	
	pla
	sta $ff
	pla 
	sta $fc 
	pla 
	tay
	pla
	tax
	pla
	rts
	
;;;;;;;;;;;;;;; SUBROUTINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadByte
	pha
	tya
	pha
	ldy	$fc				; load the byte number
	lda ($fd),y
	sta $ff
	iny 
	sty $fc
	pla
	tay
	pla
	rts
	
movePlayer
	pha
	tya
	pha
	lda $fe
	pha
	lda $ff
	pha
; check your time
	ldy #1
	lda updatable_entity_mem		; Player is the First updatable entity
	sta $fe
	lda updatable_entity_mem,y
	sta $ff
	
	jsr checkClock
	cmp #0
	beq	EndOfPlayerMove
	
	jsr move
	
EndOfPlayerMove
	pla
	sta $ff
	pla 
	sta $fe
	pla
	tay
	pla
	rts

	
;	fe ff: memorylocation of entity to be checked
;	returns 1 if the clock updated
checkClock
	pha
	tya
	pha
	ldy clock_offset
	lda ($fe),y
	sec
	cmp clock
	bcc CheckForLoop	; if the carry is set you dont update ie. gameclock is less than entity clock
NoClock
	pla					
	tay
	pla
	lda	#0
	rts
CheckForLoop			; if the gameclock is larger than the entity clock may need to update
	iny	
	clc
	adc ($fe),y
	bcs UpdateEntityClock
	sec
	cmp clock			; if the new time is also past the clock you are looped?? possibly not if it is slow?
	bcc NoClock
UpdateEntityClock
	dey
	sta	($fe),y
	pla
	tay
	pla
	lda	#1
	rts
	
;move
;	A: direction
;	fe ff: memorylocation of entity to be moved
move
	pha
	txa
	pha
	tya	
	pha
	ldy position_offset			; this is the offest for the position in the structure
	
	; transfer the old position to the new position
	lda ($fe),y					; load the location
	sta new_position
	iny 
	ldx #1
	lda ($fe),y
	sta new_position,x
	
	iny
	lda ($fe),y					; load the direction into A
	lsr
	bcc noMove
	asl
	sta ($fe),y
	
	ldy #1
	
	asl
	bcs MoveUp
	asl
	bcs MoveDown
	asl
	bcs	MoveLeft
	asl
	bcs MoveRight
noMove
	jmp EndMove				; if there is no direction then it doesn't move
	
; MoveUp is commented the others moves follow similar logic
MoveUp
	lda new_position,y
	sec
	sbc #22					; move by one row
	bcc	MoveUpBorder		; check if you cross the upper lower border
	sta new_position,y		; if you didn't, store the new locaiton
	jmp FinishMove
MoveUpBorder
	lda new_position
	beq	FinishMove			; if you are in the top then you cant move up
	lda #0					; you are now in the top
	sta new_position		; save in new positon
	lda new_position,y
	sec
	sbc #22					; move up one row 
	sta new_position,y		; save new position
	jmp FinishMove
	
MoveDown
	lda new_position,y
	clc
	adc #22
	bcs	MoveDownBorder
	sta new_position,y
	jmp FinishMove
MoveDownBorder
	lda new_position
	bne	FinishMove
	lda #1
	sta new_position
	lda new_position,y
	clc
	adc #22
	sta new_position,y
	jmp FinishMove
	
MoveLeft
	lda new_position,y
	sec
	sbc #1
	bcc MoveLeftBorder
	sta new_position,y
	jmp FinishMove
MoveLeftBorder
	lda new_position
	beq	FinishMove
	lda #0
	sta new_position
	lda #$ff
	sta new_position,y
	jmp FinishMove
	
MoveRight
	lda new_position,y
	clc
	adc #1
	bcs MoveRightBorder
	sta new_position,y
	jmp FinishMove
MoveRightBorder
	lda new_position
	bne	FinishMove
	lda #1
	sta new_position
	lda	#0
	sta new_position,y
	jmp FinishMove
	
FinishMove
	jsr check_collision

	cmp #0
	bne Collision
	
	ldy position_offset
	iny
	lda ($fe),y
	tax
	dey
	lda ($fe),y
	jsr	drawGround
	
	
	ldy #1
	lda new_position,y
	ldy position_offset
	iny
	sta ($fe),y
	tax
	dey
	lda new_position
	sta ($fe),y
	jsr draw

Collision

EndMove
	pla
	tay
	pla
	tax
	pla
	rts


check_collision
	pha
	tya
	pha
	lda new_position
	ldy #1
	ldx new_position,y
	jsr getFromPosition
	; need to make a collide list maybe
	cmp ground_char
	beq NoCollide
	ldy position_offset
	lda ($fe),y
	sta new_position
	iny
	lda ($fe),y
	ldy #1
	sta new_position,y
	pla
	tay
	pla
	lda #1
	rts
NoCollide
	pla
	tay
	pla
	lda #0
	rts
	
;getFromPosition
	; A: top/bottom location 0 = top
	; X: location
	; return
	; A: character
	; X: color
getFromPosition
	cmp #0
	bne readBottom
	lda	$1e00,x
	pha
	lda $9600,x
	tax
	pla
	rts
readBottom
	lda	$1f00,x
	pha
	lda $9700,x
	tax
	pla
	rts
	
;draw
	; A: top/bottom location 0 = top
	; X: location
	; $fe $ff: entity to draw 
draw
	sta holder			; clear accumulator to store state
	pha
	tya
	pha
	lda holder
	cmp #0
	bne DrawBottom
	ldy #0				; this is the index for the character
	lda ($fe),y
	sta	$1e00,x
	ldy #1				; this is the index for the color
	lda ($fe),y
	sta $9600,x
	jmp	EndDraw

DrawBottom
	ldy #0
	lda ($fe),y
	sta	$1f00,x
	ldy #1
	lda ($fe),y
	sta $9700,x
EndDraw
	pla 
	tay
	pla
	rts

; drawTerrain
; A: top/bottom bit 0= top
; X: position
drawTerrain
	sta holder
	pha
	tya
	pha
	ldy #0
	lda holder
	jsr drawDrawable
	pla
	tay
	pla
	rts
	
; drawGround
; A: top/bottom bit 0= top
; X: position	
drawGround
	sta holder
	pha
	tya
	pha
	ldy #1
	lda holder
	jsr drawDrawable
	pla
	tay
	pla
	rts

; drawTerrain
; A: top/bottom bit 0= top
; X: position
; Y: index
drawDrawable
	sta holder
	pha
	lda	$ff
	pha
	lda	$fe
	pha
	tya
	pha
	asl
	tay					;multiply by 2
	lda drawable_mem,y
	sta $fe
	iny
	lda	drawable_mem,y
	sta $ff
	lda holder
	jsr draw
	pla
	tay
	pla
	sta	$fe
	pla
	sta	$ff
	pla
	rts
	
; input
; 
input
	pha
	lda $c5			; read scancode
Up
	cmp #9  		;'W' Scancode
	bne Down 					
	lda #$81
	jmp InputRetrun
Down
	cmp #41 		;'S' Scancode
	bne Left
	lda #$41
	jmp InputRetrun
Left
	cmp #17 		;'A' Scancode
	bne Right
	lda #$21
	jmp InputRetrun
Right	
	cmp #18 		;'D' Scancode
	bne nothin
	lda #$11
	jmp InputRetrun
	; expand here for more input upto 3 with the same byte
nothin
	lda player_direction
InputRetrun
	sta player_direction
	pla
	rts
	
updateClock
	pha
	tya
	pha
	txa
	pha
	jsr $ffde		;read time from system clock and store in zero page
	sta clock		;orig a = low
	pla 
	tax
	pla
	tay
	pla
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;DATA;;;;;;;;;;;;;;;;;;;;;;

holder
	dc.b	$00
	
last_input       
	dc.b	$00     

new_position     
	dc.b	$00, $00 

;updatable variables
clock
	dc.b	$00

position_offset
	dc.b	$02
clock_offset
	dc.b	$05

updatable_entity_mem
	dc.w 	player_char
	dc.w	$0000
	
player_char      
	dc.b	#01
player_color     
	dc.b	$06
player_position
	dc.b	$00, $22
player_direction
	dc.b	$00
player_clock
	dc.b	$00
player_clock_updates
	dc.b	$04

; drawable Variables
; be careful if you switch the order it will things up 
; add to the end of the list
drawable_mem
	dc.w	terrain_char
	dc.w	ground_char
	dc.w 	player_char
	dc.w	up_char
	dc.w	down_char
	dc.w	left_char
	dc.w	right_char
	dc.w	$0000
	
terrain_char
	dc.b	#03
terrain_color
	dc.b	$00

ground_char
	dc.b	#05
ground_color
	dc.b	$05
	
up_char
	dc.b	$71
up_color
	dc.b	$05

down_char
	dc.b	$72
down_color
	dc.b	$05

left_char
	dc.b	$73
left_color
	dc.b	$05

right_char
	dc.b	$74
right_color
	dc.b	$05

jason_right0:	
	dc.b $18, $18, $13, $3e, $58, $18, $34, $46
jaguar_right0:
	dc.b $02, $43, $43, $9e, $7f, $66, $62, $a1
palm_tree0:
	dc.b $1a, $7c, $b2, $28, $48, $08, $0c, $1f
shrub0:
	dc.b $0a, $4c, $28, $1d, $2a, $1c, $08, $1c
shrub1:
	dc.b $28, $2a, $ac, $a9, $99, $5a, $3c, $1c, $1c
	
;Level memory
level_mem
	dc.w	level0
	dc.w	level1
	dc.w	level2
	dc.w	$0000

level0
	dc.b	$00, $00, $00
	dc.b	$7f, $aa, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$75, $55, $58 
	dc.b	$00, $00, $00 

	
level1
	dc.b	$00, $00, $00
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$00, $00, $00

level2
	dc.b	$00, $00, $00
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $f0, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$00, $00, $00
