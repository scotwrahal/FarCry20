; checks the clock of an updatable entity and updates it if needed
;   A has the index of the updatable entity you are checking
;   returns 1 if the clock updated 0 otherwise
checkClock
    sta holder
    pha
    tya
    pha
    lda $ff
    pha
    lda $fe
    pha
    lda holder
    
    jsr loadEntity
    
    ldy clock_offset
    lda ($fe),y             ; get the clock time
    sec
    cmp clock               ; compare it with the current clock
    beq UpdateClock         ; if the times are equal then you update
NoClock
    pla
    tay
    pla
    sta $fe
    pla
    sta $ff
    pla
    lda #0
    rts                     ; restore values and return the result of the check
UpdateClock                 ; if the gameclock is larger than the entity clock may need to update
    iny                     ; move to the entity clock update
    clc
    adc ($fe),y             ; update the clock based on the entity clock update
    dey                     ; return to the clock so you can store the new time
    sta ($fe),y
    pla
    tay
    pla
    sta $fe
    pla
    sta $ff
    pla
    lda #1
    rts                     ; restore values and return the result of the check

    
    ; update clock updates the clock and stores it where we can check it
updateClock
    pha
    tya
    pha
    txa
    pha
    jsr $ffde               ; read time from system clock
    sta clock               ; store the low byte since we only really need it
    ; may want to store more time info for scoring
    pla
    tax
    pla
    tay
    pla
    rts