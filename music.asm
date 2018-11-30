; TODO make a list of functions
; update music will update the current track playing
loadSong
    ldy tracki_offset
    lda ($fe),y
    asl
    tay 
    lda song_memory,y
    sta $fc 
    iny
    lda song_memory,y
    sta $fd
    rts

loadNote
    ldy notei_offset
    lda ($fe),y
    asl
    tay 
    iny
    lda ($fc),y
    rts

storeNote
    sta holder              ; store it for later
    ldy channel_offset
    lda ($fe),y
    tay
    lda holder              ; get the note
    sta $900a,y             ; store the note in the correct register
    rts

updateNote
    ldy notei_offset
    lda ($fe),y
    clc
    adc #1
    ldy length_offset
    cmp ($fc),y
    bne NoLoop
    lda #1
NoLoop
    ldy notei_offset
    sta ($fe),y
    asl
    tay 
    lda ($fc),y
    ldy clock_update_offset
    sta ($fe),y
    rts