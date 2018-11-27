updateSpawner
    txa 
    pha
    jsr checkClock
    cmp #0
    beq NoSpawn
    ldx #0
SpawnAIs
    txa
    asl
    jsr loadAI2
    lda $fd
    cmp #0
    beq AIsSpawned
    ldy type_offset
    lda ($fc),y
    cmp #3
    bne NoAIForSpawn
    ldy active_offset
    lda ($fc),y
    bne AIActive
    jsr spawnEntity
    jmp AIsSpawned
AIActive
NoAIForSpawn
    inx
    jmp SpawnAIs
AIsSpawned
NoSpawn
    pla
    tax
    rts
    
loadSpawner
    clc
    adc spawner_offset
    jmp loadEntity
    
    
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
    
copyOn
    ldy on_char_offset
    lda ($fc),y
    sta ($fe),y
    ldy on_color_offset
    lda ($fc),y
    sta ($fe),y
    rts