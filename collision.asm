; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
checkCollision
    ldy on_char_offset
    lda ($fe),y
    cmp terrain_char
    beq CollideTerrain
    cmp terrain1_char
    beq CollideTerrain
    cmp healthpack_char
    beq CollideHealth
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
CollideHealth
    ldy on_color_offset
    lda ($fe),y
    and #$0f
    cmp healthpack_color
    beq CollideHealth2
    jmp Collide
CollideTerrain2
    lda #1              ; terrain collision
    rts
CollideHealth2
    lda #3
    rts
    
Collide
    txa
    pha   
    ;loop entitys
    ldx #0              ; index for the list of entitys
CollideEntity
    txa
    jsr loadEntity2
    lda $fd
    beq CollideEntityDone
    cmp $ff
    bne NotSelf
    lda $fc
    cmp $fe
    beq NextEntity
NotSelf
    jsr checkRows
    bne NextEntity
    jsr checkColumns
    beq CollidedWithEntity
NextEntity
    inx
    jmp CollideEntity
CollidedWithEntity
    pla
    tax
    lda #2
    rts
CollideEntityDone
    pla
    tax
    lda #0
    rts
    
    
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
    
handleAICollision
handlePlayerCollision
    pla 
    cmp #1
    beq EntityTerrain
    cmp #3
    beq EntityHealth
    
    lda ($fc),y
    cmp #2
    beq EntityPlayer
    cmp #3
    beq EntityAI
    cmp #4
    beq EntityBullet
;default
    jmp EntityTerrain
    rts
    
handleBulletCollision
    pla 
    cmp #1
    beq BulletTerrain
    cmp #3
    beq BulletHealth
    
    lda ($fc),y
    cmp #2
    beq BulletPlayer
    cmp #3
    beq BulletAI
    cmp #4
    beq BulletBullet
;default
    jmp BulletTerrain
    rts

BulletTerrain
    jmp despawn
    
BulletBullet
    jsr copyOn
BulletHealth
    rts
BulletAI
BulletPlayer
    jsr despawn
    jsr damage
    rts

EntitySpawner
    rts
EntityBullet
    jsr flipEntities
    jsr damage
    jsr despawn
    jsr flipEntities
    jsr copyOn
    rts
EntityAI
EntityPlayer
    jsr damage
EntityTerrain
    jsr terrainCollide
    rts
EntityHealth
    jsr heal
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
    
    
flipEntities
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
    cmp #0
    bmi Kill
    rts
Kill
    jsr flipEntities
    jsr despawn
    jsr flipEntities
    rts 
    
copyOn
    ldy on_char_offset
    lda ($fc),y
    sta ($fe),y
    ldy on_color_offset
    lda ($fc),y
    sta ($fe),y
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