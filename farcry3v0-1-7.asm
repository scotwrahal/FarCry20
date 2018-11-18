;farcry3
    processor   6502                ;assembling for 6502
    org         $1001               ;standard organization
    dc.w        end_basic           ;pointer to end of BASIC stub
    dc.w        1234                ;line number 1234
    dc.b        $9e                 ;SYS instruction
    dc.b        $34,$31,$30,$39     ;address given to SYS: 4109 in ascii (beginning of assembly code)
    dc.b        0                   ;null terminator for SYS statement
end_basic
    dc.w        0                   ;indicating end of BASIC stub

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
    sbc #39                 ; *(8*(number of bitmaps) - 1)
    bne write_byte_line     ; loop until all bitmaps loaded into custom char memory

load_colour
    lda #$dd                ; $dd yields light green playfield, dark green border
    sta $900f               ; load value into screen and border colour register (p. 175)

level_load
    lda #2                  ; this will select what level you want loaded
    jsr load_level

set_up_music
    lda #$0f        		; load 15 (max volume) into Accumulator
    sta $900e       		; set max volume

set_timers
    jsr updateClock

    ; for all updatable entities make their clock the current clock
    lda clock
    sta player_clock
    sta music_clock

play_loop
    jsr updateClock
    jsr updateMusic
    jsr input
    jsr movePlayer
    jmp play_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

    lda #1                	; music player is the 1st updatable entity
    jsr checkClock
    cmp #0
    beq NoMusicUpdate

    ; load the correct track
    lda track_index
    asl                 	; multiply by 2 (music address is 2 bytes)
    tay
    lda song_memory,y		; store the address in zeropage
    sta $fe
    iny
    lda song_memory,y
    sta $ff

    lda note_index
    asl
    tay
    iny
    lda ($fe),y
    sta $900a          		; store the note in the register
    iny                 	; store the next note duration when you update
    tya
    tax                 	; save the index
    lsr                 	; divide by 2
    ldy #0              	; the song length is stored at 0
    cmp ($fe),y         	; compare with the song length
    bne NoSongWrap      	; if you are not on the last not don't wrap
    ldx #2              	; this is the looped index shifted
    lda #1              	; starts at the begining
NoSongWrap
    sta note_index      	; A holds the new index
    txa
    tay                 	; restores the proper index
    lda ($fe),y
    sta music_clock_updates ; set the clock update to how long the next note needs to play
NoMusicUpdate
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


; loads the level number in A
; $fc tracks the byte
; $ff tracks current bit
; $fd fe will store the level address
load_level
    sta holder
    pha
    txa
    pha
    tya
    pha
    lda $fc
    pha
    lda $ff
    pha
    lda holder
    asl                 	; multiply by 2 (level address is 2 bytes)
    tay
    lda level_mem,y
    sta $fd
    iny
    lda level_mem,y
    sta $fe
; start at 0 0
    lda #0
    sta $fc             	; store the byte number
    ldx #0
load_row
    ; check if you are done
    pha
    lda $fc
    cmp #66                 ; check if you have loaded 66 bytes (3 bytes per line 22 lines)
    beq LevelLoadDone
    pla

    jsr loadByte    		; load the first byte of the row

    ldy #8          		; the number of bits in the first byte
Byte1
    asl $ff         		; get the value for the next bit
    bcs B11         		; branch for terrain and ground
B10
    jsr drawTerrain 		; 0 = terrain
    jmp B1next
B11
    jsr drawGround  		; 1 = ground
B1next
    clc
    inx             		; increment the position
    dey
    bne Byte1       		; repeat till the byte is done

    jsr loadByte
    ldy #8                  ; the second byte has 8 bits
Byte2
    asl $ff
    bcs B21
B20
    jsr drawTerrain
    jmp B2next
B21
    jsr drawGround
B2next
    clc
    inx             		; increment the position
    bne B2skip      		; boundery happens on a b2 so need to check that
    lda #1
B2skip
    dey
    bne Byte2
    jsr loadByte
    ldy #6                  ; the 3rd byte has 6 bits
Byte3
    asl $ff
    bcs B31
B30
    jsr drawTerrain
    jmp B3next
B31
    jsr drawGround
B3next
    clc
    inx
    dey
    bne Byte3
    ; this may be where you read the last 2 bits of info for the level
    jmp load_row


LevelLoadDone
    pla         			; extra pull for preserving the position
    pla
    sta $ff
    pla
    sta $fc
    pla
    tay
    pla
    tax
    pla
    rts

loadByte
    pha
    tya
    pha
    ldy $fc                 ; load the byte number
    lda ($fd),y
    sta $ff
    iny
    sty $fc
    pla
    tay
    pla
    rts

movePlayer
    pha
    tya
    pha
    lda #0                  ; the player is the 0th updatable entity
    jsr checkClock          ; check if you are ready to update
    cmp #0
    beq EndOfPlayerMove
    lda #0                  ; the player is the 0th updatable entity
    jsr move
EndOfPlayerMove
    pla
    tay
    pla
    rts

; checks the clock of an updatable entity and updates it if needed
;   A has the index of the updatable entity you are checking
;   returns 1 if the clock updated 0 otherwise
checkClock
    sta holder
    pha
    tya
    pha
    lda $ff
    pha
    lda $fe
    pha
    lda holder

    ; load the entity
    asl                     ; multiply by 2 (entity address is 2 bytes)
    tay
    lda updatable_entity_mem,y
    sta $fe
    iny
    lda updatable_entity_mem,y
    sta $ff

    ldy clock_offset
    lda ($fe),y             ; get the clock time
    sec
    cmp clock               ; compare it with the current clock
    beq CheckForLoop        ; if the times are equal then you update
    ;bcc CheckForLoop        ; if the carry is set you dont update ie. gameclock is less than entity clock
NoClock
    pla
    tay
    pla
    sta $fe
    pla
    sta $ff
    pla
    lda #0
    rts                     ; restore values and return the result of the check
CheckForLoop                ; if the gameclock is larger than the entity clock may need to update
    iny                     ; move to the entity clock update
    clc
    adc ($fe),y             ; update the clock based on the entity clock update
    ;bcs UpdateEntityClock
    ;sec
    ;cmp clock               ; if the new time is also past the clock you are wrapped so don't update
    ;bcc NoClock
UpdateEntityClock
    dey                     ; return to the clock so you can store the new time
    sta ($fe),y
    pla
    tay
    pla
    sta $fe
    pla
    sta $ff
    pla
    lda #1
    rts                     ; restore values and return the result of the check

; moves an updatable entity based on the direction they are moving and if the low bit is set
;   A index of the updatable entity to be moved
move
    sta holder
    pha
    txa
    pha
    tya
    pha
    lda holder

    asl                     ; multiply by 2 (updateable entity address is 2 bytes)
    tay
    lda updatable_entity_mem,y
    sta $fe
    iny
    lda updatable_entity_mem,y
    sta $ff

    ldy position_offset     ; this is the offest for the position in the structure

    ; transfer the old position to the new position
    lda ($fe),y             ; load the location
    sta new_position
    iny
    ldx #1
    lda ($fe),y
    sta new_position,x

    iny
    lda ($fe),y             ; load the direction into A
    lsr
    bcc noMove
    asl
    sta ($fe),y
    ldy #1                  ; load 1 for the low position
    asl                     ; shift through the bits to get the direction
    bcs MoveUp
    asl
    bcs MoveDown
    asl
    bcs MoveLeft
    asl
    bcs MoveRight
noMove
    jmp EndMove             ; if there is no direction then it doesn't move

; MoveUp is commented the others moves follow similar logic
MoveUp
    lda new_position,y
    sec
    sbc #22                 ; move by one row
    bcc MoveUpBorder        ; check if you cross the upper lower border
    sta new_position,y      ; if you didn't, store the new locaiton
    jmp FinishMove
MoveUpBorder
    lda new_position
    beq FinishMove          ; if you are in the top then you cant move up
    lda #0                  ; you are now in the top
    sta new_position        ; save in new positon
    lda new_position,y
    sec
    sbc #22                 ; move up one row
    sta new_position,y      ; save new position
    jmp FinishMove

MoveDown
    lda new_position,y
    clc
    adc #22
    bcs MoveDownBorder
    sta new_position,y
    jmp FinishMove
MoveDownBorder
    lda new_position
    bne FinishMove
    lda #1
    sta new_position
    lda new_position,y
    clc
    adc #22
    sta new_position,y
    jmp FinishMove

MoveLeft
    lda new_position,y
    sec
    sbc #1
    bcc MoveLeftBorder
    sta new_position,y
    jmp FinishMove
MoveLeftBorder
    lda new_position
    beq FinishMove
    lda #0
    sta new_position
    lda #$ff
    sta new_position,y
    jmp FinishMove

MoveRight
    lda new_position,y
    clc
    adc #1
    bcs MoveRightBorder
    sta new_position,y
    jmp FinishMove
MoveRightBorder
    lda new_position
    bne FinishMove
    lda #1
    sta new_position
    lda #0
    sta new_position,y
    jmp FinishMove

FinishMove
    jsr check_collision     ; check for collisions

    cmp #0
    bne Collision
NoCollision
    ldy position_offset     ; load in the old position
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    jsr drawGround          ; draw the ground in the old position
                            ; may want to update this so that the entity keeps track what is under it
    ldy #1                  ; move the new position to the old position
    lda new_position,y
    ldy position_offset
    iny
    sta ($fe),y
    tax
    dey
    lda new_position
    sta ($fe),y
    jsr draw                ; draw the entity

Collision
    ; handle collisions here right now it just doesnt move
    
EndMove
    pla
    tay
    pla
    tax
    pla
    rts
; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
check_collision
    pha
    tya
    pha
    lda new_position
    ldy #1
    ldx new_position,y
    jsr getFromPosition     ; gets the character on the screen in the new position
    ; need to make a collide list maybe
    cmp ground_char
    beq NoCollide
    pla
    tay
    pla
    lda #1
    rts
NoCollide
    pla
    tay
    pla
    lda #0
    rts

; getFromPosition returns the color and the character at a locaiton on the screen
;   A: top/bottom location 0 = top
;   X: location
;   return
;   A: character
;   X: color
getFromPosition
    cmp #0
    bne readBottom
    lda $1e00,x
    pha
    lda $9600,x
    tax
    pla
    rts
readBottom
    lda $1f00,x
    pha
    lda $9700,x
    tax
    pla
    rts

; draw
;   A: top/bottom location 0 = top
;   X: location
;   $fe $ff: entity to draw
draw
    sta holder              ; clear accumulator to store state
    pha
    tya
    pha
    lda holder
    cmp #0
    bne DrawBottom
    ldy #0                  ; this is the index for the character
    lda ($fe),y
    sta $1e00,x
    ldy #1                  ; this is the index for the color
    lda ($fe),y
    sta $9600,x
    jmp EndDraw

DrawBottom
    ldy #0
    lda ($fe),y
    sta $1f00,x
    ldy #1
    lda ($fe),y
    sta $9700,x
EndDraw
    pla
    tay
    pla
    rts

; drawTerrain
; A: top/bottom bit 0= top
; X: position
drawTerrain
    sta holder
    pha
    tya
    pha
    ldy #0                  ; terrain is the 0th drawable
    lda holder
    jsr drawDrawable
    pla
    tay
    pla
    rts

; drawGround
; A: top/bottom bit 0= top
; X: position
drawGround
    sta holder
    pha
    tya
    pha
    ldy #1                  ; ground is the 1st drawable
    lda holder
    jsr drawDrawable
    pla
    tay
    pla
    rts

; drawTerrain
; A: top/bottom bit 0= top
; X: position
; Y: index
drawDrawable
    sta holder
    pha
    lda $ff
    pha
    lda $fe
    pha
    tya                     ; makes the index stored into A for loading
    pha
    ;load the drawable
    asl                     ; multiply by 2 (drawable entity address is 2 bytes)
    tay                     
    lda drawable_mem,y
    sta $fe
    iny
    lda drawable_mem,y
    sta $ff
    lda holder              ; restore the position
    jsr draw
    pla
    tay
    pla
    sta $fe
    pla
    sta $ff
    pla
    rts

; input take the input and stores it for the player
; sets the lowest byte to one to show that it updated
; stores the old if there is no update
;   may want to make this work for the joystick.
input
    pha
    lda $c5                 ; read scancode
Up
    cmp #9                  ;'W' Scancode
    bne Down
    lda #$81
    jmp InputRetrun
Down
    cmp #41                 ;'S' Scancode
    bne Left
    lda #$41
    jmp InputRetrun
Left
    cmp #17                 ;'A' Scancode
    bne Right
    lda #$21
    jmp InputRetrun
Right
    cmp #18                 ;'D' Scancode
    bne nothin
    lda #$11
    jmp InputRetrun
    ; expand here for more input upto 3 with the same byte
nothin
    lda player_direction
InputRetrun
    sta player_direction
    pla
    rts

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

holder
    dc.b    $00

last_input
    dc.b    $00

new_position
    dc.b    $00, $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UPDATABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clock
    dc.b    $00

position_offset
    dc.b    $02
clock_offset
    dc.b    $05

updatable_entity_mem ; keep the order of the list
    dc.w    player_char
    dc.w    music_player

player_char
    dc.b    $02
player_color
    dc.b    $06
player_position
    dc.b    $00, $22
player_direction
    dc.b    $00
player_clock
    dc.b    $00
player_clock_updates
    dc.b    $04

music_player
track_index
    dc.b    $00
note_index
    dc.b    $01

    dc.b    $00, $00, $00 ;this is all stuff to be used later possibly
    ; may store the start of the song and the index or somthing like that
music_clock
    dc.b    $00
music_clock_updates
    dc.b    $01


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawable_mem ; keep the order of the list
    dc.w    terrain_char
    dc.w    ground_char
    dc.w    player_char
    dc.w    up_char
    dc.w    down_char
    dc.w    left_char
    dc.w    right_char

terrain_char
    dc.b    $04
terrain_color
    dc.b    $00

ground_char
    dc.b    $05
ground_color
    dc.b    $05

up_char
    dc.b    $71
up_color
    dc.b    $05

down_char
    dc.b    $72
down_color
    dc.b    $05

left_char
    dc.b    $73
left_color
    dc.b    $05

right_char
    dc.b    $74
right_color
    dc.b    $05


graphics:
jason_right0:
    dc.b $18, $18, $13, $3e, $58, $18, $34, $46
jaguar_right0:
    dc.b $02, $43, $43, $9e, $7f, $66, $62, $a1
palm_tree0:
    dc.b $1a, $7c, $b2, $28, $48, $08, $0c, $1f
shrub0:
    dc.b $0a, $4c, $28, $1d, $2a, $1c, $08, $1c
shrub1:
    dc.b $28, $2a, $ac, $a9, $99, $5a, $3c, $1c



;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEVEL MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ideally to be stored on a disk and loaded in later
level_mem
    dc.w    level0
    dc.w    level1
    dc.w    level2

level0
    dc.b    $00, $00, $00
    dc.b    $7f, $aa, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $75, $55, $58
    dc.b    $00, $00, $00


level1
    dc.b    $00, $00, $00
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $00, $00, $00

level2
    dc.b    $00, $00, $00
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $f0, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $7f, $ff, $f8
    dc.b    $00, $00, $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOUND MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
song_memory
    dc.w    song1

song1
song1_length
    dc.b    $03, $00    ; number of notes plus one
song1_notes
    ;     duration note
    dc.b    #30, #130
    dc.b    #30, #175
