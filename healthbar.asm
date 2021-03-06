drawHealthBar
    txa
    pha
    lda #player_offset
    jsr loadEntity2         ; load the player
    ldy #health_offset
    lda ($fc),y             ; load the health
    bmi NoUpdateHealth  
    lsr                     ; make it 0-7
    lsr
    lsr
    lsr 
    clc
    adc #1
    tax
    lda #$e4                ; set the position to be the last row 
    ldy #position_offset
    iny
    sta ($fe),y
    ldy #9
DrawHealth
    dey 
    dex
    beq DrawNotHealth
    jsr drawEntity
    tya
    pha
    jsr moveRight
    pla
    tay
    jmp DrawHealth
DrawNotHealth
    dey
    beq BarDone
    jsr drawEntityOn
    tya
    pha
    jsr moveRight
    pla
    tay
    jmp DrawNotHealth
NoUpdateHealth
BarDone
    pla
    tax
    rts