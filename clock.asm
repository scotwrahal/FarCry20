; checks the clock of an updatable entity and updates it if needed
;   the entity needs to be loaded before you check the clock
;   returns 1 if the clock updated 0 otherwise
checkClock
    tya
    pha
    ldy clock_offset
    lda ($fe),y             ; get the clock time
    sec
    cmp clock               ; compare it with the current clock
    beq CheckForLoop         ; if the times are equal then you update
    bcc CheckForLoop
NoClock
    pla
    tay
    lda #0
    rts                     ; restore values and return the result of the check
CheckForLoop                 ; if the gameclock is larger than the entity clock may need to update
    iny                     ; move to the entity clock update
    clc
    adc ($fe),y             ; update the clock based on the entity clock update
    bcs UpdateClock
    sec
    cmp clock
    bcc NoClock
UpdateClock
    dey                     ; return to the clock so you can store the new time
    sta ($fe),y
    pla
    tay
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
    
setClocksAllEntities
    ;loop entitys
    ldx #0              ; index for the list of entitys
SetClock
    txa
    asl                 ; multiply by 2 for address
    jsr loadEntity
    lda $ff 
    cmp #0              ; check for end of entity type
    beq SetClockDone
    jsr setClock
    inx
    jmp SetClock
SetClockDone
    rts

setClock
    lda clock
    clc
    adc #1
    ldy clock_offset
    sta ($fe),y
    rts     
    
rnd
    lda random1
    asl
    eor random1
    asl
    rol random1
    lda random1
    rts