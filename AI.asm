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
    lda #0
    jsr loadEntity2         ; load the player into fc
    jsr checkPositions
    cmp #0
    beq On
    cmp #1
    beq Below
    cmp #2
    beq Above
    rts

Above
    ; jmp SetUp
    ; lda #0      ; keep track of how many times
    ; pha
AboveLoop
    ; pla
    ; clc
    ; adc #1      ; increment the count
    ; pha
    jmp SetDown
    jsr checkPositions
    cmp #2
    bne CheckRowsUp
    jmp AboveLoop
CheckRowsUp
    ; cmp #0 
    ; beq SetUp
    ; jsr checkRows
    ; cmp #0
    ; beq SetRight
    ; jmp SetLeftFromUp
    rts

Below
    ; jmp SetDown
    ; lda #0      ; keep track of how many times
    ; pha
BelowLoop
    ; pla
    ; clc
    ; adc #1      ; increment the count
    ; pha
    jmp SetUp
    jsr checkPositions
    cmp #1
    bne CheckRowsDown
    jmp AboveLoop
CheckRowsDown
    ; cmp #0 
    ; beq SetDown
    ; jsr checkRows
    ; cmp #0
    ; beq SetRight
    ; jmp SetLeftFromUp
    rts 

On    
    rts
    
SetUp
    jsr restoreUp
    lda #$81
    ldy direction_offset
    sta ($fe),y
    rts
SetDown
    jsr restoreDown
    lda #$41
    ldy direction_offset
    sta ($fe),y
    rts
    
SetLeftFromUp
    jsr restoreUp
    jmp SetLeft
SetLeftFromDown
    jsr restoreDown
SetLeft
    lda #$21
    ldy direction_offset
    sta ($fe),y
    rts

SetRightFromUp
    jsr restoreUp
    jmp SetLeft
SetRightDown
    jsr restoreDown
SetRight
    lda #$11
    ldy direction_offset
    sta ($fe),y
    rts
    
restoreDown
restoreUp



; return 0 if they are the same
; return 1 otherwise
checkRows
    ldy position_offset
    lda ($fe),y
    and #$7f
    sta holder
    lda ($fc),y
    and #$7f
    cmp holder
    beq SameRow
    lda #1
    rts
SameRow
    lda #0
    rts