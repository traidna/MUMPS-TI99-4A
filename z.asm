	; z.asm z commands, two letters
	; may have params or not

Zee:
	push r11
        clr r3           ; zero out r3
        movb *r9+,r3     ; read char after z and advance past
	swpb r3
	bl @toupper      ; 
	swpb r3
	clr r2           ; clear r2 and
        li r2,'I'        ; load with I to check for insert 
	swpb r2          ; mov to msb
	cb r3,r2         ; is it an I - insert
        jeq zinsert      ; if I go do insert
	li r2,'W'        ; write symbol table
	swpb r2
	cb r3,r2
	jeq zwrite       ; 

	li r2,'R'        ; delete mumps source
	swpb r2
	cb r3,r2
	jne ZD
	b  @zremove       ; 
ZD:	li r2,'D'        ; is it L - list
	swpb r2          ; mov to msg
	cb r3,r2         ; is is ZL command
	jne Zee2
	bl @zlist


	jmp zexit

Zee2	li r1,5          ; error unknown command
	mov r1,@ErrNum   ; store it 
	jmp zexit        ; done

zexit:
	pop r11
	b *r11

zlist:    ; list code
	push r11 
	movb *r9,r3
	ci r3,0000h
	jne zlista
	li r1,CODESTART
	jmp zlist2
zlista	ci r3,Space
	jeq zlab
	li r2,12
	mov r2,@ErrNum
	jmp zl2

zlab:
	inc r9        ; move past space
	movb *r9,r3  ; get what should be an alpah
	bl @isalpha   ; should be an alpha
	jeq zlab2     ; if yes go get label		
	li r3,11      ; if not log error
	mov r3,@ErrNum 
	jmp zl2	      ; and exit

zlab2:
	li r2,LABEL
	push r2
	bl @getlabel
	push r2
	bl @findlabel
	pop r2        ; address of end of label
	pop r1        ; address of start of line
	ci r2,0h
	jeq zl2	

zlist2:	clr r2
	bl @gotoxy
	
	li r2,EOF
	cb *r1,r2
	jeq zl2

zl	bl @PrintString
	push r1
	bl @CR
	pop r1
	clr r2
	movb *r1,r2
	; ci r2,NULL
	li r2,EOF
	cb *r1,r2
	jeq zl2
	mov @CursorPos,r2
	ci r2,640	
	jlt zl
	push r1
	bl @CR
	li r1,PressMsg
	bl @PrintString
	bl @getkey
	bl @Cls
	pop r1
	jmp zl
	
zl2	pop r11
	b *r11	


zwrite:
	mov @HEAD,r6
	bl @treeprint
	jmp zexit



zinsert:  ; insert code

	;clr r2
	;bl @gotoxy	
	li r1,ZIMsg         ; point to zi message
	bl @PrintString     ; print the zi message
zins2:	li r2,0240h         ; set screen posisiton for getstr
	push r2             ; push it so getstr can pop it
	bl @GetStr          ; call getstr
	li r6,TIB           ; get address of string from getstr
	clr r3
	movb *r6,r3
	ci r3,0
	jne zins3
	bl @Cls
	jmp zexit

zins3	mov @CodeTop,r7     ; point to bottom of codearea 
	bl @strcopy         ; append new line of code
	li r6,TIB	    ; reset TIB pointer
	push r6             ; push for strlen
	bl @strlen          ; get strlen
	pop r6              ; retrieve length
	mov @CodeTop,r7     ; get last value of codetop 
	a r6,r7             ; add string lenght to it
	ai r7,1             ; add one for terminator
	mov r7,@CodeTop     ; save new codetop
	li r6,EOF           ; load eof in r6
	movb r6,*r7         ; move eof to new position
	bl @Cls             ; clear screen
	;bl @zlist
	jne zins2
	jmp zwrite


zremove:  ; 

  	li r2,CODESTART
        mov r2,@CodeTop        ; Iintial CodeTop ( next addres for M code)
        li r1,EOF              ; Initial code space
        mov r1,*r2             ; put end of file at first space in code mem
	b @zexit

