loadBulletEntity
    clc
    adc bullet_offset
    jmp loadEntity

moveBullet
    clc
    adc bullet_offset
    jsr moveEntity
    ldy direction_offset
    lda #1
    ora ($fe),y
    sta ($fe),y
    rts
    
drawBullet
    jmp drawEntity
    
updateBulletEntity
    rts