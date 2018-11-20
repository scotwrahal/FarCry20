;farcry3
    processor   6502                ;assembling for 6502
    org         $1001               ;standard organization
    word     end_basic           ;pointer to end of BASIC stub
    word     1234                ;line number 1234
    byte     $9e                 ;SYS instruction
    byte     $34,$31,$30,$39     ;address given to SYS: 4109 in ascii (beginning of assembly code)
    byte     0                   ;null terminator for SYS statement
end_basic
    word     0                   ;indicating end of BASIC stub

start:
    lda #255                ; point to custom character set
    sta $9005
load_8x8:
    ldx #0                  ; index of bitmap line
write_byte_line:
    lda graphics,x          ; load line from offset of bitmap
    sta $1c08,x
    inx
    txa
    sbc #127                ; (8*(number of bitmaps) - 1)
    bne write_byte_line     ; loop until all bitmaps loaded into custom char memory

load_screen_colour
    lda #$dd                ; $dd yields light green playfield, dark green border
    sta $900f               ; load value into screen and border colour register (p. 175)

level_load
    lda #0                  ; this will select what level you want loaded
    jsr load_level

set_up_music
    lda #$0f        		; load 15 (max volume) into Accumulator
    sta $900e       		; set max volume

set_timers
    jsr updateClock
        
    ldx #0
SetEntityClocks
    txa
    jsr loadEntity
    lda $ff
    cmp #0
    beq EntityClocksSet
    jsr setClockEntity
    inx
    jmp SetEntityClocks
EntityClocksSet

    ldx #0
SetMusicClocks
    txa
    jsr loadMusicEntity
    lda $ff
    cmp #0
    beq MusicClocksSet
    jsr setClockEntity
    inx
    jmp SetMusicClocks
MusicClocksSet

play_loop
    jsr updateClock
    jsr updateMusic
    jsr input
    ; change add update functions
    ;jsr updateEntitys
    lda #0
    jsr loadEntity
    jsr moveEntity
    jsr drawEntity
    
    jmp play_loop

    INCDIR  "farcry20"    
    INCLUDE "levels.asm"
    INCLUDE "sounds.asm"
    INCLUDE "move.asm"
    INCLUDE "collision.asm"
    INCLUDE "clock.asm"
    INCLUDE "draw.asm"
    INCLUDE "input.asm"
    INCLUDE "data.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateEntitys
    

setClockEntity
    lda clock
    ldy clock_offset
    sta ($fe),y    
    rts
    
loadMusicEntity
    clc 
    adc music_offset
loadEntity
    clc 
    adc entity_offset
    jsr loadDrawable
    rts 

loadDrawable
    sta holder
    pha
    tya
    pha
    lda holder
    tay
    lda drawables,y
    sta $fe
    iny
    lda drawables,y
    sta $ff
    pla 
    tya
    lda holder
    pla
    rts