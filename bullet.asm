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
    
handleBulletCollion
    pla
    cmp #1
    beq BulletTerrain
    cmp #2
    beq BulletPlayer
    cmp #3
    beq BulletAI
    cmp #4
    beq BulletBullet
    rts
    

BulletTerrain
    jmp despawn
BulletBullet
    rts
BulletAI
BulletPlayer
    jsr damage
    jmp despawn

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