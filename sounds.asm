;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; helper function for update music
updateNote
    iny                 	            ; store the next note duration when you update
    tya
    tax                 	            ; save the index
    lsr                 	            ; divide by 2
    ldy length_offset
    cmp ($fc),y         	            ; compare with the song length
    bne NoSongWrap      	            ; if you are not on the last not don't wrap
    ldx #2              	            ; this is the looped index shifted
    lda #1              	            ; starts at the begining
NoSongWrap
    ldy #1
    sta ($fe),y           	            ; A store the index the new index
    txa
    tay                 	            ; restores the proper index for calculations
    lda ($fc),y
    ldy clock_update_offset
    sta ($fe),y                         ; set the clock update to how long the next note needs to play for
    rts

; helper function for update music
loadNote
    jsr loadUpdatableEntity
    
    ldy #0                  ; get the track number
    lda ($fe),y 
    asl                 	; multiply by 2 (music address is 2 bytes)
    tay
    lda song_memory,y		; store the song address in $fe
    sta $fc
    iny
    lda song_memory,y
    sta $fd

    ldy note_offset                 ; load the note index
    lda ($fe),y             
    asl                     ; multiply by 2 (notes are 2 bytes)
    tay
    iny                     ; the key is stored in the 1st location of a note 
    lda ($fc),y             ; get the key to be played
    rts

; update music will update the current track playing
updateMusic
    pha
    tya
    pha
    txa
    pha
    lda $ff
    pha
    lda $fe
    pha
    lda $fd
    pha
    lda $fc
    pha

    lda mp1offset; this is the offset for the music player entity
    jsr checkClock
    cmp #0
    beq NoChannel1Update

    lda mp1offset
    jsr loadNote             
    sta $900a          		; store the note in the register
    jsr updateNote          ; advances the music system to the next note

NoChannel1Update
    lda mp2offset
    jsr checkClock
    cmp #0
    beq NoChannel2Update
    
    lda mp2offset
    jsr loadNote
    sta $900b          		; store the note in the register for 2
    jsr updateNote
    
NoChannel2Update
    lda mp3offset
    jsr checkClock
    cmp #0
    beq NoChannel3Update
    
    lda mp3offset
    jsr loadNote
    sta $900b          		; store the note in the register for 2
    jsr updateNote
NoChannel3Update
    pla
    sta $fc
    pla
    sta $fd
    pla
    sta $fe
    pla
    sta $ff
    pla
    tax
    pla
    tay
    pla
    rts