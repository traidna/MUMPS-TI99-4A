	; w.asm - Write routine
	; write can hande # - cls, !, newline strings in "", 
	; numbers or variables or results of operators

Write: 	; R9 is pointer to executing code
	push r11

	clr r3           ; zero out r3
	movb *r9+,r3     ; read char after w and advance past
	ci r3,2000h      ; is it space should be
	jeq wrt2         ; if good jump down
	li r1,12         ; missing space syntax error
	mov r1,@ErrNum   ; set error num
	jmp wrtend       ; exit out bottom			

wrt2:    
	movb *r9,r3      ; read char after space
	ci r3,Hashtag    ; check for #
	jeq wcls         ; if # then cls
	ci r3,ExclamPt   ; is char ! if so do print newline
	jeq wnewln       ; new line
	;;ci r3,02200h   ; let mstring handle syntax from here
	                 ; letters (vars), digits, " operators ok here
	bl @getmstr      ; get mumps string
	mov @ErrNum,r1
	;jmp $
	ci r1,0          ; see if any errors
	;jne werror	 ; yes found error - do not print anything
	jne wrtend
	popss r1         ; get address of string on top of string/math stack
	bl @PrintString  ; print the string		 
wrt3:	movb *r9,r3      ; get the current char in code 
	ci r3,Comma      ; is it a comman
	jne  wrt4        ; if no then jump on 
	inc r9           ; if comma then inc code pointer
	jmp wrt2         ; loop back up for next thing to print
wrt4	ci r3,SPACE
	jeq wrtend
wrt5	ci r3,NULL       ; not a comma so check if NULL 
	jne werror       ; if not a null then syntax error
	jmp wrtend       ; if NULL end of line and write command

werror:	
	li r1,11        ; missing space syntax error
	mov r1,@ERRNUM ; set error num

wrtend:	pop r11
	b *r11
	;b *r7

wcls:   bl @Cls
	inc r9    ; move past #
	jmp wrt3

wnewln:
	bl @CR
	inc r9
	movb *r9,r3
	ci r3,Exclampt
	jeq wnewln
	jmp wrt3
