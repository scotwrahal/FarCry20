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

load_level
; start at 0 0
	lda #0
	sta $fc			; store the byte number
	ldx #0
load_row
	jsr	loadByte	; load the first byte to be loaded
	ldy #8			; the number of bits in the first byte
Byte1	
	asl $ff			; get the value for the next bit
	bcs	B11			; branch for terrain and ground
B10
	jsr drawTerrain		; 0 = terrain
	jmp B1next
B11						
	jsr drawGround		; 1 = ground
B1next
	clc
	inx				; increment the position
	dey
	bne	Byte1			; repeat till the byte is done
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_timers
	

play_loop
	jsr input
	jsr movePlayer
	;jsr beginTimer					; stalls for time to slow it down
	jmp play_loop
	
;;;;;;;;;;;;;;; SUBROUTINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadByte
	pha
	txa
	pha
	ldx	$fc				; load the byte number
	lda level1,x
	sta $ff
	txa
	adc #01
	cmp #67
	beq level_load_done		; load 66 bytes
	sta $fc				; store the next byte number
	pla
	tax
	pla
	rts

level_load_done
	pla
	tax
	pla
	jmp set_timers
	
	


	

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
	; FF: color code
	; FE: caracter code
draw
	pha
	cmp #0
	bne DrawBottom
	lda $fe
	sta	$1e00,x
	lda $ff
	sta $9600,x
	pla
	rts
DrawBottom
	lda $fe
	sta	$1f00,x
	lda $ff
	sta $9700,x
	pla
	rts

; drawTerrain
; A: top/bottom bit 0= top
; X: position
drawTerrain
	pha
	sta	holder
	tya
	pha
	lda	$ff
	pha
	lda	$fe
	pha
	ldy terrain_color
	sty $ff
	ldy terrain_char
	sty $fe
	lda holder
	jsr draw
	pla
	sta	$fe
	pla
	sta	$ff
	pla
	tay
	pla
	rts

; drawGround
; A: top/bottom bit 0= top
; X: position
drawGround
	pha
	sta holder
	lda	$ff
	pha
	lda	$fe
	pha
	lda ground_color
	sta $ff
	lda ground_char
	sta $fe
	lda holder
	jsr draw
	pla
	sta	$fe
	pla
	sta	$ff
	pla
	rts

; drawPlayer
drawPlayer
	pha
	txa
	pha
	tya
	pha
	lda	$ff
	pha
	lda	$fe
	pha
	ldy player_color
	sty $ff
	ldy player_char
	sty $fe
	ldy #1
	lda player_position,y
	tax
	lda player_position
	jsr draw
	pla
	sta	$fe
	pla
	sta	$ff
	pla
	tay
	pla
	tax
	pla
	rts

; input
; stores player in last_input
input
	pha
	lda $c5			; read scancode
Up
	cmp #9  		;'W' Scancode
	bne Down 					
	lda #$80
	jmp InputRetrun
Down
	cmp #41 		;'S' Scancode
	bne Left
	lda #$40
	jmp InputRetrun
Left
	cmp #17 		;'A' Scancode
	bne Right
	lda #$20
	jmp InputRetrun
Right	
	cmp #18 		;'D' Scancode
	bne Nothin
	lda #$10
	jmp InputRetrun
	; expand here for more input upto 4 with the same byte
Nothin
	lda #0
InputRetrun
	sta last_input
	pla
	rts
	
movePlayer
	pha
	tya
	pha
	ldy #1
	lda last_input 	;get the controls
	asl
	bcs MoveUp
	asl
	bcs MoveDown
	asl
	bcs	MoveLeft
	asl
	bcs MoveRight
	pla
	tay
	pla
	rts
	
; MoveUp is commented the others moves follow similar logic
MoveUp
	lda player_position,y	; load the location
	sec
	sbc #22					; move by one row
	bcc	MoveUpBorder		; check if you cross the upper lower border
	sta new_position,y		; if you didn't, store the new locaiton
	jmp FinishMove
MoveUpBorder
	lda player_position		; check if you are in the top or bottom
	beq	FinishMove			; if you are in the top then you cant move up
	lda #0					; you are now in the top
	sta new_position		; save in new positon
	lda player_position,y	
	sec
	sbc #22					; move up one row 
	sta new_position,y		; save in new position
	jmp FinishMove
	
MoveDown
	lda player_position,y
	clc
	adc #22
	bcs	MoveDownBorder
	sta new_position,y
	jmp FinishMove
MoveDownBorder
	lda player_position
	bne	FinishMove
	lda #1
	sta new_position
	lda player_position,y
	clc
	adc #22
	sta new_position,y
	jmp FinishMove
	
MoveLeft
	lda player_position,y
	sec
	sbc #1
	bcc MoveLeftBorder
	sta new_position,y
	jmp FinishMove
MoveLeftBorder
	lda player_position
	beq	FinishMove
	lda #0
	sta new_position
	lda #$ff
	sta new_position,y
	jmp FinishMove
	
MoveRight
	lda player_position,y
	clc
	adc #1
	bcs MoveRightBorder
	sta new_position,y
	jmp FinishMove
MoveRightBorder
	lda player_position
	bne	FinishMove
	lda #1
	sta new_position
	lda	#0
	sta new_position,y
	jmp FinishMove
	
FinishMove
	jsr check_player_collision
	cmp #0
	bne NoMove
	
	lda player_position,y
	tax 
	lda player_position
	jsr drawGround
	
	lda new_position
	sta player_position
	lda new_position,y
	sta player_position,y
	jsr drawPlayer
	
NoMove
	pla
	tay
	pla
	rts   

check_player_collision
	lda new_position
	ldx new_position,y
	jsr getFromPosition

	cmp ground_char
	beq NoCollide
	
	lda player_position
	sta new_position
	lda player_position,y
	sta new_position,y
	lda #1
	rts
	
NoCollide
	lda #0
	rts

	
; need to update so that the system is not stalled when waiting
beginTimer
	pha
	txa
	pha
	tya
	pha
	jsr $ffde	;read time from system clock and store in zero page
	;store time in zero page memory (high byte is omitted)
	sta $fb		;orig a = high

updateClock ;read time from clock and save it into 3 bytes
	pha
	txa
	pha
	tya
	pha
	jsr $ffde		;read time from system clock
	sta current_time_high
	stx current_time_middle
	sty current_time_low
	pla
	tay
	pla
	tax
	pla
	rts

	
;checkTime
;AXY: the time you want to check vs the current time
;return
;1 if the time passed in is less than or equal to the current time
checkTime
	sec
	sbc current_time_high			;subtract low byte of orig time from it
	tya
	sbc current_time_middle
	txa	
	sbc current_time_low
	rts          
	
current_time_high
	dc.b	$00     
current_time_middle
	dc.b	$00     
current_time_low
	dc.b	$05     

holder
	dc.b	$00

last_input       
	dc.b	$00     

new_position     
	dc.b	$00, $00 

;Player Variables
player_position  
	dc.b	$01, $00    
player_char      
	dc.b	$51
player_color     
	dc.b	$06 
player_clock_updates
	dc.b	$05
player_clock
	dc.b	$00, $00, $00

;Enviroment Variables
terrain_char
	dc.b	$66
terrain_color
	dc.b	$00

ground_char
	dc.b	$7f     
ground_color     
	dc.b	$05
	
level1
	dc.b	$00, $00, $00
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
	dc.b	$7f, $ff, $f8 
	dc.b	$7f, $ff, $f8 
	dc.b	$00, $00, $00 