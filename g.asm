	; g.asm - goto 


Go:     ; 
        ; R9 is pointer to executing code

        ;push r11
        clr r3           ; zero out r3
        movb *r9+,r3     ; read char after g and advance past
        ci r3,0h         ; if NULL goto start of code
	jne GoLab
	; push current R9 to return stack ?
	li r9,CODESTART
	bl @Cls
	jmp GoendG

GoLab:
	ci r3,Space
	jne GoErr
	
 	movb *r9,r3      ; read char after space
        bl @isalpha      ; must be an alpha to start
        jeq Go3
        li r1,4          ; bad label
        mov r1,@ErrNum   ; set error num
        jmp Goexit        ; exit out bottom

Go3:
        li r1,LABEL      ; load up mem space to store label text
        push r1          ; push to stack for getlabel
        bl @getlabel     ; call getlabel - label will be at *r1
        li r1,LABEL
        push r1
        bl @findlabel
        pop r2    
        pop r8           ; if r2 not 0 r8 will have addr of start

Goend:
        ;pushm r9
        mov r2,r9
GoendG:
        b @lp

Goexit:	
	pop r11
	b *r11

Goerr:
	li r1,1   ; missing space
	mov r1,@ErrNum
	jmp Goexit	
