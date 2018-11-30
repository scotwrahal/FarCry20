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
    ldy type_offset
    lda ($fc),y
    cmp #3
    bne AIsSpawned          ; all the AIs are together so when you stop reading them you are done
    ldy active_offset
    lda ($fc),y
    bne AIActive            ; only spawn non active entities
    jsr spawnEntity
    jmp AIsSpawned
AIActive
    inx
    jmp SpawnAIs
AIsSpawned
    jsr drawEntity
    pla
    tax  
    rts
    

; fc is the entity to spawn
; fe is the spawning entity
spawnEntity
    ldy active_offset       ; check to see if the thing you are tyring to spawn is active
    lda ($fc),y
    beq Spawn
    rts
Spawn
    lda #1                  ; make it active
    sta ($fc),y

    ldy position_offset
    lda ($fe),y
    sta ($fc),y
    iny 
    lda ($fe),y
    sta ($fc),y
    iny 
    lda ($fe),y
    sta ($fc),y
    
    
    ldy direction_offset
    lda ($fe),y
    ora #1
    sta ($fc),y
    
    ldy on_char_offset
    lda ($fe),y
    sta ($fc),y
    
    ldy on_color_offset
    lda ($fe),y
    sta ($fc),y
    
    ldy clock_offset
    lda clock
    sta ($fc),y
    
    ldy state_offset
    lda #0
    sta ($fc),y
    
    ldy type_offset
    lda ($fc),y
    cmp #3
    bne NotAI
    ldy health_offset
    lda AI_health
    sta ($fc),y
NotAI
    rts 
    
despawn
    ldy active_offset       ; set it to not active
    lda #0
    sta ($fe),y
    jsr drawEntityOn              ; draw what it is standing on
    
    ldy active_offset       ; set it to not active
    lda #0
    sta ($fe),y

    ldy position_offset     ; move it off the screen
    lda #$80
    sta ($fe),y
    iny 
    lda #$ff
    sta ($fe),y
    rts