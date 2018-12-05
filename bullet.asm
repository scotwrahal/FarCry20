loadBullet2
    asl 
    tay
    lda bullets,y
    sta $fc
    iny
    lda bullets,y
    sta $fd
    rts
    
setBullet
    lda #1
    ldy #direction_offset
    ora ($fe),y
    sta ($fe),y
    rts

shoot  
    ldy #direction_offset
    lda ($fe),y
    and #$08
    beq NoShoot
    lda ($fe),y
    and #$04
    bne NoShoot
    lda ($fe),y         ; make it so that u are not shooting
    and #$f7            ; 111110111
    sta ($fe),y
    ldy #bullet_index_offset
    lda ($fe),y
    jsr loadBullet2
    ldy #active_offset
    lda ($fc),y
    bne NoShoot
    jsr spawnEntity
    lda #1
    ldy #2
    jsr playSong
NoShoot
    rts    