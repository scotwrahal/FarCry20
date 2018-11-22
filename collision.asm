handleCollision
    ;collide with terrain
    cmp #0
    beq CollidedWithNothing
    cmp #1
    beq TerrainCollide
    cmp #2
    beq TerrainCollide
    cmp #3
    beq TerrainCollide
    cmp #4
    beq TerrainCollide
CollidedWithNothing
    rts

TerrainCollide
    jsr terrainCollisionHandler
    rts

terrainCollisionHandler
    jsr invertDirection
    ldy direction_offset
    lda ($fe),y
    ora #$01
    sta ($fe),y
    jsr move
    jsr invertDirection
    rts


; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
checkCollision
    tya
    pha
    ldy on_char_offset
    lda ($fe),y
    cmp terrain_char
    bne Collide
    pla
    tay
    lda #1              ; terrain collision
    rts
Collide
    ;loop entitys
    ldx #0
    lda #0 
    pha
CollideEntity
    txa
    asl
    jsr loadEntity2
    lda $fd
    cmp #0
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
    jsr checkEntity
    cmp #1
    beq CollidedWithEntity
NextEntity
    inx
    jmp CollideEntity
CollidedWithEntity
    pla
    clc
    adc #1
    sta holder
    pla
    tay
    lda holder
    rts
CollideEntityDone
    pla
    clc
    adc #1
    cmp #3
    beq CollideDone
    pha
    inx
    jmp CollideEntity
CollideDone
    pla
    tay
    lda #0
    rts

checkEntity
    ldy position_offset
    lda ($fe),y
    sta holder
    lda ($fc),y
    cmp holder
    bne NotInTheSameSpot
    iny
    lda ($fe),y
    sta holder
    lda ($fc),y
    cmp holder
    bne NotInTheSameSpot
    lda #1
    rts
NotInTheSameSpot
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