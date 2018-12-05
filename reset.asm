reset
    jsr setTimers
    jsr resetAllEntities
    rts

resetAllEntities
    txa
    pha
    ldx #0
ResetEntity
    txa
    jsr loadEntity
    lda $ff
    beq EntitiesResetd
    jsr resetEntity
    inx
    jmp ResetEntity
EntitiesResetd
    pla 
    tax
    rts

resetEntity
    ldy #type_offset
    lda ($fe),y
    cmp #2 
    beq ResetPlayer
    cmp #3 
    beq ResetAI
    cmp #4 
    beq ResetBullet
    cmp #5 
    beq ResetSpawner
    cmp #6
    beq ResetHealthbar
    cmp #7
    beq ResetCapturePoint
    cmp #8 
    beq ResetMusic
    rts
    
ResetPlayer
    jmp resetPlayer
ResetAI
    jmp resetAI
ResetBullet
    jmp resetBullet
ResetSpawner
    jmp resetSpawner
ResetHealthbar
    jmp resetHealthbar
ResetCapturePoint
    jmp resetCapturePoint
ResetMusic
    jmp resetMusic
    
resetCapturePoint
    ldy #capture_percent_offset
    lda #$0
    sta ($fe),y

    ldy #position_offset
    lda #0
    sta ($fe),y
    iny
    lda #250
    sta ($fe),y
     
    jsr drawCapturePoint
    rts
    
resetMusic
    jsr ShutDown
resetSpawner
resetHealthbar
    rts

resetBullet    
resetAI
    ldy #position_offset
    lda #$80
    sta ($fe),y
    iny
    lda #$ff
    sta ($fe),y
    
    ldy #active_offset
    lda #0
    sta ($fe),y
    rts
    
resetPlayer
    ldy #position_offset
    lda #2
    sta ($fe),y
    iny
    lda #50
    sta ($fe),y
    iny
    lda #6
    sta ($fe),y 
    
    ldy #health_offset
    lda #$7f
    sta ($fe),y
    
    ldy #on_char_offset
    lda #3
    sta ($fe),y
    
    ldy #on_color_offset
    lda #5
    sta ($fe),y
    rts
    