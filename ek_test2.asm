;ek_test2.asm
	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234	
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 in ascii (beginning of assembly code)
	dc.b 		0                   ;null terminator for SYS statement  
end_basic
	dc.w		0					;indicating end of BASIC stub	
start 			;begin 17 second timer

loop0
	jsr $ffde	;read time from system clock
	txa			;transfer x (middle byte of clock) to a
	cmp #$04	;1024 (from middle byte of clock)
	bne loop0	;loop while < 1024 clock ticks have occurred (1024/60 = ~17 seconds at regular speed)
	
	lda #68							;load ascii 'D' into Accumulator
	jsr $ffd2						;print
	lda #79							;load ascii 'O' into Accumulator
	jsr $ffd2						;print
	lda #78							;load ascii 'N' into Accumulator
	jsr $ffd2						;print
	lda #69							;load ascii 'E' into Accumulator
	jsr $ffd2
inf	
	lda $00c5		;get char pressed down
	cmp #48 ;Q (quit)
	beq exit
	jmp inf
exit
	rts
	
	
	
