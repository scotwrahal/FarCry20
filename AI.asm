loadAI
    clc
    adc AI_offset
    jmp loadEntity
    
loadAI2
    tay
    asl
    lda AIs,y
    sta $fc
    iny
    lda AIs,y
    sta $fd
    rts
    
; this could probably be condensed if we keep track of x and y
; then you don't have to do a bunch of moves to figure out the direction speeding it up quite significantly
; if we want to optimize this would be a good place to start
setDirection
    ldy direction_offset
    lda #$41
    sta ($fe),y
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