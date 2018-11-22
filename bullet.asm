setBulletClocks
    ldx #0
SetBulletClocks
    txa
    asl
    jsr loadBullet
    lda $ff
    cmp #0
    beq BulletClocksSet
    jsr setClock
    inx
    jmp SetBulletClocks
BulletClocksSet
    rts

updateBullets
    ldx #0
UpdateBullets
    txa
    asl
    jsr loadBullet
    lda $ff
    cmp #0
    beq BulletEntitiesUpdated
    jsr updateBullet
    inx
    jmp UpdateBullets
BulletEntitiesUpdated
    rts

loadBullet
    clc
    adc bullet_offset
    jmp loadEntity

moveBullet
    clc
    adc bullet_offset
    jsr checkClock
    cmp #0
    bne NoTime
    jsr move
    ldy direction_offset
    lda #1
    ora ($fe),y
    sta ($fe),y
NoTime
    rts

drawBullet
    jmp drawEntity

updateBullet
    rts