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
    jmp start
    
    INCDIR  "farcry20"
    INCLUDE "data.asm"
    INCLUDE "levels.asm"
    INCLUDE "entity.asm"
    INCLUDE "collision.asm"
    INCLUDE "music.asm"
    INCLUDE "AI.asm"
    INCLUDE "bullet.asm"
    INCLUDE "spawner.asm"
    INCLUDE "clock.asm"
    INCLUDE "drawable.asm"
    INCLUDE "input.asm"
    INCLUDE "healthbar.asm"
    
start:
    lda #252                ; point to custom character set
    sta $9005

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
    jsr input
    jsr updateEntities
    jsr drawAllEntities
    jmp play_loop

    
damage
    ldy health_offset
    lda ($fc),y
    ldy damage_offset
    sec
    sbc ($fe),y
    ldy health_offset
    sta ($fc),y
    rts
; things that could be done to pontenally compress the code
; make the loops all use the same loop and pass in the loading function and what to do
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setTimers
    jsr updateClock
    jsr setClocksAllEntities
    
    rts