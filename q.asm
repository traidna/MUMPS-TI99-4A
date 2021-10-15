Quit:
	
	ci r13,MSTACK      ; check if stack is empty
	jne quitrtn        ; if not then get return to address
	li r0,1            ; stack empty to term this program
	mov r0,@QuitFlag   ; 
	
	jmp quitexit	   ; done
	
quitrtn:
	popm r9    ; pop mumps return stack 
	
quitexit:
	b *r11

