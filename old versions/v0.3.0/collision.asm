; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
check_collision
    pha
    tya
    pha
    lda new_position
    ldy #1
    ldx new_position,y
    jsr getFromPosition     ; gets the character on the screen in the new position
    ; need to make a collide list maybe
    cmp ground_char
    beq NoCollide
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

animate
	pla
	sta return_add_hi
	pla
	sta return_add_low
	pla
	sta num_frames
	pla
	sta graphic_offset
	lda jason_animation_state
	adc graphic_offset
	sta player_char				;assign new image
	sbc graphic_offset						;remove offset
	ldx num_frames
	cmp num_frames						
	bne StoreNoReset
	sbc #1
	sbc num_frames
StoreNoReset
	adc #1
	sta jason_animation_state
	lda return_add_low
	pha
	lda return_add_hi
	pha
	rts
	
; getFromPosition returns the color and the character at a locaiton on the screen
;   A: top/bottom location 0 ; = top
;   X: location
;   return
;   A: character
;   X: color
getFromPosition
    cmp #0
    bne readBottom
    lda $1e00,x
    pha
    lda $9600,x
    tax
    pla
    rts
readBottom
    lda $1f00,x
    pha
    lda $9700,x
    tax
    pla
    rts