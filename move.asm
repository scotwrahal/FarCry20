moveEntity
    pha
    jsr checkClock          ; check if you are ready to update
    cmp #0
    beq EndOfEntityMove
    jsr move
EndOfEntityMove
    pla
    rts
    
moveBullet
    clc
    adc bullet_offset
    jsr moveEntity
    ldy direction_offset
    lda #1
    ora ($fe),y
    sta ($fe),y
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
    bcc MoveUpBorder        ; check if you cross the upper lower border
    sta new_position,y      ; if you didn't, store the new locaiton
    jmp FinishMove
MoveUpBorder
    lda new_position
    beq NoMoveUp            ; if you are in the top then you cant move up
    lda #0                  ; you are now in the top
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
    ;change to a draw_on function
    jsr drawGround          ; draw the ground in the old position
    ldy #1                  ; move the new position to the entity position and set up for draw
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