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
    clc
    adc song_notes_offset
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
    
ShutDown
    lda #0
    jsr storeNote
    ldy active_offset
    sta ($fe),y
    rts

updateNote
    ldy notei_offset
    lda ($fe),y
    clc
    adc #1
    ldy length_offset
    cmp ($fc),y
    bne NoLoop
    ldy loop_offset
    lda ($fc),y
    beq ShutDown
    lda #0
NoLoop
    ldy notei_offset
    sta ($fe),y
    asl
    clc 
    adc song_notes_offset
    tay 
    lda ($fc),y
    ldy clock_update_offset
    sta ($fe),y
    rts

loadMusicPlayer
    asl 
    tay 
    lda music,y 
    sta $fe
    iny
    lda music,y
    sta $ff
    rts
    
; A the music player to play on
; Y the song you want to play
playSong
    sta holder
    lda $ff
    pha
    lda $fe
    pha
    lda holder

    
    sty holder
    jsr loadMusicPlayer
    lda holder
    pha
    jsr ShutDown
    ldy tracki_offset
    pla
    sta ($fe),y
    
    ldy notei_offset
    lda #0
    sta ($fe),y
    
    ldy clock_offset
    lda clock
    sta ($fe),y
    
    ldy clock_update_offset
    lda #1
    sta ($fe),y
    
    ldy active_offset
    lda #1
    sta ($fe),y
    
    jsr loadSong
    
    ldy song_channel_offset
    lda ($fc),y
    ldy channel_offset
    sta ($fe),y
    
    pla
    sta $fe
    pla
    sta $ff
    rts