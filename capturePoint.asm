Captured
    pla
    brk
    lda #0
    jsr loadLevel
    rts 

drawCapturePoint
    jsr drawEntityOn
    jsr moveRight
    jsr drawEntityOn
    jsr moveDown
    jsr drawEntityOn
    jsr moveLeft
    jsr drawEntityOn
    jsr moveUp
    rts
    
checkIfCapturing
    lda player_offset           ; load player
    jsr loadEntity2
    ; compare the character that the player is on to the capture character
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
    lda #5                      ; this is the capture speed
    clc
    adc ($fe),y
    sta ($fe),y 
    jmp DoneUpdatingCapture
NotCapturing   
    ldy capture_percent_offset
    lda ($fe),y
    sec
    sbc #1
    bpl Bottomed
    lda #0
Bottomed
    sta ($fe),y
DoneUpdatingCapture
    rts
    
drawCaptureBar
    txa
    pha
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
    jsr drawEntityOn
    tya
    pha
    jsr moveLeft
    pla
    tay
    jmp DrawNotCapture
CaptureBarDone
    pla
    tax
    rts