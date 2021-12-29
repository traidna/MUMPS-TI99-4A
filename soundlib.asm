        ; pass in R2 1CCTVVV 1CC1 1111 or 
        ; r2 - channel 0,1,2,3 
SoundOff:
	li r1,8400h	  ;Sound port				; 1CCTVVVV	;Vol=15 means mute
	a r2,r2       ; double chanel
	ai r2,9       ; add 9 - 1001 
	sla r2,4      ; move one byte left
	ai r2,0Fh     ; set volume to F (mute)
	swpb r2       ; move to msb for movb
 	movb r2,*r1   ; copy to sound Register
    b *r11

Sound:   		  ; pass in chanel in r2 
				  ; note/tone in r3 (xxffff)
				  ; r4 volume
	li r1,8400h
	mov r2,r0

	a r2,r2       ; double channel
	ai r2,9       ; add 9 - 1001 
	sla r2,4      ; move one byte left
	a r4,r2       ; set volume to F (mute)
	swpb r2       ; move to msb for movb
 	movb r2,*r1   ; copy to sound Register

	mov r0,r2
	a r2,r2       ; double chanel
	ai r2,8       ; add 8
	sla r2,4      ; move one byte left
	swpb r2       ; move to msb
	a r3,r2       ; ed in note (xxffffff)
	movb r2,*r1   ; write  to sound port
	swpb r2       ; swap bytes to get LLLL tone
	movb r2,*r1   ; write to sound port
	b *r11        ; return caller


beep:
	push r11        ; push calling return addr
	li r2,0         ; Channel 0
	li r3,3103      ; decimal tone value
	li r4,2         ; volume 0-15 0 loudest
	bl @Sound       ; call sound routine
	li r1,07000h;   ; duration of waiting
beepwait:           ; loop label 
	dec r1          ; decrease loop ctr
	jne beepwait    ; loop back up
	li r2,0         ; channel 
	;li r4,0Fh       ; volume mute
	;bl @Sound       ; call sound to mute
	bl @Soundoff
	pop r11         ; pop return address
	b *r11		    ; return to caller
	
			
SpeechLoadAddr:	  ; pass in address to load in R0
   
    li r2,4            ; read loop for 4 nibbles
loadlp:
	src r0,4          ; move nibble 
	movb r0,r1        ; copy to r1
	src r1,4          ; move nibble
	andi r1,0F00h     ; mask only nibble to load
	ori r1,04000h     ; add 4 command to load addr
	movb r1,@Spchwt   ; write command/nibble
	dec r2            ; dec counter
	jne loadlp        ; if counter is not 0 loop back up
	li r1,4000h       ; command for final nibble which is zero
	movb r1,@Spchwt   ; write it
	bl *r11           ; return to caller
	
SpeechDelay:
	li r2,100h        ; set up counter for delay
spdelay:	          ; delay loop
	dec r2
	jne spdelay
	b *R11            ; return to caller
	
   ; pass in address of phrase in r0
Speech:
   push r11
	; check if synth attached
	; need delay to see if still talking
	push R0
    ;bl @SpeechAttached
	ci r0,0
	jeq SpeechEnd
	pop R0
	bl @SpeechLoadAddr
	bl @SpeechDelay
	
	li r2,5000h       ; command to speak
	movb r2,@Spchwt   ; write it
SpeechEnd:	
	pop r11           ; get address of caller
	b *r11            ; branch back to caller

SpeechAttached:

	li r0,0000h
	bl @SpeechLoadAddr
	movb @H10,@Spchwt
	bl @SpeechDelay
	
	movb @H10,@Spchwt   ; Read data command.

	bl @SpchReadit        ;Read one byte.
	CB @SPDATA,@HHAA      ; Is it >AA?
    jeq SpeechYes
    li r0,0 
	jmp Spchattchend
SpeechYes
	li r0,1
	;bl @Beep
Spchattchend
	pop r11
	b *r11
	

