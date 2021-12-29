	; read command
	; r x  read string finish with ENTER
	; r *x single key read - wait for key press

Read:
	push r11

	clr r3           ; zero out r3
	mov @Dolio,r5    ; get current io device
    movb *r9+,r3     ; read char after S and advance past
    ci r3,2000h      ; is it space should be
    jeq Read2        ; if good jump down
    li r1,1          ; missing space syntax error
    mov r1,@ErrNum   ; set error num
    jmp readend      ; exit out bottom
	

Read2:
	movb *r9,r3      ; read char after space
    ci r3,Asteric    ; is is an *
	jne Readstr      ; if not read a string below
	ci r5,ConsIO      ; check if consolio
	jeq Read2b       ; if it is ok
	li r1,23         ; not consolio so no * allowed
	mov r1,@ErrNum   ; log error
	jmp readend      ; exit out
Read2b:	inc r9           ; move past *

	li r14,b1getkey_a
	bl @GoBank1
	;bl @getkey	 ; read one keypress	
	pushss r6	 ; get address on string stack
	mov r7,r3        ; toascstr need char in r3
	swpb r3          ; in lsb
	bl @toascstr     ; call util to conver byte value to num string 
	jmp Read2a       ; jump down to get var name




Readstr:  ; not an * so get string
	; add code here
	ci r5,ConsIO
	jne RdFile
	mov @CursorPos,r6		
	push r6

	li r14,b1getstr_a
	bl @GoBank1

	li r6,TIB
	pushss r7
	bl @strcopy
	jmp Read2a

Rdfile:  ; read rec from open file and copy to string stack from vdpmem
	li r1,2          ;read opcode
	swpb r1          ; swap to msb
	movb r1,@pabopc	 ; put in PAB record

	;li r14,b1clrVDPbuf_a
	;bl @GoBank1      ; 
	bl @clrVDPbuf    ; clear read buffer

	li r14,b1fileio_a
	bl @GoBank1
	;bl @fileio       ; request the read

	li r0,BUFADR     ; vdp address of read buffer
	pushss r2        ; address in ram to copy to 

	;li r14,b1VDPtoRAM_a
	;bl @GoBank1
	bl @VDPtoRAM     ; copy from Vdp memory to ram (bufaddr to var)
	jmp Read3

	
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
