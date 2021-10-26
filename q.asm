Quit:   ; quit command, either pop return value of last caller
	; or set quitflag because MUMPS stack is empty 
	
	ci r13,MSTACK      ; check if stack is empty
	jne quitrtn        ; if not then get return to address
	li r0,1            ; stack empty to term this program
	mov r0,@QuitFlag   ; set quit flag
	
	jmp quitexit	   ; done
	
quitrtn:
	popm r9    ; pop mumps return stack set r9 code pointer to caller
	
quitexit:
	b *r11

