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
    sbc graphics_size                ; (8*(number of bitmaps) - 1)
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

    jsr setTimers

play_loop
    jsr updateClock
    jsr updateMusic
    jsr input
    jsr updateEntities
    jmp play_loop

    INCDIR  "farcry20"
    INCLUDE "levels.asm"
    INCLUDE "entity.asm"
    INCLUDE "collision.asm"
    INCLUDE "music.asm"
    INCLUDE "AI.asm"
    INCLUDE "bullet.asm"
    INCLUDE "clock.asm"
    INCLUDE "drawable.asm"
    INCLUDE "input.asm"
    INCLUDE "data.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setTimers
    jsr updateClock

    jsr setEntityClocks
    jsr setAIClocks
    jsr setBulletClocks
    jsr setMusicClocks
    rts