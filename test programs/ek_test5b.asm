;ek_test5.asm
;A timer which restarts every n clock ticks, where n is a pre-defined constant

	processor	6502				;assembling for 6502
	org			$1001				;standard organization	
	dc.w		end_basic			;pointer to end of BASIC stub
	dc.w		1234				;line number 1234	
	dc.b		$9e					;SYS instruction
	dc.b 		$34,$31,$30,$39		;address given to SYS: 4109 in ascii (beginning of assembly code)
	dc.b 		0                   ;null terminator for SYS statement  
end_basic
	dc.w		0					;indicating end of BASIC stub	

set_volume
	lda #0			;initialize song note index
	sta note_index
	lda #$0f		;load 15 (max volume) into Accumulator
	sta $900e		;set max volume
	
begintimer
	jsr $ffde	;read time from system clock and store in zero page
	;store time in zero page memory (high byte is omitted)
	sta orig_low		;orig a = low
	stx orig_mid		;orig x = middle
	sty orig_hi		;orig y = hi
	
readclock ;read time from clock and save it into 3 bytes
	jsr $ffde	;read time from system clock
	
subtraction		;perform subtraction and store somewhere
	pha			;push new A to stack
	tya			;transfer high byte of new time (Y) into accumulator
	sbc orig_hi		;subtract original high byte value
	sbc conshi		;subtract high byte of constant
	bcc readclock	;if negative, get time and start again
	txa			;transfer middle byte of new time into accumulator
	sbc orig_mid		;subtract original middle byte value
	sbc consmid		;subtract middle byte of constant
	bcc readclock	;if negative, get time and start again
	pla		;load low byte of new value back into accumulator from stack
	sbc orig_low		;subtract low byte of orig time from it
	sbc conslow ;subtract low byte of constant
	bcc readclock	;if negative, get time and start again
	
;print "DONE" when timer has reached a value greater than the constant given below
timeout
	ldx note_index
	lda the_song,x
	sta $900a		;play note
	inx				;increment note index
	stx note_index
	lda note_index
	sbc #8
	beq reset_song
	jsr begintimer					;get new original time
	
reset_song
	lda #0
	sta note_index
	jsr begintimer

;the constant below dictates how long the timer should run before restarting (measured in clock ticks, 60 per second)
conshi:				;high byte of constant timer value
	dc.b $00
consmid:			;middle byte of constant timer value
	dc.b $00
conslow:			;low byte of constant timer value
	dc.b $1e
	;$1e = 30 = 0.5 seconds
the_song:
	dc.b #167,#159,#228,#219,#215,#231,#228,#191
orig_low:
	dc.b
orig_mid:
	dc.b
orig_hi:
	dc.b
note_index:
	dc.b