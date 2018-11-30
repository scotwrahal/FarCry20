; checks the clock of an updatable entity and updates it if needed
;   the entity needs to be loaded before u check the clock
;   returns 1 if the clock updated 0 otherwise
checkClock
    lda clock
    sta holder
    ldy clock_offset
    lda ($fe),y
    sec
    cmp holder
    beq Update    
DontUpdate
    lda #0
    rts
Update
    ldy clock_offset
    lda ($fe),y
    ldy clock_update_offset
    clc
    adc ($fe),y
    and #$7f
    ldy clock_offset
    sta ($fe),y
    lda #1
    rts


; update clock updates the clock and stores it where we can check it
updateClock
    pha
    tya
    pha
    txa
    pha
    jsr $ffde               ; read time from system clock
    and #$7f
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
    jsr loadEntity
    lda $ff             ; check for end of entity type
    beq SetClockDone
    jsr setClock
    inx
    jmp SetClock
SetClockDone
    rts

setClock
    txa
    clc
    adc clock
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