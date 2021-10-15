ShowHex:
	push r11
	ai r0,3000h				;0
	ci r0,3A00h
	jlt ShowHexDigitOk
	ai r0,0700h				;Letters
ShowHexDigitOk:
	bl @PrintChar
	pop r11
	b *r11
	
ShowHexDigit:
	;;mov r11,r10
	push r11
	mov r2,r0
	andi r0,0F000h
	srl r0,4
	bl @ShowHex
	sla r2,4
	pop r11
	b *r11
	;B *R10
	

ShowHex4:   ; pass in r2		
	;mov r11,r9
	
	push r11

ShowHex4b:  ; pass in r2 		
	bl @ShowHexDigit
	bl @ShowHexDigit
	bl @ShowHexDigit
	bl @ShowHexDigit
	pop r11
	b *r11
