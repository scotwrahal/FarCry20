resetEntities
    txa
    pha
    ldx #0
ResetEntity
    txa
    jsr loadEntity
    lda $ff
    beq EntitiesResetd
    jsr checkClock
    beq NotReadyForReset
    ldy active_offset
    lda ($fe),y
    beq NotReadyForReset
    jsr resetEntity
DontDraw
NotReadyForReset
    inx
    jmp ResetEntity
EntitiesResetd
    pla 
    tax
    rts

resetEntity
    ldy type_offset
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
    
resetPlayer
    ldy position_offset
    lda #2
    lda #2
    sta ($fe),y
    iny
    lda #50
    sta ($fe),y
    iny
    lda #6
    sta ($fe),y 
    rts
    getFromEntityPosition