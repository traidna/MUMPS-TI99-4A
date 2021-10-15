	; s.asm - Write routine
Set: 	; 
	push r11

        clr r3           ; zero out r3
        movb *r9+,r3     ; read char after S and advance past
        ci r3,2000h      ; is it space should be
        jeq Set2          ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp setend        ; exit out bottom

Set2:
        movb *r9,r3      ; read char after space
        bl @isalpha      ; must be an alpha to start
        jeq Set3
        li r1,4          ; bad label
        mov r1,@ErrNum   ; set error num
	jmp setend

Set3:      
	;;;li r1,VARNAME
	;;;push r1	
	pushss r1
	push r1
	bl @getlabel
	movb *r9+,r3
	ci r3,Equals
	jeq Set4
	popss r1         ; take the varname off string stack
        li r1,7          ; error expecting =
        mov r1,@ErrNum   ; set error num
	jmp setend
	
Set4:
	
	bl @getmstr      ; get mumps string

        mov @ErrNum,r1
        ci r1,0          ; see if any errors
        jne serror       ; yes found error - do not print anything

SetSave:
	popss r2          ; address of data
	;; since more access to string stack from here it'll 
        ;; be ok to acess from here
        ;; until any more pushss occure
	popss r1         ; pop varname from string stack
	push r1          ; push address of varname to stack for addvar	
	push r2          ; push data to be assigned to varname
	bl @addvar       ; call routine to store varible in btrees 
	
serror: 
	popss r1        ; take varname off string stack

setend:	pop r11
	b *r11

