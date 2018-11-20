
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
holder          byte $00

last_input      byte $00

new_position    byte $00, $00
	
return_add_hi   byte $00
	
return_add_low  byte $00

graphic_offset  byte $00

num_frames      byte $00

clock           byte $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawables:
terrain     word terrain_char
ground      word ground_char

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UPDATABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THESE EXTEND DRAWABLE
entities:
player      word player_char

enemys:
enemy1      word enemy1_char
enemy2      word enemy2_char
    
bullets:
bullet1     word bullet1_char
            word 0              ; terminator for list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUSIC PLAYERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THESE ARE UPDATABLE BUT NOT DRAWABLE
music:
music_player_1  word track_index_1
music_player_2  word track_index_2
music_player_3  word track_index_3
                word 0
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DRAWABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
terrain_char    byte #14
terrain_color   byte $00


ground_char     byte #16
ground_color    byte $05

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UPDATABLE ENTITIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
template
char
player_char             byte $02
color
player_color            byte $06
position
player_position         byte $00, #23
direction
player_direction        byte $00
tmeplate_on
player_on               byte $00
t_clock
player_clock            byte $00
clock_updates
player_clock_updates    byte $07

enemy1_char             byte #2
enemy1_color            byte $08
enemy1_position         byte $00, #46
enemy1_direction        byte $00
enemy1_on               byte $00
enemy1_clock            byte $00
enemy1_clock_updates    byte $03
    
enemy2_char             byte #2
enemy2_color            byte $07
enemy2_position         byte $00, #68
enemy2_direction        byte $00
enemy2_on               byte $00
enemy2_clock            byte $00
enemy2_clock_updates    byte $05

bullet1_char            byte #2
bullet1_color           byte $07
bullet1_position        byte $00, #68
bullet1_direction       byte $00
bullet1_on              byte $00
bullet1_clock           byte $00
bullet1_clock_updates   byte $05

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUSIC PLAYERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
music_template
track_index
track_index_1           byte $00
note_index
note_index_1            byte $01
    
track_index_2           byte $01
note_index_2            byte $01

track_index_3           byte $01
note_index_3            byte $01
    
music_clock_1           byte $00
music_clock_updates_1   byte $01

music_clock_2           byte $00
music_clock_updates_2   byte $01

music_clock_3           byte $00
music_clock_updates_3   byte $01


graphics:
jason_right0:
    byte $18, $18, $13, $3e, $58, $18, $34, $46
jason_right1:
	byte $18, $18, $13, $3e, $38, $18, $28, $2c
jason_right2:
	byte $18, $18, $13, $1e, $18, $18, $10, $18
jason_left0:
	byte $18, $18, $c8, $7c, $1a, $18, $2c, $62
jason_left1:
	byte $18, $18, $c8, $7c, $1c, $18, $14, $34
jason_left2:
	byte $18, $18, $c8, $78, $18, $18, $08, $18
jason_up0:
	byte $1a, $1a, $1a, $3c, $58, $18, $18, $10
jason_up1:
	byte $1a, $1a, $1a, $3c, $38, $18, $18, $00
jason_up2:
	byte $1a, $1a, $1a, $3c, $58, $18, $18, $08
jason_down0:
	byte $18, $18, $18, $3c, $5a, $58, $58, $08
jason_down1:
	byte $18, $18, $18, $3c, $5c, $58, $58, $00
jason_down2:
	byte $18, $18, $18, $3c, $5a, $58, $58, $10
jaguar_right0:
    byte $02, $43, $43, $9e, $7f, $66, $62, $a1
palm_tree0:
    byte $1a, $7c, $b2, $28, $48, $08, $0c, $1f
shrub0:
    byte $0a, $4c, $28, $1d, $2a, $1c, $08, $1c
shrub1:
    byte $28, $2a, $ac, $a9, $99, $5a, $3c, $1c
	
jason_animation_state:
	byte $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEVEL MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ideally to be stored on a disk and loaded in later
level_mem
    word level0
    word level1
    word level2

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


level1
    byte $00, $00, $00
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $ff, $f8
    byte $7f, $f0, $f8
    byte $7f, $f0, $f8
    byte $7f, $f0, $f8
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
    byte $00, $00, $00

level2
    byte $00, $00, $00 
    byte $7f, $ff, $f8 
    byte $7f, $ff, $f8 
    byte $7f, $ff, $f8 
    byte $67, $fb, $f8 
    byte $77, $f9, $f8 
    byte $7b, $fd, $f8 
    byte $7b, $fd, $f8 
    byte $7d, $fe, $f8 
    byte $7e, $fe, $f8 
    byte $7e, $7e, $f8 
    byte $7f, $3e, $f8 
    byte $7f, $9e, $78 
    byte $7f, $df, $f8 
    byte $7f, $ff, $f8 
    byte $7f, $ff, $e8 
    byte $73, $ff, $98 
    byte $78, $01, $38 
    byte $7f, $fc, $78 
    byte $7f, $ff, $f8 
    byte $7f, $ff, $f8 
    byte $00, $00, $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOUND MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
song_memory
song0    word song0_length
song1    word song1_length

track_template
track_length
song0_length
    byte #20, $00    ; number of notes plus one
track_notes
song0_notes
    ;     duration note
    byte #5, #135
    byte #5, #147
    byte #5, #159
    byte #5, #167
    byte #5, #179
    byte #5, #187
    byte #5, #195
    byte #5, #201
    byte #5, #207
    byte #5, #212
    byte #5, #217
    byte #5, #221
    byte #5, #225
    byte #5, #228
    byte #5, #231
    byte #5, #233
    byte #5, #235
    byte #5, #237
    byte #5, #239
    byte #5, #241
    
song1_length
    byte #20, $00    ; number of notes plus one
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
    
;;;;;;;;; TODO LOOK FOR A WAY TO CALCULATE THESE 
terrain_offset      byte #0; = terrain - drawables
ground_offset       byte #2; = ground - drawables
char_offset         byte #0; = char - template
color_offset        byte #1; = color - template
position_offset     byte #2; = position - template
direction_offset    byte #4; = direction - template
on_offset           byte #5; = on - template
clock_offset        byte #6; = clock - template
clock_update_offset byte #7; = clock_updates - template
entity_offset       byte #4; = entities - drawables
bullet_offset       byte #6; = bullets - entities
mp1offset           byte #10; = music_player_3 - entities
mp2offset           byte #12; = music_player_2 - entities
mp3offset           byte #14; = music_player_1 - entities
track_offset        byte #0; = track_index - music_template
note_offset         byte #1; = note_index - music_template
length_offset       byte #0; = track_length - track_template