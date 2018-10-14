;ek_test3.asm
;Plays notes from the C major scale. User may change the music note being played by pressing the following keys:
; 'C','D','E','F','G','A','B'
;Press 'Q' to exit the program
	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234	
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 in ascii (beginning of assembly code)
	dc.b 		0                   ;null terminator for SYS statement  
end_basic
	dc.w		0					;indicating end of BASIC stub	
start
	lda #$0f		;load 15 (max volume) into Accumulator
	sta $900e		;set max volume
loop0
	lda $00c5		;get char pressed down -- Music notes taken from VIC-20 Programmer's Guide p. 97
	cmp #34	;C
	beq	playc
	cmp #18	;D
	beq	playd
	cmp #49	;E --typo in book p 179
	beq	playe
	cmp #42	;F
	beq	playf
	cmp #19	;G
	beq	playg
	cmp #17	;A
	beq	playa
	cmp #35	;B
	beq	playb
	cmp #48 ;Q (quit)
	beq exit
	jmp loop0
	
playc
	lda #135		;load 135 into Accumulator (low C note)
	jmp playnote
playd
	lda #147		;load 147 into Accumulator (low D note)
	jmp playnote
playe
	lda #159		;load 159 into Accumulator (low E note)
	jmp playnote
playf
	lda #163		;load 163 into Accumulator (low F note)
	jmp playnote
playg
	lda #175		;load 175 into Accumulator (low G note)
	jmp playnote
playa
	lda #183		;load 183 into Accumulator (low A note)
	jmp playnote
playb
	lda #191		;load 191 into Accumulator (low B note)
	jmp playnote

playnote
	sta $900a		;play note
	jmp loop0		;restart character input loop
	
exit
	lda #$00		;load 0 (min volume) into Accumulator
	sta $900e		;set min volume
	rts				;quit
