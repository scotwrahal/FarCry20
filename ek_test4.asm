;ek_test1.asm
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
	ldy #10		;program loops 10 times
loop2
	lda #13		;define offset for screen origin vertical (book says standard value of 5 but I think it's 12)
	sta 36864	;poke screen origin horizontal with offset
	jsr quick_pause
	
	lda #37		;define offset for screen origin horizontal (book says standard value of 25 but I think it's 35)
	sta 36865	;poke screen origin vertical with offset
	jsr quick_pause
	
	lda #11		;define offset for screen origin horizontal
	sta 36864	;poke screen origin horizontal with offset
	jsr quick_pause
	
	lda #33		;define offset for screen origin vertical
	sta 36865	;poke screen origin vertical with offset
	jsr quick_pause
	
	dey			;decrement counter
	tya
	cmp #$00	;check if counter == 0
	bne loop2	;loop if counter != 0
	rts			;exit
	
quick_pause		;brief looping subroutine to slow down the visual effect
	ldx #30		;loop0 executes 30 times
loop0
	lda #$ff	
loop1			;nested loop1 executes 255 times
	sbc #$01
	cmp #$00
	bne loop1
	
	dex			;decrement loop0 counter
	txa
	cmp #$00
	bne loop0
	
	rts			;return after (255*30) = 7650 loops total