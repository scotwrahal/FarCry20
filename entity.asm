; TODO make a list of functions

setEntityClocks
    ldx #0              ; index
SetEntityClocks
    txa
    asl                 ; multiply by 2 because they are addresses
    jsr loadEntity
    lda $ff             ; load the page number of the entity
    cmp #0              ; no entitys are on pg 0
    beq EntityClocksSet ; so break out of the loop
    jsr setClock        ; sets the entity clock to the current clock
    inx                 ; increase the index
    jmp SetEntityClocks
EntityClocksSet
    rts
    
drawAllEntitys
    ;loop entitys
    ldx #0              ; index for the list of entitys
    lda #0              ; entity type
    pha
DrawEntity
    txa
    asl                 ; multiply by 2 for address
    jsr loadEntity
    lda $ff
    cmp #0              ; check for end of entity type
    beq DrawEntityDone
    jsr drawEntity
    inx
    jmp DrawEntity
DrawEntityDone
    pla
    clc
    adc #1              ; advance entity type
    cmp #3              ; 3 entities 
    beq DrawingDone
    pha
    inx
    jmp DrawEntity
DrawingDone
    rts
    
handleEntityCollision
    pla
    cmp #1
    beq EntityTerrain
    cmp #2
    beq EntityPlayer
    cmp #3
    beq EntityAI
    cmp #4
    beq EntityBullet
    rts
    
EntityBullet
    jsr flipEntitys
    jsr damage
    jsr despawn
    jsr flipEntitys
    jsr copyOn
    rts
EntityAI
EntityPlayer
    ;jsr damage
EntityTerrain
    jsr terrainCollide
    rts
    
copyOn
    ldy on_char_offset
    lda ($fc),y
    sta ($fe),y
    ldy on_color_offset
    lda ($fc),y
    sta ($fe),y
    rts
    
flipEntitys
    lda $fe
    sta holder
    lda $fc
    sta $fe
    lda holder
    sta $fc
    lda $ff
    sta holder
    lda $fd
    sta $ff
    lda holder
    sta $fd
    rts

terrainCollide    
    pha
    txa
    pha
    tya
    pha
    ldy direction_offset
    lda ($fe),y
    asl                     ; shift through the bits to get the direction
    bcs CollideMoveDown
    asl
    bcs CollideMoveUp
    asl
    bcs CollideMoveRight
    asl
    bcs CollideMoveLeft
    
CollideMoveUp
    jsr moveUp
    jmp FinishMove
    
CollideMoveDown
    jsr moveDown
    jmp FinishMove
    
CollideMoveLeft
    jsr moveLeft
    jmp FinishMove
    
CollideMoveRight
    jsr moveRight
    jmp FinishMove


updateEntities
    ldx #0
UpdateEntity
    txa
    asl
    jsr loadEntity
    lda $ff
    cmp #0
    beq EntitiesUpdated
    jsr updateEntity
    inx
    jmp UpdateEntity
EntitiesUpdated
    rts

updateEntity
    pha
    tya
    pha
    txa
    pha
    ldy health_offset
    lda ($fe),y
    bpl Update
    jsr despawn
    jmp NoUpdate
Update
    jsr checkClock
    cmp #0
    beq NoTimeBasedUpdates
    ldy active_offset
    lda ($fe),y
    beq NotActive
    jsr move
    jsr checkCollision
    jsr handleCollision
    jsr shoot
NotActive
NoTimeBasedUpdates
NoUpdate
    pla
    tax
    pla
    tay
    pla
    rts
    
shoot   
    ldy direction_offset
    lda ($fe),y
    and #$08
    beq NoShoot
    lda ($fe),y
    and #$04
    bne NoShoot
    lda ($fe),y         ; make it so that you are not shooting
    and #$f7            ; 111110111
    sta ($fe),y
    ldy bullet_index_offset
    lda ($fe),y
    asl 
    jsr loadBullet2
    jsr spawnEntity
NoShoot
    rts
    
setClock
    lda clock
    clc
    adc #1
    ldy clock_offset
    sta ($fe),y
    rts

loadEntity
    clc
    adc entity_offset
    jmp loadDrawable

loadEntity2
    tay
    lda entities,y
    sta $fc
    iny
    lda entities,y
    sta $fd
    rts

drawEntity
    pha
    txa
    pha
    tya
    pha
    ldy state_offset
    lda ($fe),y
    asl
    asl
    pha
    jsr getDirection
    sta holder
    pla
    clc
    adc holder
    sta holder
    pha
    ldy char_offset
    lda ($fe),y
    clc
    adc holder
    sta ($fe),y
    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    jsr draw
    pla
    sta holder
    ldy char_offset
    lda ($fe),y
    sec
    sbc holder
    sta ($fe),y
    pla
    tay
    pla
    tax
    pla
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

    ldy direction_offset
    lda ($fe),y             ; load the direction into A
    lsr
    php
    asl
    sta ($fe),y
    plp
    bcc noMove
    
    ldy position_offset     ; load in the old position
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    jsr drawOn              ; draw the thing you were on in the old position

;update the state
    ldy state_offset
    lda ($fe),y
    clc
    adc #1
    sta holder
    ldy max_state_offset
    lda ($fe),y
    cmp holder
    bne skip
    lda #0
    jmp restore
skip
    lda holder
restore
    ldy state_offset
    sta ($fe),y

    ldy direction_offset
    lda ($fe),y
    asl                     ; shift through the bits to get the direction
    bcs EntitymoveUp
    asl
    bcs EntitymoveDown
    asl
    bcs EntitymoveLeft
    asl
    bcs EntitymoveRight
noMove
; set to the idle state 
    lda #0
    ldy state_offset
    sta ($fe),y
    jmp EndMove             ; if there is no direction then it doesn't move
    
    
EntitymoveUp
    jsr moveUp
    jmp FinishMove
    
EntitymoveDown
    jsr moveDown
    jmp FinishMove
    
EntitymoveLeft
    jsr moveLeft
    jmp FinishMove
    
EntitymoveRight
    jsr moveRight
    jmp FinishMove
    
FinishMove
    ldy position_offset
    iny                         ; store the thing you are now standing on
    lda ($fe),y
    dey
    tax
    lda ($fe),y
    jsr getFromPosition
    ldy on_char_offset
    sta ($fe),y
    txa
    ldy on_color_offset
    sta ($fe),y
EndMove
    pla
    tay
    pla
    tax
    pla
    rts


    
; moveUp is commented the others moves follow similar logic
moveUp
    ldy position_offset
    iny
    lda ($fe),y
    sec
    sbc #22                 ; move by one row
    bcc MoveUpBorder        ; check the upper lower border
    sta ($fe),y             ; if  didn't, store the new locaiton
    dey 
    lda ($fe),y
    sec
    sbc #1                  ; decrement the row
    sta ($fe),y
    rts
MoveUpBorder
    ldy position_offset
    lda ($fe),y
    and #$80                ; only use the top bit
    beq NoMoveUp            ; in the top cant move up
    lda ($fe),y
    and #$7f                ; clear top bit
    sec
    sbc #1                  ; decrement the row
    sta ($fe),y             ; save the new position
    iny
    lda ($fe),y
    sec
    sbc #22                 ; move up one row
    sta ($fe),y             ; save new position
NoMoveUp
    rts
    
moveDown
    ldy position_offset
    iny
    lda ($fe),y
    clc
    adc #22
    bcs MoveDownBorder
    sta ($fe),y
    dey 
    lda ($fe),y
    clc
    adc #1                  ; increment the row
    sta ($fe),y
    rts
MoveDownBorder
    ldy position_offset
    lda ($fe),y
    and #$80
    bne NoMoveDown
    lda ($fe),y
    ora #$80                ; set the position
    clc
    adc #1                  ; increment the row
    sta ($fe),y
    iny
    lda ($fe),y
    clc
    adc #22
    sta ($fe),y
NoMoveDown
    rts
    
moveLeft
    ldy position_offset
    iny
    lda ($fe),y
    sec
    sbc #1
    bcc MoveLeftBorder
    sta ($fe),y
    rts

MoveLeftBorder
    ldy position_offset
    lda ($fe),y
    and #$80
    beq NoMoveLeft
    lda ($fe),y
    and #$7f
    sta ($fe),y
    iny
    lda #$ff
    sta ($fe),y
NoMoveLeft
    rts
    
moveRight
    ldy position_offset
    iny
    lda ($fe),y
    clc
    adc #1
    bcs MoveRightBorder
    sta ($fe),y
    rts
MoveRightBorder
    ldy position_offset
    lda ($fe),y
    and #$80
    bne NoMoveRight
    lda ($fe),y
    ora #$80
    sta ($fe),y
    iny
    lda #0
    sta ($fe),y
NoMoveRight
    rts

drawOn
    pha
    tya
    pha
    txa
    pha

    ldy on_char_offset
    lda ($fe),y
    sta on_char
    ldy on_color_offset
    lda ($fe),y
    sta on_color

    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y

    ldy on_holder_offset
    jsr drawDrawable
    pla
    tax
    pla
    tay
    pla
    rts
    

; fc is the entity to spawn
; fe is the spawning entity
spawnEntity
    ldy active_offset       ; check to see if the thing you are tyring to spawn is active
    lda ($fc),y
    beq Spawn
    rts
Spawn
    lda #1
    sta ($fc),y

    ldy position_offset
    lda ($fe),y
    sta ($fc),y
    iny 
    lda ($fe),y
    sta ($fc),y
    
    ldy direction_offset
    lda ($fe),y
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
    rts    
    
despawn
    ldy active_offset       ; set it to not active
    lda ($fe),y
    bne Despawn
    rts
    
Despawn
    lda #0
    sta ($fe),y
    jsr drawOn              ; draw what it is standing on
    
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
    
    