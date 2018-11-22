setAIClocks    
    ldx #0
SetAIClocks
    txa
    asl
    jsr loadAI
    lda $ff
    cmp #0
    beq AIClocksSet
    jsr setClock
    inx
    jmp SetAIClocks
AIClocksSet
    rts
    
updateAIs
    ldx #0
    lda $11
    sta AI1_direction
UpdateAI
    txa
    asl
    jsr loadAI
    lda $ff
    cmp #0
    beq AIsUpdated
    jsr updateAI
    inx
    jmp UpdateAI
AIsUpdated
    rts
    
loadAI
    clc
    adc AI_offset
    jmp loadEntity

updateAI
    jsr setDirection
    jsr updateEntity
    rts

setDirection
    ldy direction_offset
    lda #$11
    sta ($fe),y
    ; find your position relative to the player set your direction towards the player
    rts
