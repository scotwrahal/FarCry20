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
    cmp #0
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

; drawTerrain
; A: top/bottom bit 0; = top
; X: position
drawTerrain
    sta holder
    pha
    tya
    pha
    ldy terrain_offset
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
    lda holder
    jsr drawDrawable
    pla
    tay
    pla
    rts

; drawTerrain
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
    ldy position_offset
    iny
    lda ($fe),y 
    tax
    dey 
    lda ($fe),y 
    jsr draw
    pla
    tay
    pla
    tax
    pla
    rts
    
drawOn
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
    pha
    ldy on_offset
    lda ($fe),y
    tay
    pla
    jsr drawDrawable
    pla
    tax
    pla
    tay
    pla    
    rts
    
animate
	pla
	sta return_add_hi
	pla
	sta return_add_low
	pla
	sta num_frames
	pla
    
	sta graphic_offset
	lda jason_animation_state
	adc graphic_offset
	sta player_char				;assign new image
	sbc graphic_offset						;remove offset
	ldx num_frames
	cmp num_frames						
	bne StoreNoReset
	sbc #1
	sbc num_frames
StoreNoReset
	adc #1
	sta jason_animation_state
    
	lda return_add_low
	pha
	lda return_add_hi
	pha
	rts