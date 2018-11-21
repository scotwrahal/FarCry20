loadBulletEntity
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

updateBulletEntity
    rts