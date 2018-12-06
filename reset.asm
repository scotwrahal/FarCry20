reset
    jsr setTimers
    
    lda player_damage
    asl 
    sta player_bullet_damage
    lda diffuculty
    sta enemy_bullet_damage
    
resetAllEntities
    txa
    pha
    ldx #0
ResetEntity
    txa
    jsr loadEntity
    lda $ff
    beq EntitiesReset
    jsr resetEntity
    inx
    jmp ResetEntity
EntitiesReset
    pla 
    tax
    rts

resetEntity
    ldy #clock_offset
    lda clock
    clc 
    adc #1
    sta ($fe),y
    
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
    
resetPlayer
    ldy #position_offset
    lda #player_position1
    sta ($fe),y
    iny
    lda #player_position2
    sta ($fe),y
    iny
    lda #player_position3
    sta ($fe),y 
    
    ldy #health_offset
    lda #$7f
    sta ($fe),y
    
    ldy #on_char_offset
    lda #terrain_index
    sta ($fe),y
    
    ldy #on_color_offset
    lda #green
    sta ($fe),y
    
    ldy #active_offset
    lda #1
    sta ($fe),y
    
    ldy #direction_offset
    lda $80
    sta ($fe),y
    rts
    
resetAI
    ldy #health_offset
    lda diffuculty
    asl
    asl
    asl
    clc
    adc AI_health
    bpl StoreAIHealth
    bcc StoreAIHealth 
    lda #$f7
StoreAIHealth
    sta ($fe),y
    
    ldy #damage_offset
    lda diffuculty 
    lsr
    sta ($fe),y
    
resetBullet    
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

resetCapturePoint
    ldy #capture_percent_offset
    lda #0
    sta ($fe),y

    ldy #position_offset
    lda #capture_position1
    sta ($fe),y
    iny
    lda #capture_position2
    sta ($fe),y
    
    ldy #clock_update_offset
    lda diffuculty
    asl
    asl
    clc
    adc #15
    sta ($fe),y
    
    jsr drawCapturePoint
    rts
    
resetMusic
    jsr ShutDown
resetSpawner
resetHealthbar
    rts
    