handleCollision
    ;collide with terrain
    cmp #0              ; nothing
    beq CollidedWithNothing
    cmp #1              ; terrain
    beq TerrainCollide
    cmp #2              ; player
    beq TerrainCollide
    cmp #3              ; AI
    beq TerrainCollide
    cmp #4              ; bullet
    beq CollidedWithNothing
CollidedWithNothing
    rts

TerrainCollide
    jsr terrainCollisionHandler
    rts

terrainCollisionHandler
    pha
    txa
    pha
    tya
    pha
    ldy direction_offset
    lda ($fe),y
    asl                     ; shift through the bits to get the direction
    bcs CollideMoveDown
    asl
    bcs CollideMoveUp
    asl
    bcs CollideMoveRight
    asl
    bcs CollideMoveLeft
    rts
    
CollideMoveUp
    jsr moveUp
    jmp FinishMove
    rts
    
CollideMoveDown
    jsr moveDown
    jmp FinishMove
    rts
    
CollideMoveLeft
    jsr moveLeft
    jmp FinishMove
    rts
    
CollideMoveRight
    jsr moveRight
    jmp FinishMove
    rts


; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
checkCollision
    tya
    pha
    ldy on_char_offset
    lda ($fe),y
    cmp terrain_char
    beq CollideTerrain
    cmp terrain1_char
    beq CollideTerrain
    jmp Collide
CollideTerrain
    ldy on_color_offset
    lda ($fe),y
    and #$0f
    cmp terrain_color
    beq CollideTerrain2
    cmp terrain1_color
    beq CollideTerrain2
    jmp Collide
CollideTerrain2
    pla
    tay
    lda #1              ; terrain collision
    rts
    
Collide
    ;loop entitys
    ldx #0              ; index for the list of entitys
    lda #0              ; entity type
    pha
CollideEntity
    txa
    asl                 ; multiply by 2 for address
    jsr loadEntity2
    lda $fd
    cmp #0              ; check for end of entity type
    beq CollideEntityDone
    sta holder
    lda $ff
    cmp holder
    bne NotSelf
    lda $fc
    sta holder
    lda $fe
    cmp holder
    beq NextEntity
NotSelf
    jsr checkPositions
    cmp #0
    beq CollidedWithEntity
NextEntity
    inx
    jmp CollideEntity
CollidedWithEntity
    pla
    clc
    adc #2
    sta holder
    pla
    tay
    lda holder
    rts
CollideEntityDone
    pla
    clc
    adc #1              ; advance entity type
    cmp #3              ; 3 entities 
    beq CollideDone
    pha
    inx
    jmp CollideEntity
CollideDone
    pla
    tay
    lda #0
    rts

getChar
    ldy color_offset
    lda ($fe),y
    tax
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
    ldy char_offset
    lda ($fe),y
    clc
    adc holder
    rts

getDirection
    ldy direction_offset
    lda ($fe),y
_Up
    asl
    bcc _Down
    lda #0
    rts
_Down
    asl
    bcc _Left
    lda #1
    rts
_Left
    asl
    bcc _Right
    lda #2
    rts
_Right
    asl
    bcc _None
    lda #3
    rts
_None
    lda #$ff
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
    
checkPositions 
    ldy position_offset
    lda ($fe),y
    and #$80
    lsr
    lsr
    sta holder
    lda ($fc),y 
    and #$80
    lsr
    lsr
    cmp holder
    bmi Return1
    bne Return2                     ; is positive
    
    iny
    lda ($fe),y
    lsr                             ; do a right shift to prevent negatives among large differences
    sta holder
    lda ($fc),y
    lsr
    cmp holder
    bmi Return1
    bne Return2
    
    lda ($fe),y
    sta holder
    lda ($fc),y
    cmp holder
    bmi Return1
    bne Return2
Return0
    lda #0
    rts
Return1
    lda #1
    rts
Return2
    lda #2
    rts