; input take the input and stores it for the player
; sets the lowest byte to one to show that it updated
; stores the old if there is no update
;   may want to make this work for the joystick.
input
    pha
    lda $c5                 ; read scancode
Up
    cmp #9                  ;'W' Scancode
    bne Down
    lda #$81
    jmp InputRetrun
Down
    cmp #41                 ;'S' Scancode
    bne Left
    lda #$41
    jmp InputRetrun
Left
    cmp #17                 ;'A' Scancode
    bne Right
    lda #$21
    jmp InputRetrun
Right
    cmp #18                 ;'D' Scancode
    bne nothin
    lda #$11
    jmp InputRetrun
    ; expand here for more input upto 3 with the same byte
    
nothin
    lda player_direction
InputRetrun
    sta player_direction
    pla
    rts