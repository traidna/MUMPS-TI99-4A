Quit:   ; quit command, either pop return value of last caller
	; or set quitflag because MUMPS stack is empty 
	
	ci r13,MSTACK      ; check if stack is empty
	jne quitrtn        ; if not then get return to address
	li r0,1            ; stack empty to term this program
	mov r0,@QuitFlag   ; set quit flag	
	jmp quitexit	   ; done
	
quitrtn:
	popm r9           ; pop mumps return stack set r9 code pointer to caller
	;ci r9,0A000h      ; check if do was from command line
	;jl quitexit
	mov @Forflg,r0  ; check if in for loop
	ci r0,0
	;;;jeq quitexit 
	jeq quitnofor
	
    mov @Doflg,r0     ; reduce level of do's
    ai r0,-1
    mov r0,@Doflg	
	pop r11          ; pop call to parse
	pop r11          ; call from lp to get back to for
    jmp quitexit

quitnofor:
	pop r11
	pop r11
	
quitexit:
   
	b *r11

