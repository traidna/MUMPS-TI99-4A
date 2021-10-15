	; d.asm - Do routine
Do: 	; 
	;push r11

        clr r3           ; zero out r3
        movb *r9+,r3     ; read char after D and advance past
        ci r3,2000h      ; is it space should be
        jeq DO2          ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp doend        ; exit out bottom

Do2:
        movb *r9,r3      ; read char after space
	bl @isalpha      ; must be an alpha to start
	jeq Do3
        li r1,4          ; bad label
        mov r1,@ErrNum   ; set error num
        jmp doend        ; exit out bottom
	
Do3:
	li r1,LABEL      ; load up mem space to store label text
	push r1          ; push to stack for getlabel
	bl @getlabel     ; call getlabel - label will be at *r1
	li r1,LABEL
	push r1
	bl @findlabel
	pop r2           ; 0 if not found otherwise addr after label
	pop r8           ; if r2 not 0 r8 will have addr of start

Doend:  
	pushm r9
	mov r2,r9
	b @lp
	;bl @lp
	;li r1,debug1
	;bl @Printstring
	;bl @getkey
Doexit:	;pop r11
	;b *11



findlabel:   ; search label pointed to by address on top of stack
	     ; pushes start of line found
	     ; pushes address of char after label found or 0	
	pop r6            ; address of label to find
	push r11          
	li r2,CODESTART   ; START AT TOP OF CODE
	mov r6,r8         ; copy of start of label to r8

findlab1:
	clr r3
	movb *r2,r3     ; check first char of line
	mov r2,r14
	ci r3,EOF       ; is it end of file
	jne findlab2    ; if not jump down and keep going
	clr r2	        ; if it is EOF set return value to 0
	jmp flexit      ; jump to exit
findlab2:
	bl @isalpha     ; is the first character a alpah
	jne flnextline  ; if no, then advance to next line
	li r7,SCRATCH   ; point r7 at available scratch memory

fl22	movb *r2+,*r7+  ; copy label to scratch
	movb *r2,r3
	ci r3,SPACE     ; stop at space
	jne fl22        ; if not space keep going
	clr r11
	movb r11,*r7      ; it's a space so terminate the string
			; compare this label to one passed in
	li r7,SCRATCH
	mov r8,r6       ; reset r6 back to start of passed in string
	;jmp $
	bl @strcmp      ; compare r6 passed in string and r7 str from code
	ci r5,0	        ; if zero then then are equal
	jeq flexit
doskipln:	
	movb *r2+,r3
	ci r3,NULL
	jne doskipln	
	jmp findlab1

flnextline:
	movb *r2+,r3
	ci r3,NULL		
	jne flnextline
	jmp findlab1

flexit:
	pop r11   ; get return address
	push r14   ; push start of line r2 holds address of char after label
	push r2   ; push result 0 if not found address of label otherwise
	;jmp $
	b *r11    ; branch back to caller

