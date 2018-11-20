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
    sbc #63                 ; (8*(number of bitmaps) - 1)
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
    sta enemy1_clock
    sta enemy2_clock
    sta music_clock_c1
    sta music_clock_c2

play_loop
    jsr updateClock
    jsr updateMusic
    jsr input
    lda #0
    jsr moveEntity
    lda #3
    jsr moveEntity
    lda #4
    jsr moveEntity
    jmp play_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; helper function for update music
updateNote
    iny                 	; store the next note duration when you update
    tya
    tax                 	; save the index
    lsr                 	; divide by 2
    ldy #0              	; the song length is stored at 0
    cmp ($fc),y         	; compare with the song length
    bne NoSongWrap      	; if you are not on the last not don't wrap
    ldx #2              	; this is the looped index shifted
    lda #1              	; starts at the begining
NoSongWrap
    ldy #1
    sta ($fe),y           	; A store the index the new index
    txa
    tay                 	; restores the proper index for calculations
    lda ($fc),y
    ldy clock_offset
    iny
    sta ($fe),y             ; set the clock update to how long the next note needs to play for
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
    
    ldy #1                  ; load the note index
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

    lda #1                	; music player 1 is the 1st updatable entity
    jsr checkClock
    cmp #0
    beq NoChannel1Update
    
    lda #1                  ; music player 1 is the 1st updatable entity
    jsr loadNote             
    sta $900a          		; store the note in the register
    jsr updateNote          ; advances the music system to the next note

NoChannel1Update
    lda #2                	; music player 2 is the 2nd updatable entity
    jsr checkClock
    cmp #0
    beq NoChannel2Update
    
    lda #2                  ; music player 2 is the 2nd updatable entity
    jsr loadNote
    sta $900b          		; store the note in the register for 2
    jsr updateNote
    
NoChannel2Update
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


; loads the level number in A
; $fc tracks the byte
; $ff tracks current bit
; $fd fe will store the level address

; helper functions for  load level
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

; helper function for load level
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
; helper function for load level   
readByte
    asl $ff                 ; get the value for the next bit
    bcs ReadGround          ; branch for terrain and ground
ReadTerrain
    jsr drawTerrain         ; 0 = terrain
    jmp NextBit
ReadGround
    jsr drawGround          ; 1 = ground
NextBit
    clc
    inx             		; increment the position
    bne BoundarySkip        ; boundery check
    lda #1
BoundarySkip
    dey
    bne readByte            ; repeat till the byte is done
    rts
    
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
    pha                     ; push A to preserve the location
    lda $fc
    cmp #66                 ; check if you have loaded 66 bytes (3 bytes per line 22 lines)
    beq LevelLoadDone       ; BREAK out of load
    pla                     ; restore the location

    jsr loadByte    		
    ldy #8          		; the number of bits in the first byte
    jsr readByte
    jsr loadByte
    ldy #8                  ; the second byte has 8 bits
    jsr readByte
    jsr loadByte
    ldy #6                  ; the 3rd byte has 6 bits
    jsr readByte
    ; this may be where you read the last 2 bits of info for the level
    jmp load_row
; end of loading function


moveEntity
    pha
    jsr checkClock          ; check if you are ready to update
    cmp #0
    beq EndOfPlayerMove
    pla                         ; the player is the 0th updatable entity
    jsr move
    rts
EndOfPlayerMove
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
    
    jsr loadUpdatableEntity
    
    ldy clock_offset
    lda ($fe),y             ; get the clock time
    sec
    cmp clock               ; compare it with the current clock
    beq UpdateClock         ; if the times are equal then you update
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
UpdateClock                 ; if the gameclock is larger than the entity clock may need to update
    iny                     ; move to the entity clock update
    clc
    adc ($fe),y             ; update the clock based on the entity clock update
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

loadUpdatableEntity
    asl                     ; multiply by 2 (updateable entity address is 2 bytes)
    tay
    lda updatable_entitys,y
    sta $fe
    iny
    lda updatable_entitys,y
    sta $ff
    rts
    
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
    
    jsr loadUpdatableEntity

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
	lda #3
	sta player_char
    lda new_position,y
    sec
    sbc #22                 ; move by one row
    bcc MoveUpBorder        ; check if you cross the upper lower border
    sta new_position,y      ; if you didn't, store the new locaiton
    jmp FinishMove
MoveUpBorder
    lda new_position
    beq NoMoveUp          ; if you are in the top then you cant move up
    lda #0                  ; you are now in the top
    sta new_position        ; save in new positon
    lda new_position,y
    sec
    sbc #22                 ; move up one row
    sta new_position,y      ; save new position
NoMoveUp
    jmp FinishMove
MoveDown
	lda #4
	sta player_char
    lda new_position,y
    clc
    adc #22
    bcs MoveDownBorder
    sta new_position,y
    jmp FinishMove
MoveDownBorder
    lda new_position
    bne NoMoveDown
    lda #1
    sta new_position
    lda new_position,y
    clc
    adc #22
    sta new_position,y
NoMoveDown
    jmp FinishMove
MoveLeft
	lda #2
	sta player_char
    lda new_position,y
    sec
    sbc #1
    bcc MoveLeftBorder
    sta new_position,y
    jmp FinishMove
MoveLeftBorder
   lda new_position
   beq NoMoveLeft
   lda #0
   sta new_position
   lda #$ff
   sta new_position,y
NoMoveLeft
   jmp FinishMove
MoveRight
	lda #1
	sta player_char
    lda new_position,y
    clc
    adc #1
    bcs MoveRightBorder
    sta new_position,y
    jmp FinishMove
MoveRightBorder
   lda new_position
   bne NoMoveRight
   lda #1
   sta new_position
   lda #0
   sta new_position,y
NoMoveRight
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
    ldy #1                  ; move the new position to the entity position and set up for draw
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
    sta enemy1_direction
    sta enemy2_direction
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

updatable_entitys ; keep the order of the list
    dc.w    player
    dc.w    music_player_c1
    dc.w    music_player_c2
enemy_entitys
    dc.w    enemy1
    dc.w    enemy2
    

player
player_char
    dc.b    $02
player_color
    dc.b    $06
player_position
    dc.b    $00, #23
player_direction
    dc.b    $00
player_clock
    dc.b    $00
player_clock_updates
    dc.b    $07

enemy1
enemy1_char
    dc.b    $02
enemy1_color
    dc.b    $08
enemy1_position
    dc.b    $00, #46
enemy1_direction
    dc.b    $00
enemy1_clock
    dc.b    $00
enemy1_clock_updates
    dc.b    $03
    
    
enemy2
enemy2_char
    dc.b    $02
enemy2_color
    dc.b    $07
enemy2_position
    dc.b    $00, #68
enemy2_direction
    dc.b    $00
enemy2_clock
    dc.b    $00
enemy2_clock_updates
    dc.b    $05

music_player_c1
track_index_c1
    dc.b    $00
note_index_c1
    dc.b    $01
    
music_player_c2
track_index_c2
    dc.b    $01
note_index_c2
    dc.b    $01
    
    dc.b    $00 ; this used later possibly and is used for spacing
music_clock_c1
    dc.b    $00
music_clock_updates_c1
    dc.b    $01
music_clock_c2
    dc.b    $00
music_clock_updates_c2
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
    dc.b    $06
terrain_color
    dc.b    $00

ground_char
    dc.b    $08
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
jason_left0:
	dc.b $18, $18, $c8, $7c, $1a, $18, $2c, $62
jason_up0:
	dc.b $1a, $1a, $1a, $3c, $58, $18, $18, $10
jason_down0:
	dc.b $18, $18, $18, $3c, $5a, $58, $58, $08
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
    dc.b $00, $00, $00 
    dc.b $7f, $ff, $f8 
    dc.b $7f, $ff, $f8 
    dc.b $7f, $ff, $f8 
    dc.b $67, $fb, $f8 
    dc.b $77, $f9, $f8 
    dc.b $7b, $fd, $f8 
    dc.b $7b, $fd, $f8 
    dc.b $7d, $fe, $f8 
    dc.b $7e, $fe, $f8 
    dc.b $7e, $7e, $f8 
    dc.b $7f, $3e, $f8 
    dc.b $7f, $9e, $78 
    dc.b $7f, $df, $f8 
    dc.b $7f, $ff, $f8 
    dc.b $7f, $ff, $e8 
    dc.b $73, $ff, $98 
    dc.b $78, $01, $38 
    dc.b $7f, $fc, $78 
    dc.b $7f, $ff, $f8 
    dc.b $7f, $ff, $f8 
    dc.b $00, $00, $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOUND MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
song_memory
    dc.w    song0
    dc.w    song1

song0
song0_length
    dc.b    #20, $00    ; number of notes plus one
song0_notes
    ;     duration note
    dc.b    #5, #135
    dc.b    #5, #147
    dc.b    #5, #159
    dc.b    #5, #167
    dc.b    #5, #179
    dc.b    #5, #187
    dc.b    #5, #195
    dc.b    #5, #201
    dc.b    #5, #207
    dc.b    #5, #212
    dc.b    #5, #217
    dc.b    #5, #221
    dc.b    #5, #225
    dc.b    #5, #228
    dc.b    #5, #231
    dc.b    #5, #233
    dc.b    #5, #235
    dc.b    #5, #237
    dc.b    #5, #239
    dc.b    #5, #241
    
song1
song1_length
    dc.b    #20, $00    ; number of notes plus one
song1_notes
    ;     duration note
    dc.b    #8, #135
    dc.b    #8, #147
    dc.b    #8, #159
    dc.b    #8, #167
    dc.b    #8, #179
    dc.b    #8, #187
    dc.b    #8, #195
    dc.b    #8, #201
    dc.b    #8, #207
    dc.b    #8, #212
    dc.b    #8, #217
    dc.b    #8, #221
    dc.b    #8, #225
    dc.b    #8, #228
    dc.b    #8, #231
    dc.b    #8, #233
    dc.b    #8, #235
    dc.b    #8, #237
    dc.b    #8, #239
    dc.b    #8, #241
