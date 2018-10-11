;ek_test5.asm
;a timer which restarts every n clock ticks, where n is a pre-defined constant

	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234	
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 in ascii (beginning of assembly code)
	dc.b 		0                   ;null terminator for SYS statement  
end_basic
	dc.w		0					;indicating end of BASIC stub	

begintimer
	jsr $ffde	;read time from system clock and store in zero page
	;store time in zero page memory (high byte is omitted)
	sta $fb		;orig a = low
	stx $fc		;orig x = middle
	sty $fd		;orig y = hi
	
readclock ;read time from clock and save it into 3 bytes
	jsr $ffde	;read time from system clock
	
subtraction		;perform subtraction and store somewhere
	
	sta $fe		;save new A to zero page
	tya			;transfer high byte of new time (Y) into accumulator
	sbc $fd		;subtract original high byte value
	sbc conshi		;subtract high byte of constant
	bcc readclock	;if negative, get time and start again
	txa			;transfer middle byte of new time into accumulator
	sbc $fc		;subtract original middle byte value
	sbc consmid		;subtract middle byte of constant
	bcc readclock	;if negative, get time and start again
	lda $fe		;load low byte of new value back into accumulator
	sbc $fb		;subtract low byte of orig time from it
	sbc conslow ;subtract low byte of constant
	bcc readclock	;if negative, get time and start again
	
;print "DONE" when timer has reached a value greater than the constant given below
timeout
	lda #68							;load ascii 'D' into Accumulator
	jsr $ffd2						;print
	lda #79							;load ascii 'O' into Accumulator
	jsr $ffd2						;print
	lda #78							;load ascii 'N' into Accumulator
	jsr $ffd2						;print
	lda #69							;load ascii 'E' into Accumulator
	jsr $ffd2
	jsr begintimer					;get new original time

;the constant below dictates how long the timer should run before restarting (measured in clock ticks, 60 per second)
conshi:				;high byte of constant timer value
	dc.b $00
consmid:			;middle byte of constant timer value
	dc.b $02
conslow:			;low byte of constant timer value
	dc.b $58