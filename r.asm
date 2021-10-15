	; read command
	; r x  read string finish with ENTER
	; r *x single key read - wait for key press

Read:
	push r11

	clr r3           ; zero out r3
        movb *r9+,r3     ; read char after S and advance past
        ci r3,2000h      ; is it space should be
        jeq Read2        ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp readend      ; exit out bottom

Read2:
	movb *r9,r3      ; read char after space
        ci r3,Asteric    ; is is an *
	jne Readstr      ; if not read a string below
	inc r9           ; move past *
	bl @getkey	 ; read one keypress	
	pushss r6	 ; get address on string stack
	mov r7,r3        ; toascstr need char in r3
	swpb r3          ; in lsb
	bl @toascstr     ; call util to conver byte value to num string 
	jmp Read2a       ; jump down to get var name

Readstr:  ; not an * so get string
	; add code here
	mov @CursorPos,r6		
	push r6
	bl @getstr
	li r6,TIB
	pushss r7
	bl @strcopy	
	
Read2a:	
	movb *r9,r3
	bl @isalpha      ; must be an alpha to start	
        jeq Read3
        li r1,4          ; bad label
        mov r1,@ErrNum   ; set error num
        jmp setend

Read3:
        li r1,VARNAME
        push r1
        bl @getlabel
        ;movb *r9+,r3     ; move to char after ???
        li r1,VARNAME    ; address of varname
        push r1          ; push to stack for addvar
        popss r1         ; pop data from string stack
        push r1          ; push data to be assigned to varname
        bl @addvar       ; call routine to store varible in btrees	

readend:
	pop r11
	b *r11
