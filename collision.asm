; Check for what is in the new location and determines if it has collided
; right now it only checks if it is the ground of not
check_collision
    pha
    tya
    pha
    lda new_position
    ldy #1
    ldx new_position,y
    jsr getFromPosition     ; gets the character on the screen in the new position
    ; need to make a collide list maybe
    cmp ground_char
    beq NoCollide
    pla
    tay
    pla
    lda #1
    rts
NoCollide
    pla
    tay
    pla
    lda #0
    rts
	
; getFromPosition returns the color and the character at a locaiton on the screen
;   A: top/bottom location 0 ; = top
;   X: location
;   return
;   A: character
;   X: color
getFromPosition
    cmp #0
    bne readBottom
    lda $1e00,x
    pha
    lda $9600,x
    tax
    pla
    rts
readBottom
    lda $1f00,x
    pha
    lda $9700,x
    tax
    pla
    rts