loadAI2
    tay
    asl
    lda AIs,y
    sta $fc
    iny
    lda AIs,y
    sta $fd
    rts
    
checkShot
    ldy direction_offset
    lda ($fe),y
    and #$08
    beq NotShooting
    lda ($fe),y
    and #$fe
    sta ($fe),y
NotShooting
    rts
    
; this could probably be condensed if we keep track of x and y
; then u don't have to do a bunch of moves to figure out the direction speeding it up quite significantly
; if we want to optimize this would be a good place to start
setDirection
    ldy direction_offset
    lda ($fe),y
    and #$c0
    php

    lda #0
    sta ($fe),y

    lda player_offset
    jsr loadEntity2

    plp
    beq CheckRowsFirst
    jsr checkColumns
    bmi SetLeft
    bne SetRight
    jsr setShoot

CheckRowsFirst
    jsr checkRows
    bmi SetUp
    bne SetDown
    jsr setShoot

    jsr checkColumns
    bmi SetLeft
    bne SetRight
CheckedRowsFirst
    rts
    
SetUp
    ldy direction_offset
    lda #$81
    ora ($fe),y
    sta ($fe),y
    rts

SetDown
    ldy direction_offset
    lda #$41
    ora ($fe),y
    sta ($fe),y
    rts
    
SetLeft
    ldy direction_offset
    lda #$21
    ora ($fe),y
    sta ($fe),y
    rts

SetRight
    ldy direction_offset
    lda #$11
    ora ($fe),y
    sta ($fe),y
    rts
    
setShoot
    ldy direction_offset
    lda #$08
    ora ($fe),y
    sta ($fe),y
    rts

; returns -1 if fe is to the left  of fc
; returns  0 if fe is in the same  as fc
; returns  1 if fe is to the right of fc
checkColumns
    ldy position_offset
    iny
    iny
    lda ($fc),y
    cmp ($fe),y
    bmi LeftColumn
    beq SameColumn
    lda #1
    rts
LeftColumn
    lda #$ff
    rts
SameColumn
    lda #0
    rts

    
    
; returns -1 if fe is above fc
; returns  0 if fe is same  fc
; returns  1 if fe is below fc    
checkRows
    ldy position_offset
    lda ($fe),y
    and #$7f
    sta holder
    lda ($fc),y
    and #$7f
    cmp holder
    bmi UpRow
    beq SameRow
DownRow 
    lda #1
    rts
UpRow
    lda #$ff
    rts
SameRow
    lda #0
    rts