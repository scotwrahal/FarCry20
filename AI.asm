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
    pha 
    tya 
    pha
    txa
    pha
    
    ; find your position relative to the player set your direction towards the player
    lda #0
    jsr loadEntity2         ; load the player into fc
    ldx #0                  ; set the move counter to 0
    jsr checkPositions
    cmp #0
    beq On
    cmp #1
    beq Below
    cmp #2
    beq Above
    jmp ReturnSetDirection

Above
    inx
    jsr moveDown
    jsr checkPositions
    cmp #2
    bne CheckRowsAbove
    jmp Above
CheckRowsAbove
    cmp #0
    beq SetDown   
    jsr checkRows
    cmp #0
    beq SetLeftFromAbove
    jmp SetRightFromAbove
    
Below
    inx
    jsr moveUp
    jsr checkPositions
    cmp #1
    bne CheckRowsBelow
    jmp Below
CheckRowsBelow
    cmp #0
    beq SetUp
    jsr checkRows
    cmp #0
    beq SetRightFromBelow
    jmp SetLeftFromBelow
    
On    
    jmp ReturnSetDirection
    
SetUp
    jsr restoreFromBelow
    lda #$81
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection
    
SetDown
    jsr restoreFromAbove
    lda #$41
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection
    
SetLeftFromAbove
    jsr restoreFromAbove
    jmp SetLeft
SetLeftFromBelow
    jsr restoreFromBelow
SetLeft
    lda #$21
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection

SetRightFromAbove
    jsr restoreFromAbove
    jmp SetRight
SetRightFromBelow
    jsr restoreFromBelow
SetRight
    lda #$11
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection
    

restoreFromBelow
    jsr moveDown
    dex
    bne restoreFromBelow
    rts
    
restoreFromAbove
    jsr moveUp
    dex
    bne restoreFromAbove
    rts

ReturnSetDirection
    pla
    tax
    pla
    tay
    pla
    rts


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