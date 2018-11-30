updateEntities
    txa
    pha
    ldx #0
UpdateEntity
    txa
    jsr loadEntity
    lda $ff
    beq EntitiesUpdated
    jsr checkClock
    beq NotReadyForUpdate
    ldy active_offset
    lda ($fe),y
    beq NotReadyForUpdate
    jsr updateEntity
DontDraw
NotReadyForUpdate
    inx
    jmp UpdateEntity
EntitiesUpdated
    pla 
    tax
    rts

updateEntity
    ldy type_offset
    lda ($fe),y
    cmp #2 
    beq UpdatePlayer
    cmp #3 
    beq UpdateAI
    cmp #4 
    beq UpdateBullet
    cmp #5 
    beq UpdateSpawner
    cmp #6
    beq UpdateHealthbar
    cmp #7
    beq UpdateCapturePoint
    cmp #8 
    beq UpdateMusic
    rts
    
UpdatePlayer
    jmp updatePlayer
UpdateAI
    jmp updateAI
UpdateBullet
    jmp updateBullet
UpdateSpawner
    jmp updateSpawner
UpdateHealthbar
    jmp updateHealthbar
UpdateCapturePoint
    jmp updateCapturePoint
UpdateMusic
    jmp updateMusic

updatePlayer
    jsr drawEntityOn
    jsr move
    jsr shoot
    jsr checkCollision
    jsr handleCollision
    jsr drawEntity
    rts
    
updateAI
    jsr setDirection
    jsr checkShot
    jsr updatePlayer
    rts
    
updateBullet
    jsr drawEntityOn
    jsr setBullet
    jsr move
    jsr checkCollision
    jsr handleCollision
    jsr drawEntity
    rts
    
updateSpawner
    jsr spawnNextEntity
    jsr drawEntity
    rts
    
updateHealthbar
    jsr drawHealthBar
    rts
    
updateCapturePoint
    jsr checkIfCapturing
    jsr drawCaptureBar
    rts
    
updateMusic
    jsr loadSong            
    jsr loadNote           
    jsr storeNote           
    jsr updateNote
    rts
    