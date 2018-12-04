loadDrawable
    sta holder
    tya
    pha
    lda holder
    asl
    tay
    lda drawables,y
    sta $fe
    iny
    lda drawables,y
    sta $ff
    pla
    tay
    lda holder
    rts

; drawTerrain
; A: top/bottom bit 0; = top
; X: position
drawTerrain
    sta holder
    pha
    tya
    pha
    ldy terrain_offset
    jsr rnd
    and #$01
    beq DrawT
    iny
DrawT
    lda holder
    jsr drawDrawable
    pla
    tay
    pla
    rts

; drawGround
; A: top/bottom bit 0; = top
; X: position
drawGround
    sta holder
    pha
    tya
    pha
    ldy ground_offset
    jsr rnd
    and #$01
    beq Draw
    iny
Draw
    lda holder
    jsr drawDrawable
    pla
    tay
    pla
    rts

; drawDrawable
; A: top/bottom bit 0; = top
; X: position
; Y: index
drawDrawable
    sta holder
    lda $ff
    pha
    lda $fe
    pha
    lda holder
    pha
    tya
    jsr loadDrawable
    pla              ; restore the position
    jsr draw
    pla
    sta $fe
    pla
    sta $ff
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
    
getDirection
    ldy direction_offset
    lda ($fe),y
_Up
    asl
    bcc _Down
    lda #0
    rts
_Down
    asl
    bcc _Left
    lda #1
    rts
_Left
    asl
    bcc _Right
    lda #2
    rts
_Right
    asl
    bcc _None
    lda #3
    rts
_None
    lda #$ff
    rts

; draw
;   A: top/bottom location 0 ; = top
;   X: location
;   $fe $ff: thing to draw
draw
    sta holder              ; clear accumulator to store state
    pha
    tya
    pha
    lda holder
    and #$80
    bne DrawBottom
    ldy char_offset
    lda ($fe),y
    sta $1e00,x
    ldy color_offset
    lda ($fe),y
    sta $9600,x
    jmp EndDraw
DrawBottom
    ldy #0
    lda ($fe),y
    sta $1f00,x
    ldy #1
    lda ($fe),y
    sta $9700,x
EndDraw
    pla
    tay
    pla
    rts


; getFromPosition returns the color and the character at a locaiton on the screen
;   A: top/bottom location 0 ; = top
;   X: location
;   return
;   A: character
;   X: color
getFromPosition
    and #$80
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
    
drawEntityOn
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

getFromEntityPosition 
    ldy position_offset
    iny                         ; store the thing u are now standing on
    lda ($fe),y
    dey
    tax
    lda ($fe),y
    jsr getFromPosition
    rts

drawHealthpack
    pha
    tya
    pha
    txa
    pha

    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    
    ldy healthpack_offset
    jsr drawDrawable
    pla
    tax
    pla
    tay
    pla
    rts 
    
removeHeal
    pha
    tya
    pha
    txa
    pha

    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y
    
    jsr drawGround
    jsr storeOnScreenInEntity
    
    pla
    tax
    pla
    tay
    pla
    rts 

storeOnScreenInEntity 
    ldy position_offset
    iny
    lda ($fe),y
    tax
    dey
    lda ($fe),y   
    jsr getFromPosition
    ldy on_char_offset
    sta ($fe),y
    txa
    ldy on_color_offset
    sta ($fe),y
    rts