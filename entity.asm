; TODO make a list of functions
updateEntity
    pha
    tya
    pha
    jsr moveEntity
    jsr check_collision
    cmp #1
    bne NoCollide
    jsr invertDirection
    ldy direction_offset
    lda ($fe),y
    ora #$01
    sta ($fe),y
    jsr move
    jsr invertDirection
    
NoCollide
    jsr drawEntity
    pla
    tay
    pla
    rts
    
setClockEntity
    lda clock
    ldy clock_offset
    sta ($fe),y    
    rts
   
loadEntity
    clc 
    adc entity_offset
    jmp loadDrawable
    
moveEntity
    jsr checkClock          ; check if ready to update
    cmp #0
    beq EndOfEntityMove
    jsr move
EndOfEntityMove
    rts
    
drawEntity
    pha
    txa                  
    pha
    tya
    pha
    ldy position_offset
    iny
    lda ($fe),y 
    tax
    dey 
    lda ($fe),y 
    jsr draw
    pla
    tay
    pla
    tax
    pla
    rts
    
animateEntity
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

; moves an updatable entity based on the direction they are moving and if the low bit is set
;   A index of the updatable entity to be moved
move
    sta holder
    pha
    txa
    pha
    tya
    pha
    lda holder

    ldy position_offset
    ; transfer the old position to the new position variable
    lda ($fe),y             ; load the location
    sta new_position
    iny
    ldx #1
    lda ($fe),y
    sta new_position,x

    ldy direction_offset
    lda ($fe),y             ; load the direction into A
    lsr
    bcc noMove
    asl
    sta ($fe),y             ; update the direction to say that it has been moved
    ldy #1                  ; load 1 for the low position, 0 is the high used in the move
    asl                     ; shift through the bits to get the direction
    bcs MoveUp
    asl
    bcs MoveDown
    asl
    bcs MoveLeft
    asl
    bcs MoveRight
noMove
    jmp EndMove             ; if there is no direction then it doesn't move
; MoveUp is commented the others moves follow similar logic
MoveUp
    lda new_position,y
    sec
    sbc #22                 ; move by one row
    bcc MoveUpBorder        ; check the upper lower border
    sta new_position,y      ; if  didn't, store the new locaiton
    jmp FinishMove
MoveUpBorder
    lda new_position
    beq NoMoveUp            ; in the top cant move up
    lda #0                  ; now in the top
    sta new_position        ; save in new positon
    lda new_position,y
    sec
    sbc #22                 ; move up one row
    sta new_position,y      ; save new position
NoMoveUp
    jmp FinishMove
MoveDown
    lda new_position,y
    clc
    adc #22
    bcs MoveDownBorder
    sta new_position,y
    jmp FinishMove
MoveDownBorder
    lda new_position
    bne NoMoveDown
    lda #1
    sta new_position
    lda new_position,y
    clc
    adc #22
    sta new_position,y
NoMoveDown
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
    beq NoMoveLeft
    lda #0
    sta new_position
    lda #$ff
    sta new_position,y
NoMoveLeft
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
    bne NoMoveRight
    lda #1
    sta new_position
    lda #0
    sta new_position,y
NoMoveRight
FinishMove
    ldy position_offset     ; load in the old position
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    jsr drawOn              ; draw the ground in the old position
    
    
    ldy #1                  ; move the new position to the entity position and set up for draw
    lda new_position,y
    tax
    lda new_position
    jsr getFromPosition
    ldy on_char_offset
    sta ($fe),y
    txa
    ldy on_color_offset
    sta ($fe),y   
    
    ldy #1
    lda new_position,y
    ldy position_offset
    iny
    sta ($fe),y
    tax
    dey
    lda new_position
    sta ($fe),y
EndMove
    pla
    tay
    pla
    tax
    pla
    rts
    
drawOn
    pha
    tya
    pha
    txa
    pha
    
    ldy on_char_offset
    lda ($fe),y
    sta on_char
    ldy on_color_offset
    lda ($fe),y
    sta on_color
    
    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y

    ldy on_holder_offset
    jsr drawDrawable
    pla
    tax
    pla
    tay
    pla    
    rts
    
; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
check_collision
    tya
    pha
    ldy on_char_offset
    lda ($fe),y
    cmp terrain_char
    beq Collide
    pla
    tay
    lda #0
    rts
Collide
    pla
    tay
    lda #1
    rts
    
; inverts the direction of the entity
invertDirection
    pha
    tya
    pha
    ldy direction_offset
    lda ($fe),y
    sta holder
    asl
    bcs FlipUD
    asl
    bcs FlipUD
FlipLR
    lda ($fe),y
    eor #$30
    jmp EndFlip
FlipUD
    lda ($fe),y
    eor #$c0
EndFlip
    sta ($fe),y
    pla
    tay
    pla
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