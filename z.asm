	; z.asm z commands, two letters
	; may have params or not

Zee:
	push r11
    clr r3         ; zero out r3
    movb *r9+,r3   ; read char after z and advance past
	swpb r3        ; move to lsb
	bl @toupper    ; convert to upper case
	swpb r3        ; put back in msb

	clr r2         ; clear r2 and ...
    li r2,'I'      ; load with I to check for insert 
	swpb r2        ; mov to msb
	cb r3,r2       ; is it an I - insert
   	jne zw         ; jmp to check if w
	
	li r14,b1zinsert_a
	bl @GoBank1     
	b @zexit

zw:	li r2,'W'      ; write symbol table
	swpb r2
	cb r3,r2       ; is it W
	jne zs
	li r14,b1zwrite_a
	bl @GoBank1
	;b @zwrite     ; if yes then jump to write
	b @zexit

zs:	li r2,'S'      ; save mumps source to file
	swpb r2        ; move to msb  
	cb r3,r2       ; is it an S if so 
	jne zld         ; if not ZS jump down to check for zr
	b @zsave       ; branch to zsave  

zld:
	li r2,'L'      ; save mumps source to file
	swpb r2        ; move to msb  
	cb r3,r2       ; is it an S if so 
	jne zr         ; if not ZS jump down to check for zr
	b @zload       ; branch to zsave  
		        

zr:	li r2,'R'      ; delete mumps source
	swpb r2          
	cb r3,r2       ; is it an R if so 
	jne ZD         ; if not ZR check for ZD
	li r14,b1zremove_a
	bl @GoBank1
	jmp zexit

ZD:	li r2,'D'      ; is it D - list
	swpb r2        ; mov to msg
	cb r3,r2       ; is is ZL command
	jne ZE         ; if not jump donw to zee2 - error
	li r14,b1zlist_a ;
	bl @GoBank1    ; 
	;bl @zlist      ; list source
	jmp zexit

ZE:	li r2,'E'      ; is it E - editor
	swpb r2        ; mov to msg
	cb r3,r2       ; is is ZL command
	jne ZM         ; if not jump donw to zee2 - error
	li r14,b1ze_a  ; call ze in Bank1
	bl @GoBank1    ; go bank1
	jmp zexit      ; returned form bank1




ZM:	li r2,'M'      ; is it M - Monitor
	swpb r2        ; mov to msg
	cb r3,r2       ; is is ZM command
	jne Zee2       ; if not jump donw to zee2 - error
	movb *r9+,r3    ; get next char
	ci r3,0         ; no addr given ok
	jne zmsp        ; not empty
	dec r9          ; put pointer back at 0
	jmp zmcall      ; make call
zmsp:	ci r3,SPACE     ; is it space
	jne zmerr

zmcall:	li r14,b1zm2_a
	bl @GoBank1
	jmp zexit	

zmerr:
        li r1,12         ; missing space
        mov r1,@ErrNum  ; log error
        jmp zexit



Zee2:	li r1,5          ; error unknown command
	mov r1,@ErrNum   ; store it 
	jmp zexit        ; done

zexit:  pop r11
	b *r11



zload:  ; load file from disk call to bank 1
	movb *r9+,r3
	ci r3,SPACE       ; should be a space
	jeq zload1
	b @zserr         ; missing space
zload1: ; syntax good call Bank1
	movb *r9,r3
	ci r3,QuoteW
	jeq zload2
	li r1,6
	mov r1,@ErrNum
	b @zexit	
zload2:
	li r14,b1zload1_a
	bl @GoBank1
	b @zexit




zsave:  ; check syntax for save and call bank1
	movb *r9+,r3
	ci r3,SPACE       ; should be a space
	jne zserr         ; missing space
	li r14,b1zsave_a
	bl @GoBank1
	b @zexit

zserr:
	li r1,88            ; error 88 - file io error
	mov r1,@Errnum      ; 
	jmp zsend           ;

zsend:
        mov @CursorPos,r2   ; rest vdp read/write pointer
        bl @gotoxy          ; and reset cursor position
        pop r11             ; pop return address
        b *r11              ; return to caller

