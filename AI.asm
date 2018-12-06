; loads the Ath AI entity into fc (Ath mean the number in A)
loadAI2
    asl
    tay
    lda AIs,y
    sta $fc
    iny
    lda AIs,y
    sta $fd
    rts

; checks to see if the entity is trying to shoot
; the entity to be checked is stored in ($fe)
checkShot
    ldy #direction_offset
    lda ($fe),y
    and #ShootMask      
    beq NotShooting
    lda ($fe),y
    and #UnableToShootMask
    bne NotShooting
    lda ($fe),y
    and #InvertedUnableMask
    sta ($fe),y
NotShooting
    rts

; sets the entitys position to be towards the player
; the entity to be set is stored in ($fe)
setDirection
    ldy #direction_offset
    lda ($fe),y
    ; save if the entity was moving up or down
    and #UpDownMask
    php
    
    ; reset the direction except the part that says if you can shoot
    lda ($fe),y
    and #UnableToShootMask
    sta ($fe),y

    ; load the player into fc
    lda #player_offset
    jsr loadEntity2

    ; check if it was moving up or down to alternate between up/down
    plp
    beq CheckRows
    
    ; all of these branches return from the function
CheckColumns    
    jsr checkColumns
    bmi SetLeft
    bne SetRight
    jsr setShoot    ; if you are equal then try to shoot

CheckRows
    jsr checkRows
    bmi SetUp
    bne SetDown
    jsr setShoot
    
    jmp CheckColumns ; since you can't be ontop of them then you won't get stuck

SetUp
    ldy #direction_offset
    lda #[UpMask & MoveMask]
    ora ($fe),y
    sta ($fe),y
    rts

SetDown
    ldy #direction_offset
    lda #[DownMask & MoveMask]
    ora ($fe),y
    sta ($fe),y
    rts
    
SetLeft
    ldy #direction_offset
    lda #[LeftMask & MoveMask]
    ora ($fe),y
    sta ($fe),y
    rts

SetRight
    ldy #direction_offset
    lda #[RightMask & MoveMask]
    ora ($fe),y
    sta ($fe),y
    rts
    
setShoot
    ldy #direction_offset
    lda #ShootMask
    ora ($fe),y
    sta ($fe),y
    rts

; checks the position of the entities in the fc and fe and returns as follows
; returns -1 if fe is to the left  of fc
; returns  0 if fe is in the same  as fc
; returns  1 if fe is to the right of fc
checkColumns
    ldy #position_offset
    iny
    iny
    lda ($fc),y
    cmp ($fe),y
    bmi LeftColumn
    beq SameColumn
    lda #1
    rts
LeftColumn
    lda #$ff    ; -1
    rts
SameColumn
    lda #0
    rts
    
    
; checks the position of the entities in the fc and fe and returns as follows  
; returns -1 if fe is above fc
; returns  0 if fe is same  fc
; returns  1 if fe is below fc   
checkRows
    ldy #position_offset
    lda ($fe),y
    and #RowMask
    sta holder
    lda ($fc),y
    and #RowMask
    cmp holder
    bmi UpRow
    beq SameRow
DownRow 
    lda #1
    rts
UpRow
    lda #$ff    ; -1
    rts
SameRow
    lda #0
    rts