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

loadAI
        clc
    adc AI_offset
    jmp loadEntity

updateAI
    jsr setDirection
    jsr updateEntity
    rts

setDirection
    ; find your position relative to the player set your direction towards the player
    rts
