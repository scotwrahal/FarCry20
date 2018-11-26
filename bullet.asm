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
    
loadBullet2
    tay
    lda bullets,y
    sta $fc
    iny
    lda bullets,y
    sta $fd
    rts

drawBullet
    jmp drawEntity

updateBullet
    jsr setBullet
    jsr updateEntity
    rts
    
setBullet
    lda #1
    ldy direction_offset
    ora ($fe),y
    sta ($fe),y
    rts