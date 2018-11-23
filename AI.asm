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
    ; find your position relative to the player set your direction towards the player
    ; jsr loadEntity2 ; load the player into fc
    ; jsr checkPositions
    ; cmp #0
    ; beq On
    ; cmp #1
    ; beq Above
    ; cmp #2
    ; beq Below
    ; rts

; Above
    ; lda #0
; AboveLoop
    ; jsr moveUp
    ; jsr checkPositions

; Below
    ; lda #0
; BelowLoop
; On    
    rts
    
    
    
    
; return 0 if entity in fc is in the same spot as the entity in fe
; return 1 if the entity in fc less than fe
; return 2 if the entity in fc greater than fe
; checkPositions 
    ; lda ($fe),y
    ; and #$80
    ; sta holder
    ; lda ($fc),y 
    ; and #$80
    ; cmp holder
    ; bmi Return1
    ; bne Return2
    
    ; iny
    ; lda ($fe),y
    ; sta holder
    ; lda ($fc),y
    ; cmp holder
    ; bmi Return1
    ; bne Return2
; Return0
    ; lda #0
    ; rts
; Return1
    ; lda #1
    ; rts
; Return2
    ; lda #2
    ; rts