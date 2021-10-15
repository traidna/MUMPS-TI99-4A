ShowHex:
	ai r0,3000h				;0
	ci r0,3A00h
	jlt ShowHexDigitOk
	ai r0,0700h				;Letters
ShowHexDigitOk:
	b @PrintChar
		
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
	
ShowRegALT:
	mov r11,r9
	bl @PrintCharR3
	swpb r3
	bl @PrintCharR3
	jmp ShowRegALT2
ShowReg:
	mov r11,r9
	li r0,"R "
	bl @PrintChar
		
	mov r1,r0
	bl @ShowHex
ShowRegALT2:
	li r3,": "
	bl @PrintCharR3
	swpb r3
ShowHex4b:  ; pass in r2 		
	bl @ShowHexDigit
	bl @ShowHexDigit
	bl @ShowHexDigit
	bl @ShowHexDigit
	;;bl @PrintCharR3		;Space
	pop r11
	b *r11
	;B *r9
ShowHex4:		
	;mov r11,r9
	push r11
	b @ShowHex4b
	;li r4,06000h
	;li r5,00010h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
ramdump:  ; dumpr ram address passed in R4, number of bytes in R5
	mov r11,r8
	mov r4,r2
	mov r4,r1
	li r3,": "
	bl @ShowHex4
	bl @NewLine
	swpb r3
	li r7,4
ramdumpAgain:		
	mov *r4+,r2
	bl @ShowHex4
	dec r7
	jne ramct
	;li r2,8
	;bl @PrintNChars
	ai r1,8
	bl @NewLine
	li r7,4
ramct	dec r5
	jne ramdumpAgain
	b *r8
Monitor:
	word wspMonitor
	word DoMonitor	
	
DoMonitor:
	li r3,'WP'
	mov r13,r2
	bl @ShowRegALT
		
	li r3,'PC'
	mov r14,r2
	bl @ShowRegALT
		
	li r3,'ST'
	mov r15,r2
	bl @ShowRegALT
		
	bl @NewLine

	mov r13,r5
	li r6,0000h

DoMonitorAgain:		
	mov *r5+,r2
	mov r6,r1
	bl @ShowReg
	ai r6,0100h
	ci r6,1000h 
	jne DoMonitorAgain
	;jmp $
	RTWP
