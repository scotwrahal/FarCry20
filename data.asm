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

bullet
bullet_up       byte $00, $00 ,$08, $18, $18, $00, $00, $00
bullet_down     byte $00, $00 ,$00, $18, $18, $10, $00, $00
bullet_left     byte $00, $00 ,$00, $38, $18, $00, $00, $00
bullet_right    byte $00, $00 ,$00, $1c, $18, $00, $00, $00

palm_tree0:     byte $00, $7c, $b2, $28, $48, $08, $0c, $1f
shrub0:         byte $00, $4c, $28, $1d, $2a, $1c, $08, $1c
shrub1:         byte $0, $2a, $ac, $a9, $99, $5a, $3c, $1c
shrub2:         byte $0, $2a, $ac, $a9, $99, $5a, $3c, $1c
end_graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
holder          byte $00
clock           byte $00
random1         byte $55         
random2         byte $cc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITY LIST ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawables:
terrain     word terrain_char
terrain1    word terrain1_char
ground      word ground_char
ground1     word ground1_char
on_holder   word on_char
            word 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UPDATABLE ENTITY LIST ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THESE EXTEND DRAWABLE
; this list also controls the order for updates
entities:
player      word player_char

AIs:
AI1         word AI1_char
AI2         word AI2_char

bullets:
bullet0     word bullet0_char

spawners:
spawner0    word spawner0_char

special:
healthbar     word healthbar_char
capture_point word capture_point_char



;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUSIC PLAYER LIST;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THESE ARE UPDATABLE BUT NOT DRAWABLE
music:
music_player_1  word music1_track
                word #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITIES DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
terrain_char    byte [palm_tree0 - graphics]/8+2
terrain_color   byte $00 ; black 

terrain1_char   byte [shrub0 - graphics]/8+2
terrain1_color  byte $00 ; black 


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
type 
player_type             byte #2
active
player_active           byte $01
position
player_position         byte #2, #50, #6        ; 1 tells u if u are in the top or bottom 0 nothing 111111 row number, position byte
direction
player_direction        byte $80            ; bits 1111 direction 11 shooing 1 Active 1 movement
on_char_template
player_on_char          byte [shrub1 - graphics]/8+2
on_color_template
player_on_color         byte $05
damage_
player_damage           byte $7f
health
player_health           byte $7f
state
player_state            byte $00
max_state
player_max_state        byte $03
bullet_index
player_bullet_index     byte #0

AI1_char                byte [human - graphics]/8+2
AI1_color               byte $02
AI1_clock               byte $00
AI1_clock_updates       byte #14
AI1_type                byte #3
AI1_active              byte $00
AI1_position            byte $80, $ff, $00
AI1_direction           byte $00
AI1_on                  byte [shrub1 - graphics]/8+2, $05
AI1_damage              byte 0
AI1_health              byte $7f
AI1_state               byte $00
AI1_max_state           byte $03
AI1_bullet_index        byte #1

AI2_char                byte [human - graphics]/8+2
AI2_color               byte $02
AI2_clock               byte $00
AI2_clock_updates       byte #14
AI2_type                byte #3
AI2_active              byte $00
AI2_position            byte $80, $ff, $00
AI2_direction           byte $00
AI2_on                  byte [shrub1 - graphics]/8+2, $05
AI2_damage              byte 0
AI2_health              byte $7f
AI2_state               byte $00
AI2_max_state           byte $03
AI2_bullet_index        byte #1

bullet0_char            byte [bullet - graphics]/8+2
bullet0_color           byte $00
bullet0_clock           byte $00
bullet0_clock_updates   byte $05
bullet0_type            byte #4
bullet0_active          byte $00
bullet0_position        byte $80, $ff, $00
bullet0_direction       byte $40
bullet0_on              byte 0, 0
bullet0_damage          byte $7f
bullet0_health          byte $7f
bullet0_state           byte $00
bullet0_max_state       byte $01

spawner0_char            byte [bullet - graphics]/8+2
spawner0_color           byte $00
spawner0_clock           byte $00
spawner0_clock_updates   byte $01
spawner0_type            byte #5
spawner0_active          byte $01
spawner0_position        byte #01, #23, #01
spawner0_direction       byte $40
spawner0_on              byte [shrub1 - graphics]/8+2, $05
spawner0_damage          byte 0
spawner0_health          byte $7f
spawner0_state           byte $00
spawner0_max_state       byte $01

healthbar_char                byte [human - graphics]/8+2
healthbar_color               byte $02
healthbar_clock               byte $00
healthbar_clock_updates       byte #10
healthbar_type                byte #6
healthbar_active              byte $01
healthbar_position            byte $80, $e4, $00
healthbar_direction           byte $00 ; unused
healthbar_on                  byte [shrub1 - graphics]/8+2, $05
healthbar_damage              byte $00 ; unused
healthbar_health              byte $7f
healthbar_state               byte $00
healthbar_max_state           byte $01

capture_point_char                byte [shrub2 - graphics]/8+2
capture_point_color               byte $00
capture_point_clock               byte $00
capture_point_clock_updates       byte #10
capture_point_type                byte #7
capture_point_active              byte $01
capture_point_position            byte #10, #225, $00
capture_point_direction           byte $00
capture_point_on                  byte [shrub2 - graphics]/8+2, $01
capture_percent                   byte 0
capture_point_health              byte $7f
capture_point_state               byte $00
capture_point_max_state           byte $01

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUSIC PLAYERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
music_template
track_index
music1_track           byte $00
note_index
music1_index           byte $00
music_clock                         ; this mathces up with other entity clocks
music1_clock           byte $00
music1_clock_updates   byte $01
music1_type            byte #8
music1_active          byte #1
channel
music1_channel         byte #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEVEL MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    byte [song0_end - song0_notes]/2, $00
song_notes
song0_notes
    ;     duration note
    byte #12, #231
    byte #12, #222
    byte #12, #231
    byte #12, #206
    byte #12, #231
    byte #12, #206
    byte #12, #218
    byte #12, #206
    byte #12, #229
    byte #12, #231
    byte #12, #220
    byte #12, #206
    byte #12, #181
    byte #12, #206
    byte #12, #218
    byte #12, #206
song0_end

song1_length
    byte  [song1_end - song1_notes]/2 , $00
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

terrain_offset      byte [terrain - drawables]/2
ground_offset       byte [ground - drawables]/2
on_holder_offset    byte [on_holder - drawables]/2
char_offset         byte char - template
color_offset        byte color - template
position_offset     byte position - template
direction_offset    byte direction - template
on_char_offset      byte on_char_template - template
on_color_offset     byte on_color_template - template
clock_offset        byte t_clock - template
clock_update_offset byte clock_updates - template
health_offset       byte health - template
capture_percent_offset byte damage_ - template
damage_offset       byte damage_ - template
entity_offset       byte [entities - drawables]/2
bullet_offset       byte [bullets - entities]/2
music_offset        byte [music - entities]/2
AI_offset           byte [AIs - entities]/2
spawner_offset      byte [spawners - entities]/2
length_offset       byte song_length - song_template
track_offset        byte song_notes - song_template
state_offset        byte state - template
max_state_offset    byte max_state - template
level_size          byte level_end - level_start
graphics_size       byte end_graphics - graphics
active_offset       byte active - template
bullet_index_offset byte bullet_index - template
type_offset         byte type - template
tracki_offset       byte track_index - music_template
notei_offset        byte note_index - music_template
channel_offset      byte channel - music_template
entity_count        byte #4
AI_health           byte #60
player_offset       byte [player - entities]/2
capture_point_offset byte [capture_point  - entities]/2