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
    INCLUDE "capturePoint.asm"
    INCLUDE "updates.asm"  
    INCLUDE "reset.asm"
        
start:
    lda #252                ; point to custom character set
    sta $9005

load_screen_colour
    lda #$dd                ; $dd yields light green playfield, dark green border
    sta $900f               ; load value into screen and border color register (p. 175)

set_up_music
    lda #$1f        		; load 15 (max volume) into Accumulator and set aux color to white
    sta $900e       		; set max volume

level_load
    jsr loadLevel

    lda #0
    ldy #0
    jsr playSong
    
play_loop
    jsr updateClock
    jsr input
    jsr updateEntities
    jmp play_loop