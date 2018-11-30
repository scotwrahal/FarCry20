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
    ldy direction_offset
    ora ($fe),y
    sta ($fe),y
    rts