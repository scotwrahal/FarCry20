loadAI
    clc
    adc AI_offset
    jmp loadEntity
    
loadAI2
    tay
    lda AIs,y
    sta $fc
    iny
    lda AIs,y
    sta $fd
    rts

updateAI
    jsr setDirection
    jsr updatePlayer
    rts
    
; this could probably be condensed if we keep track of x and y
; then you don't have to do a bunch of moves to figure out the direction speeding it up quite significantly
; if we want to optimize this would be a good place to start
setDirection
    pha 
    tya 
    pha
    txa
    pha
    ldy direction_offset
    lda ($fe),y
    and #$01                ; only update direction if you need to move
    beq SetDirection
    jmp ReturnSetDirection
    
    
SetDirection  
    ; find your position relative to the player set your direction towards the player
    lda #0
    jsr loadEntity2         ; load the player into fc
    ldy active_offset
    lda ($fc),y
    beq PlayerDead
    ldx #0                  ; set the move counter to 0
    jsr checkPositions
    cmp #1
    beq Below
    cmp #2
    beq Above
PlayerDead
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
    beq SetDownWithRestore  
    dex
    php
    inx
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
    beq SetUpWithRestore
    dex
    php
    inx
    jsr checkRows
    cmp #0
    beq SetRightFromBelow
    jmp SetLeftFromBelow
    
SetUpWithRestore
    jsr restoreFromBelow
    ; shoot here
SetUp
    lda #$81
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection
    
SetDownWithRestore
    jsr restoreFromAbove
    ; shoot here
SetDown
    lda #$41
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection
    
SetLeftFromAbove
    jsr restoreFromAbove
    plp                     ; check if you moved down only one time
    beq SetLeft
    ldy direction_offset
    lda ($fe),y
    and #$40                ; if it was not down go down
    beq SetDown
    jmp SetLeft
SetLeftFromBelow
    jsr restoreFromBelow
    plp
    beq SetLeft
    ldy direction_offset
    lda ($fe),y
    and #$80                ; if it was not up go up
    beq SetUp
SetLeft
    lda #$21
    ldy direction_offset
    sta ($fe),y
    jmp ReturnSetDirection

SetRightFromAbove
    jsr restoreFromAbove
    plp
    beq SetRight
    ldy direction_offset
    lda ($fe),y
    and #$40                ; if it was not down go down
    beq SetDown
    jmp SetRight
SetRightFromBelow
    jsr restoreFromBelow
    plp
    beq SetRight
    ldy direction_offset
    lda ($fe),y
    and #$80                ; if it was not up go up
    beq SetUp
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