;ek_test0.asm
;Prints a 'B' character in an infinite loop
	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 ascii (beginning of assembly code)
	dc.b 		0                   ;null terminator for SYS statement  
end_basic
	dc.w		0					;indicating end of BASIC stub
start
	lda #66							;load ascii 'B' into Accumulator
	jsr $ffd2						;jump to print subroutine
	jmp			start				;repeat
	rts
