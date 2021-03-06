;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; loads the level number in A
; $fc tracks the byte
; $ff tracks current bit
; $fd fe will store the level address

; helper functions for  load level
levelLoadDone
    pla
    jsr drawLevel
    jsr reset
    lda #0
    ldy #0
    jmp playSong

; helper function for load level
loadByte
    pha
    tya
    pha
    ldy $fc                 ; load the byte number
    lda ($fd),y
    sta $ff
    iny
    sty $fc
    pla
    tay
    pla
    rts
; helper function for load level
readByte
    asl $ff                 ; get the value for the next bit
    bcs ReadGround          ; branch for terrain and ground
ReadTerrain
    jsr drawTerrain         ; 0 ; equ terrain
    jmp NextBit
ReadGround
    jsr drawGround          ; 1 ; equ ground
NextBit
    clc
    inx             		; increment the position
    bne BoundarySkip        ; boundery check
    lda #$80
BoundarySkip
    dey
    bne readByte            ; repeat till the byte is done
    rts

loadLevel
    lda #0
    asl                 	; multiply by 2 (level address is 2 bytes)
    tay
    lda level_mem,y
    sta $fd
    iny
    lda level_mem,y
    sta $fe

; start at 0 0
    lda #0
    sta $fc             	; store the byte number
    ldx #0
load_row
    pha                     ; push A to preserve the location
    lda $fc
    cmp #level_size          ; check if u have loaded the level
    beq levelLoadDone       ; BREAK out of load
    pla                     ; restore the location

    jsr loadByte
    ldy #8          		; the number of bits in the first byte
    jsr readByte
    jsr loadByte
    ldy #8                  ; the second byte has 8 bits
    jsr readByte
    jsr loadByte
    ldy #6                  ; the 3rd byte has 6 bits
    jsr readByte
    ; this may be where u read the last 2 bits of info for the level
    jmp load_row
; end of loading function