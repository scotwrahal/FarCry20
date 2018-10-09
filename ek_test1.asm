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
	lda #$0f		;load 15 (max volume) into Accumulator
	sta $900e		;Set max volume
	lda #$87		;load 135 into Accumulator (low C note)
	sta $900a		;play low C
loopy
	jmp loopy		;loop forever