; TODO make a list of functions


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

    ldx #0
ChannelUpdate
    txa
    asl
    jsr loadMusicEntity
    lda $ff                 ; only need to check the page
    cmp #0                  ; null terminated list
    beq NoMoreChannels
    jsr checkClock
    cmp #0
    beq NoChannelUpdate

    jsr loadSong
    jsr loadNote
    sta holder
    sta $900a,x             ; store the note in the register
    jsr updateNote          ; advances the music system to the next note

NoChannelUpdate
    inx
    jmp ChannelUpdate

NoMoreChannels
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

setClockMusic
    jmp setClockEntity

loadMusicEntity
    clc
    adc music_offset
    jmp loadEntity

loadTrack
    sta holder
    tya
    pha
    lda holder
    ldy tracki_offset
    sta ($fe),y
    pla
    tay
    rts

; helper function for update music
updateNote
    iny                 	            ; store the next note duration when you update
    tya
    ldy length_offset
    cmp ($fc),y         	            ; compare with the song length
    bne NoSongWrap      	            ; if you are not on the last not don't wrap
    lda #2              	            ; starts at the begining
NoSongWrap
    ldy notei_offset
    sta ($fe),y           	            ; update the note index
    tay
    lda ($fc),y                         ; load the clock time for the next note
    ldy clock_update_offset
    sta ($fe),y                         ; set the clock update to how long the next note needs to play
    rts

; helper function for update music
loadSong
    ldy tracki_offset                   ; get the track number
    lda ($fe),y
    asl                 	            ; multiply by 2 (music address is 2 bytes)
    tay
    lda song_memory,y		            ; store the song address in $fc
    sta $fc
    iny
    lda song_memory,y
    sta $fd
    rts

loadNote
    ldy notei_offset
    lda ($fe),y                         ; load the note index
    tay
    iny                                 ; the key is stored in the 1st location of a note
    lda ($fc),y                         ; get the key to be played
    rts