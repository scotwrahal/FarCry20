; may want to make the spawners more random than a queue
spawnNextEntity
    txa 
    pha
    ldx #0
SpawnAIs
    txa
    jsr loadAI2
    lda $fd
    beq AIsSpawned          ; there are no entities to spawn
    ldy #active_offset
    lda ($fc),y
    bne AIActive            ; only spawn non active entities
    ldy #type_offset
    lda ($fc),y
    cmp #3
    bne AIsSpawned
;select Spawner
    lda $ff
    pha
    lda $fe
    pha
    jsr rnd
    and #$03
    jsr loadSpawner
    jsr spawnEntity
;deselect Spawner
    pla
    sta $fe
    pla 
    sta $ff
    jmp AIsSpawned
AIActive
    inx
    jmp SpawnAIs
AIsSpawned
    jsr drawEntity
    pla
    tax  
    rts
    
loadSpawner
    asl 
    tay 
    lda spawners,y
    sta $fe
    iny
    lda spawners,y
    sta $ff
    rts
    
spawnEntity
    ldy #active_offset       ; check to see if the thing u are tyring to spawn is active
    lda ($fc),y
    beq Spawn
    rts
Spawn
    jsr flipEntities
    jsr resetEntity
    jsr flipEntities
    
    ldy #active_offset
    lda #1                  ; make it active
    sta ($fc),y

    ldy #position_offset
    lda ($fe),y
    sta ($fc),y
    iny 
    lda ($fe),y
    sta ($fc),y
    iny 
    lda ($fe),y
    sta ($fc),y
    
    
    ldy #direction_offset
    lda ($fc),y
    and #$04
    ora #1
    ora ($fe),y
    sta ($fc),y
    
    ldy #on_char_offset
    lda ($fe),y
    sta ($fc),y
    
    ldy #on_color_offset
    lda ($fe),y
    sta ($fc),y

    jsr flipEntities
    lda $fc
    pha
    lda $fd
    pha 
    jsr updateEntity
    pla
    sta $fd
    pla
    sta $fc
    jsr flipEntities
NoSpawn
    rts
    
despawn
    jsr drawEntityOn        ; draw what it is standing on

    ldy #type_offset
    lda ($fe),y
    cmp #3
    bne NotAIDeath
    
    jsr rnd
    and #$01
    bne NotAIDeath
    
    lda $fc
    pha
    lda $fd
    pha
    lda #capture_point_offset
    jsr loadEntity2             ; load the player into fc
    ;compare the character that the player is on to the capture character
    ldy #on_char_offset         
    lda ($fe),y
    cmp ($fc),y 
    beq OnCapturing
    jsr drawHealthpack
OnCapturing
    pla
    sta $fd
    pla
    sta $fc
NotAIDeath
    jsr resetEntity
    rts