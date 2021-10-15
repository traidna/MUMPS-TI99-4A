
push:	; add item to top of stack
	; sp  - stack pointer set up in am.asm in Base ram
	; r0  - word to push
	; put r2 back to r0
	
	mov @SP,r1
	mov @RS,*r1     ; move the value passed to top of stack
	inct r1        ; add two to r0
	mov r1,@SP     ; put new top of stack to SP
	b *r11         ; return to caller

pop    ; remove top item from stack place in r0

	mov @SP,r1      ; get address of next item on stack
	dec r1          ; move it down to top value
	dec r1
	mov *r1,@RS     ; read top value
	mov r1,@SP      ; store new tos 
	b *r11          ; return to calling program

	
