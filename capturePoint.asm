updateCapturePoint
    txa
    pha
    jsr checkClock
    beq NotUpdatingCapture
    
    jsr drawCaptureBar
    
    lda player_offset                         ; load player
    jsr loadEntity2
    ldy on_char_offset
    lda ($fe),y
    cmp ($fc),y 
    bne NotCapturing
    ldy on_color_offset
    lda ($fc),y
    and #$0f
    sta holder
    lda ($fe),y
    and #$0f
    cmp holder
    bne NotCapturing
Capturing
    ldy capture_percent_offset
    lda #5
    clc
    adc ($fe),y
    sta ($fe),y 
NotCapturing    
NotUpdatingCapture
    pla 
    tax
    rts

Captured
    brk
    rts 

drawCapturePoint
    jsr drawOn
    jsr moveRight
    jsr drawOn
    jsr moveDown
    jsr drawOn
    jsr moveLeft
    jsr drawOn
    jsr moveUp
    rts
    
drawCaptureBar
    ldy capture_percent_offset
    lda ($fe),y             ; load the amount captured 
    bmi Captured
    lsr
    lsr
    lsr
    lsr
    clc
    adc #1
    tax
    ldy position_offset
    lda #$80
    sta ($fe),y
    iny
    lda #$f9
    sta ($fe),y
    ldy #9
DrawCapture
    dey 
    dex
    beq DrawNotCapture
    jsr drawEntity
    tya
    pha
    jsr moveLeft
    pla
    tay
    jmp DrawCapture
DrawNotCapture
    dey
    beq CaptureBarDone
    jsr drawOn
    tya
    pha
    jsr moveLeft
    pla
    tay
    jmp DrawNotCapture
CaptureBarDone
    rts