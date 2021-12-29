ramdump:  ; dumpr ram address passed in R4, number of bytes in R5
	push r11
	;mov r11,r8
	push r1
	push r2
	push r3
	push r7

ramagain:
	mov r4,r2
	mov r4,r1
	bl @ShowHex4
	li r0,": "
	bl @PrintChar
	li r0,"  "
	bl @PrintChar
	li r7,4
ramdumpAgain:		
	mov *r4+,r2
	bl @ShowHex4
	dec r7
	jne ramct
	ai r1,8
        bl @ramchars
	bl @CR
	li r7,4
	dec r5
	jeq ramend
	jmp ramagain

ramct	dec r5
	jne ramdumpAgain
	;jne ramagain

ramend:	pop r7
	pop r3
	pop r2
	pop r1

	pop r11
	b *r11


ramchars:  ; 
	push r11
	push r6
	mov r4,r1
	ai r1,-8
	li r6,8
	li r0,"  "
        bl @PrintChar
ramchloop:
 	movb *r1+,r0

	bl @PrintChar
	dec r6
	jne ramchloop
	pop  r6
	pop r11
	b *r11	
	
