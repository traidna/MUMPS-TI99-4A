	; h.asm - halt routine
Halt: 	; 
	mov r11,r7
	bl @CR
        li r1,HMSG
	bl @PrintString		
	bl @CR
	bl @CR
	li r1,PressMsg
	bl @PrintString
	bl @getkey
	li r1,1
	mov r1,@HaltFlag
	blwp @0
	b *r7


