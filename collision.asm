handleCollision
    ;collide with terrain
    cmp #0              ; nothing
    beq CollidedWithNothing
    pha
    ldy type_offset
    lda ($fe),y
    cmp #2              ; player collisions
    bne Handle1
    jmp handlePlayerCollision
Handle1
    cmp #3              ; enemy collisions
    bne Handle2
    jmp handleAICollision
Handle2
    cmp #4              ; bullet collisions
    bne Handle3
    jmp handleBulletCollision
Handle3
CollidedWithNothing
    rts

; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
checkCollision
    tya
    pha
    ldy on_char_offset
    lda ($fe),y
    cmp terrain_char
    beq CollideTerrain
    cmp terrain1_char
    beq CollideTerrain
    jmp Collide
CollideTerrain
    ldy on_color_offset
    lda ($fe),y
    and #$0f
    cmp terrain_color
    beq CollideTerrain2
    cmp terrain1_color
    beq CollideTerrain2
    jmp Collide
CollideTerrain2
    pla
    tay
    lda #1              ; terrain collision
    rts
    
Collide
    ;loop entitys
    ldx #0              ; index for the list of entitys
CollideEntity
    txa
    asl                 ; multiply by 2 for address
    jsr loadEntity2
    lda $fd
    cmp #0              ; check for end of entity type
    beq CollideEntityDone
    sta holder
    lda $ff
    cmp holder
    bne NotSelf
    lda $fc
    sta holder
    lda $fe
    cmp holder
    beq NextEntity
NotSelf
    jsr checkPositions
    cmp #0
    beq CollidedWithEntity
NextEntity
    inx
    jmp CollideEntity
CollidedWithEntity
    lda #2
    sta holder
    pla
    tay
    lda holder
    rts
CollideEntityDone
    pla
    tay
    lda #0
    rts

; ; inverts the direction of the entity
; invertDirection
    ; pha
    ; tya
    ; pha
    ; ldy direction_offset
    ; lda ($fe),y
    ; sta holder
    ; asl
    ; bcs FlipUD
    ; asl
    ; bcs FlipUD
; FlipLR
    ; lda ($fe),y
    ; eor #$30
    ; jmp EndFlip
; FlipUD
    ; lda ($fe),y
    ; eor #$c0
; EndFlip
    ; sta ($fe),y
    ; pla
    ; tay
    ; pla
    ; rts
    
checkPositions 
    ldy position_offset
    lda ($fe),y
    and #$80
    lsr
    lsr
    sta holder
    lda ($fc),y 
    and #$80
    lsr
    lsr
    cmp holder
    bmi Return1
    bne Return2                     ; is positive
    
    iny
    lda ($fe),y
    lsr                             ; do a right shift to prevent negatives among large differences
    sta holder
    lda ($fc),y
    lsr
    cmp holder
    bmi Return1
    bne Return2
    
    lda ($fe),y
    sta holder
    lda ($fc),y
    cmp holder
    bmi Return1
    bne Return2
Return0
    lda #0
    rts
Return1
    lda #1
    rts
Return2
    lda #2
    rts
    
handleBulletCollision
    pla 
    cmp #1
    beq BulletTerrain
    
    lda ($fc),y
    cmp #2
    beq BulletPlayer
    cmp #3
    beq BulletAI
    cmp #4
    beq BulletBullet
    rts

BulletTerrain
    jmp despawn
BulletBullet
    jsr copyOn
    rts
BulletAI
BulletPlayer
    jsr damage
    jmp despawn
    
handleAICollision
handlePlayerCollision
    pla 
    cmp #1
    beq EntityTerrain
    
    lda ($fc),y
    cmp #2
    beq EntityPlayer
    cmp #3
    beq EntityAI
    cmp #4
    beq EntityBullet
    cmp #5
    beq EntitySpawner
    rts

EntitySpawner
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
    jsr damage
EntityTerrain
    jsr terrainCollide
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
    
damage
    ldy health_offset
    lda ($fc),y
    ldy damage_offset
    sec
    sbc ($fe),y
    ldy health_offset
    sta ($fc),y
    rts
    
copyOn
    ldy on_char_offset
    lda ($fc),y
    sta ($fe),y
    ldy on_color_offset
    lda ($fc),y
    sta ($fe),y
    rts