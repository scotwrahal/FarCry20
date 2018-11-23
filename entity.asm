; TODO make a list of functions

setEntityClocks
    ldx #0              ; index
SetEntityClocks
    txa
    asl                 ; multiply by 2 because they are addresses
    jsr loadEntity
    lda $ff             ; load the page number of the entity
    cmp #0              ; no entitys are on pg 0
    beq EntityClocksSet ; so break out of the loop
    jsr setClock        ; sets the entity clock to the current clock
    inx                 ; increase the index
    jmp SetEntityClocks
EntityClocksSet
    rts

updateEntities
    ldx #0
UpdateEntity
    txa
    asl
    jsr loadEntity
    lda $ff
    cmp #0
    beq EntitiesUpdated
    jsr updateEntity
    inx
    jmp UpdateEntity
EntitiesUpdated
    rts

updateEntity
    pha
    tya
    pha
    txa
    pha
    jsr checkClock
    cmp #0
    beq NoTimeBasedUpdates
    jsr move
    jsr checkCollision
    jsr handleCollision
NoTimeBasedUpdates
    jsr drawEntity
    pla
    tax
    pla
    tay
    pla
    rts

setClock
    lda clock
    clc
    adc #1
    ldy clock_offset
    sta ($fe),y
    rts

loadEntity
    clc
    adc entity_offset
    jmp loadDrawable

loadEntity2
    tay
    lda entities,y
    sta $fc
    iny
    lda entities,y
    sta $fd
    rts

drawEntity
    pha
    txa
    pha
    tya
    pha
    ldy state_offset
    lda ($fe),y
    asl
    asl
    pha
    jsr getDirection
    sta holder
    pla
    clc
    adc holder
    sta holder
    pha
    ldy char_offset
    lda ($fe),y
    clc
    adc holder
    sta ($fe),y
    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    jsr draw
    pla
    sta holder
    ldy char_offset
    lda ($fe),y
    sec
    sbc holder
    sta ($fe),y
    pla
    tay
    pla
    tax
    pla
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

    ldy direction_offset
    lda ($fe),y             ; load the direction into A
    lsr
    php
    asl
    sta ($fe),y
    plp
    bcc noMove
    
    ldy position_offset     ; load in the old position
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    jsr drawOn              ; draw the thing you were on in the old position

;update the state
    ldy state_offset
    lda ($fe),y
    clc
    adc #1
    sta holder
    ldy max_state_offset
    lda ($fe),y
    cmp holder
    bne skip
    lda #0
    jmp restore
skip
    lda holder
restore
    ldy state_offset
    sta ($fe),y

    ldy direction_offset
    lda ($fe),y
    asl                     ; shift through the bits to get the direction
    bcs EntitymoveUp
    asl
    bcs EntitymoveDown
    asl
    bcs EntitymoveLeft
    asl
    bcs EntitymoveRight
noMove
; set to the idle state 
    lda #0
    ldy state_offset
    sta ($fe),y
    jmp EndMove             ; if there is no direction then it doesn't move
    
    
EntitymoveUp
    jsr moveUp
    jmp FinishMove
    
EntitymoveDown
    jsr moveDown
    jmp FinishMove
    
EntitymoveLeft
    jsr moveLeft
    jmp FinishMove
    
EntitymoveRight
    jsr moveRight
    jmp FinishMove

    
; moveUp is commented the others moves follow similar logic
moveUp
    ldy position_offset
    iny
    lda ($fe),y
    sec
    sbc #22                 ; move by one row
    bcc MoveUpBorder        ; check the upper lower border
    sta ($fe),y             ; if  didn't, store the new locaiton
    dey 
    lda ($fe),y
    sec
    sbc #1                  ; decrement the row
    sta ($fe),y
    rts
MoveUpBorder
    ldy position_offset
    lda ($fe),y
    and #$80                ; only use the top bit
    beq NoMoveUp            ; in the top cant move up
    lda ($fe),y
    and #$7f                ; clear top bit
    sec
    sbc #1                  ; decrement the row
    sta ($fe),y             ; save the new position
    iny
    lda ($fe),y
    sec
    sbc #22                 ; move up one row
    sta ($fe),y             ; save new position
NoMoveUp
    rts
    
moveDown
    ldy position_offset
    iny
    lda ($fe),y
    clc
    adc #22
    bcs MoveDownBorder
    sta ($fe),y
    dey 
    lda ($fe),y
    clc
    adc #1                  ; increment the row
    sta ($fe),y
    rts
MoveDownBorder
    ldy position_offset
    lda ($fe),y
    and #$80
    bne NoMoveDown
    lda ($fe),y
    ora #$80                ; set the position
    clc
    adc #1                  ; increment the row
    sta ($fe),y
    iny
    lda ($fe),y
    clc
    adc #22
    sta ($fe),y
NoMoveDown
    rts
    
moveLeft
    ldy position_offset
    iny
    lda ($fe),y
    sec
    sbc #1
    bcc MoveLeftBorder
    sta ($fe),y
    rts

MoveLeftBorder
    ldy position_offset
    lda ($fe),y
    and #$80
    beq NoMoveLeft
    lda #0
    sta ($fe),y
    iny
    lda #$ff
    sta ($fe),y
NoMoveLeft
    rts
    
moveRight
    ldy position_offset
    iny
    lda ($fe),y
    clc
    adc #1
    bcs MoveRightBorder
    sta ($fe),y
    rts
MoveRightBorder
    ldy position_offset
    lda ($fe),y
    and #$80
    bne NoMoveRight
    lda #1
    sta ($fe),y
    iny
    lda #0
    sta ($fe),y
NoMoveRight
    rts

FinishMove
    ldy position_offset
    iny                         ; store the thing you are now standing on
    lda ($fe),y
    dey
    tax
    lda ($fe),y
    jsr getFromPosition
    ldy on_char_offset
    sta ($fe),y
    txa
    ldy on_color_offset
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