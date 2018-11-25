graphics:
jaguar_right0:  byte $02, $43, $43, $9e, $7f, $66, $62, $a1
human
human_up0:  	byte $1a, $1a, $1a, $3c, $58, $18, $18, $10
human_down0:    byte $18, $18, $18, $3c, $5a, $58, $58, $08
human_left0:	byte $18, $18, $c8, $7c, $1a, $18, $2c, $62
human_right0:   byte $18, $18, $13, $3e, $58, $18, $34, $46
human_up1:	    byte $1a, $1a, $1a, $3c, $38, $18, $18, $00
human_down1:	byte $18, $18, $18, $3c, $5c, $58, $58, $00
human_left1:	byte $18, $18, $c8, $7c, $1c, $18, $14, $34
human_right1:	byte $18, $18, $13, $3e, $38, $18, $28, $2c
human_up2:	    byte $1a, $1a, $1a, $3c, $58, $18, $18, $08
human_down2:	byte $18, $18, $18, $3c, $5a, $58, $58, $10
human_left2:	byte $18, $18, $c8, $78, $18, $18, $08, $18
human_right2:	byte $18, $18, $13, $1e, $18, $18, $10, $18

palm_tree0:     byte $00, $7c, $b2, $28, $48, $08, $0c, $1f
shrub0:         byte $00, $4c, $28, $1d, $2a, $1c, $08, $1c
shrub1:         byte $0, $2a, $ac, $a9, $99, $5a, $3c, $1c
end_graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
holder          byte $00
clock           byte $00
random1         byte $55         
random2         byte $cc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawables:
terrain     word terrain_char
terrain1    word terrain1_char
ground      word ground_char
ground1     word ground1_char
on_holder   word on_char

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UPDATABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THESE EXTEND DRAWABLE
entities:
player      word player_char
            word 0
AIs:
AI1         word AI1_char
AI2         word AI2_char
            word 0

bullets:
bullet1     word bullet1_char
            word 0              ; terminator for list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUSIC PLAYERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THESE ARE UPDATABLE BUT NOT DRAWABLE
music:
music_player_1  word track_index_1
music_player_2  ;word track_index_2
music_player_3  ;word track_index_3
music_player_4  ;word track_index_4
                word #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
terrain_char    byte [palm_tree0 - graphics]/8+2
terrain_color   byte $00 ; black 

terrain1_char    byte [shrub0 - graphics]/8+2
terrain1_color   byte $00 ; black 


ground_char     byte [shrub1 - graphics]/8+2
ground_color    byte $05 ; green

ground1_char    byte [shrub0 - graphics]/8+2
ground1_color   byte $05 ; green

on_char         byte $00
on_color        byte $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UPDATABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
template                                ; this is used for calculating offsets
char
player_char             byte [human - graphics]/8+2
color
player_color            byte $06
t_clock
player_clock            byte $00
clock_updates
player_clock_updates    byte $08
position
player_position         byte #2, #50        ; 1 tells you if you are in the top or bottom 0 nothing 111111 row number, position byte
direction
player_direction        byte $80            ; bits 1111 direction 11 shooing 0 nothing 1 movement
on_char_template
player_on_char          byte [shrub1 - graphics]/8+2
on_color_template
player_on_color         byte $05
damage
player_damage           byte $01
health
player_health           byte $ff
state
player_state            byte $00
max_state
player_max_state        byte $02

AI1_char                byte [human - graphics]/8+2
AI1_color               byte $02
AI1_clock               byte $00
AI1_clock_updates       byte #14
AI1_position            byte $02, #47
AI1_direction           byte $00
AI1_on                  byte [shrub1 - graphics]/8+2, $05
AI1_health              byte $ff
AI1_damage              byte $01
AI1_state               byte $00
AI1_max_state           byte $03

AI2_char                byte [human - graphics]/8+2
AI2_color               byte $02
AI2_clock               byte $00
AI2_clock_updates       byte #14
AI2_position            byte $03, #68
AI2_direction           byte $00
AI2_on                  byte [shrub1 - graphics]/8+2, $05
AI2_health              byte $ff
AI2_damage              byte $01
AI2_state               byte $00
AI2_max_state           byte $03

bullet1_char            byte [human - graphics]/8+2
bullet1_color           byte $00
bullet1_clock           byte $00
bullet1_clock_updates   byte $05
bullet1_position        byte $04, #75
bullet1_direction       byte $40
bullet1_on              byte [shrub1 - graphics]/8+2, $05
bullet1_health          byte $ff
bullet1_damage          byte $01
bullet1_state           byte $00
bullet1_max_state       byte $03

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUSIC PLAYERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
music_template
track_index
track_index_1           byte $00
note_index
note_index_1            byte $02        ; starts at 2 for all music players
music_clock_1           byte $00
music_clock_updates_1   byte $01

track_index_2           byte $00
note_index_2            byte $02
music_clock_2           byte $00
music_clock_updates_2   byte $01

track_index_3           byte $00
note_index_3            byte $02
music_clock_3           byte $00
music_clock_updates_3   byte $01

track_index_4           byte $00
note_index_4            byte $02
music_clock_4           byte $00
music_clock_updates_4   byte $01

human_animation_state:
	byte $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEVEL MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ideally to be stored on a disk and loaded in later
level_mem
    word level0

level_start
level0
    byte $00, $00, $00
    byte $7f, $aa, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $75, $55, $58
    byte $00, $00, $00
level_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOUND MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
song_memory
song0    word song0_length
song1    word song1_length
         word #0

song_template
song_length
song0_length
    byte song0_end - song0_notes, $00    ; number of notes plus one
song_notes
song0_notes
    ;     duration note
    byte    #12, #231
    byte    #12, #222
    byte    #12, #231
    byte    #12, #206
    byte    #12, #231
    byte    #12, #206
    byte    #12, #218
    byte    #12, #206
    byte    #12, #229
    byte    #12, #231
    byte    #12, #220
    byte    #12, #206
    byte    #12, #181
    byte    #12, #206
    byte    #12, #218
    byte    #12, #206
song0_end

song1_length
    byte  song1_end - song1_notes, $00    ; number of notes plus one
song1_notes
    ;     duration note
    byte #8, #135
    byte #8, #147
    byte #8, #159
    byte #8, #167
    byte #8, #179
    byte #8, #187
    byte #8, #195
    byte #8, #201
    byte #8, #207
    byte #8, #212
    byte #8, #217
    byte #8, #221
    byte #8, #225
    byte #8, #228
    byte #8, #231
    byte #8, #233
    byte #8, #235
    byte #8, #237
    byte #8, #239
    byte #8, #241
song1_end


;;;;;;;;; TODO LOOK FOR A WAY TO CALCULATE THESE and not store them

terrain_offset      byte terrain - drawables
ground_offset       byte ground - drawables
on_holder_offset    byte on_holder - drawables
char_offset         byte char - template
color_offset        byte color - template
position_offset     byte position - template
direction_offset    byte direction - template
on_char_offset      byte on_char_template - template
on_color_offset     byte on_color_template - template
clock_offset        byte t_clock - template
clock_update_offset byte clock_updates - template
health_offset       byte health - template
damage_offset       byte damage - template
entity_offset       byte entities - drawables
bullet_offset       byte bullets - entities
music_offset        byte music - entities
AI_offset           byte AIs - entities
mp1offset           byte music_player_3 - entities
mp2offset           byte music_player_2 - entities
mp3offset           byte music_player_1 - entities
tracki_offset       byte track_index - music_template
notei_offset        byte note_index - music_template
length_offset       byte song_length - song_template
track_offset        byte song_notes - song_template
state_offset        byte state - template
max_state_offset    byte max_state - template
level_size          byte level_end - level_start
graphics_size       byte end_graphics - graphics