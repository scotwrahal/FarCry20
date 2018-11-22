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
    bcs MoveUp
    asl
    bcs MoveDown
    asl
    bcs MoveLeft
    asl
    bcs MoveRight
noMove
; set to the idle state 
    lda #0
    ldy state_offset
    sta ($fe),y
    jmp EndMove             ; if there is no direction then it doesn't move
    
; MoveUp is commented the others moves follow similar logic
MoveUp
    ldy position_offset
    iny
    lda ($fe),y
    sec
    sbc #22                 ; move by one row
    bcc MoveUpBorder        ; check the upper lower border
    sta ($fe),y      ; if  didn't, store the new locaiton
    jmp FinishMove
MoveUpBorder
    ldy position_offset
    lda ($fe),y
    beq NoMoveUp            ; in the top cant move up
    lda #0                  ; now in the top
    sta ($fe),y        ; save in new positon
    iny
    lda ($fe),y
    sec
    sbc #22                 ; move up one row
    sta ($fe),y      ; save new position
NoMoveUp
    jmp FinishMove
MoveDown
    ldy position_offset
    iny
    lda ($fe),y
    clc
    adc #22
    bcs MoveDownBorder
    sta ($fe),y
    jmp FinishMove
MoveDownBorder
    ldy position_offset
    lda ($fe),y
    bne NoMoveDown
    lda #1
    sta ($fe),y
    iny
    lda ($fe),y
    clc
    adc #22
    sta ($fe),y
NoMoveDown
    jmp FinishMove
MoveLeft
    ldy position_offset
    iny
    lda ($fe),y
    sec
    sbc #1
    bcc MoveLeftBorder
    sta ($fe),y
    jmp FinishMove
MoveLeftBorder
    ldy position_offset
    lda ($fe),y
    beq NoMoveLeft
    lda #0
    sta ($fe),y
    iny
    lda #$ff
    sta ($fe),y
NoMoveLeft
    jmp FinishMove
MoveRight
    ldy position_offset
    iny
    lda ($fe),y
    clc
    adc #1
    bcs MoveRightBorder
    sta ($fe),y
    jmp FinishMove
MoveRightBorder
    ldy position_offset
    lda ($fe),y
    bne NoMoveRight
    lda #1
    sta ($fe),y
    iny
    lda #0
    sta ($fe),y
NoMoveRight
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