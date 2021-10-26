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
     	b @zinsert     ; if I go do insert

zw:	li r2,'W'      ; write symbol table
	swpb r2
	cb r3,r2       ; is it W
	jne zs
	b @zwrite     ; if yes then jump to write

zs:	li r2,'S'      ; save mumps source to file
	swpb r2        ; move to msb  
	cb r3,r2       ; is it an S if so 
	jne zld         ; if not ZS jump down to check for zr
	b @zsave       ; branch to zsave  

zld:	li r2,'L'      ; save mumps source to file
	swpb r2        ; move to msb  
	cb r3,r2       ; is it an S if so 
	jne zr         ; if not ZS jump down to check for zr
	b @zload       ; branch to zsave  
		        


zr:	li r2,'R'      ; delete mumps source
	swpb r2          
	cb r3,r2       ; is it an R if so 
	jne ZD         ; if not ZR check for ZD
	b @zremove     ; branch to ZR zremove

ZD:	li r2,'D'      ; is it D - list
	swpb r2        ; mov to msg
	cb r3,r2       ; is is ZL command
	jne ZM         ; if not jump donw to zee2 - error
	bl @zlist      ; list source
	jmp zexit

ZM:	li r2,'M'      ; is it D - list
	swpb r2        ; mov to msg
	cb r3,r2       ; is is ZL command
	jne Zee2       ; if not jump donw to zee2 - error

	movb *r9+,r3    ; get next char needs to be a space
	ci r3,SPACE
	jne zmerr


zm2:    ; copy numb to string
	
	bl @getmstr
	popss r6

	bl @hstrtonum
	mov r7,r4
zmloop:	push r4
	li r5,50h
	bl @ramdump
	bl @CR
	li r1,PQmsg
	bl @PrintString
zmask:	bl @getkey
	ci r7,00D00h
	jeq zmagain
	ci r7,Pkey
	jeq zmprev
	ci r7,QKey
	jne zmask
	pop r4
	bl @Cls
	jmp zexit


zmagain:	
	bl @Cls
	pop r4
	ai r4,0A0h
	jmp zmloop	
zmprev:	
	bl @Cls
	pop r4
	ai r4,-0A0h
	jmp zmloop	

zmerr:
	li r1,12         ; missing space
	mov r1,@ErrNum  ; log error
	jmp zexit


Zee2:	li r1,5          ; error unknown command
	mov r1,@ErrNum   ; store it 
	jmp zexit        ; done

zexit:  pop r11
	b *r11

zlist:    ; list code
	push r11 
	movb *r9,r3        ; get current char
	ci r3,0000h        ; check if no label
	jne zlista         ; not zero so there is a label
	li r1,CODESTART    ; start a beginning of Codearea
	jmp zlist2         ; start listing
zlista	ci r3,Space        ; check for space (must be)
	jeq zlab           ; if yes then get label
	li r2,12           ; error missing space
	mov r2,@ErrNum     ; log error
	jmp zl2            ; jump out

zlab:
	inc r9          ; move past space
	movb *r9,r3     ; get what should be an alpah
	bl @isalpha     ; should be an alpha
	jeq zlab2       ; if yes go get label		
	li r3,11        ; if not log error
	mov r3,@ErrNum  ; save error
	jmp zl2	        ; and exit

zlab2:
	li r2,LABEL     ; pointer to ram space for temp var
	push r2         ; push for use in getlabel
	bl @getlabel    ; call get label
	push r2         ; push ptr to label
	bl @findlabel   ; go find it in code
	pop r2          ; address of end of label
	pop r1          ; address of start of line
	ci r2,0h        ; is the addrss 0 (not found)
	jeq zl2	        ; if so get out

zlist2:	clr r2          ; set screeen pos to 0
	bl @gotoxy      ; move to screen pos
	
	li r2,EOF       ; load EOF in r2
	cb *r1,r2       ; is char EOF
	jeq zl2         ; if yes jump out

zl	bl @PrintString    ; print line of code
	push r1            ; save code ptr - place in code
	bl @CR             ; print newline
	pop r1             ; pop code ptr back
	clr r2             ; clear r2
	;movb *r1,r2       ; read next char
	li r2,EOF          ; load r2 with EOF
 	cb *r1,r2          ; is this char end of file 
	jeq zl2            ; if yes jump out
	mov @CursorPos,r2  ; get cur screen position
	ci r2,640	   ; check see if we are 640 down
	jlt zl             ; if less than then loop back up
	push r1            ; save code ptr
	bl @CR             ; print new line
	li r1,PressMsg     ; get pointer to press key msg
	bl @PrintString    ; print the message
	bl @getkey         ; wait for key press
	bl @Cls            ; clear the screen
	pop r1             ; pop ptr to code back
	jmp zl             ; loop back up for next line of code
	
zl2	pop r11            ; pop return address 
	b *r11	           ; return to caller


zwrite:   ; print all the variables in the symbol table
	mov @HEAD,r6      ; get head of binary tree
	bl @treeprint     ; call tree print (needs r6 ) tree.asm
	jmp zexit         ; jump out



zinsert:  ; insert code

	li r1,ZIMsg         ; point to zi message
	bl @PrintString     ; print the zi message
zins2:	li r2,0240h         ; set screen posisiton for getstr
	push r2             ; push it so getstr can pop it
	bl @GetStr          ; call getstr
	li r6,TIB           ; get address of string from getstr
	clr r3              ; clr r3
	movb *r6,r3         ; read char from text input buffer
	ci r3,0             ; is it end of line
	jne zins3           ; if no jump down
	bl @Cls             ; clear screen
	jmp zexit           ; get out

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
	jne zins2           ; jump back up
	jmp zwrite          ; 


zremove:  ; 
  	li r2,CODESTART    ; set to start of code ram 
        mov r2,@CodeTop    ; Iintial CodeTop ( next addres for M code)
        li r1,EOF          ; Initial code space
        mov r1,*r2         ; put end of file at first space in code mem
	b @zexit

zload:
	movb *r9+,r3
	ci r3,SPACE       ; should be a space
	jeq zload1
	b @zserr         ; missing space
zload1:
	bl @clrampab      ; clear out PB ram ( real PEB needs this) 
	bl @getmstr       ; get filename - check for error ??
	popss r6          ; get string
	li r7,pabfil      ; set up for copy
	bl @strcopy       ; 
	li r1,zlmsg       ; load zl msg
	bl @PrintString   ; print it
	li r1,pabfil      ; point to file name
	bl @PrintString   ; print it

	li r1,00014h      ; open read
	bl @zsopen        ; open file to read
	; read source to open file
	li r2,CODESTART   ;

zlrdfile:  ; read rec from open file and copy to string stack from vdpmem
        li r1,2          ;read opcode
        swpb r1          ; swap to msb
        movb r1,@pabopc  ; put in PAB record
	push r2
        bl @clrVDPbuf    ; clear read buffer
        bl @fileio       ; request the read
        li r0,BUFADR     ; vdp address of read buffer
        ;pushss r2        ; address in ram to copy to
	pop r2
	push r2
        bl @VDPtoRAM     ; copy from Vdp memory to ram (bufaddr to var)
   	pop r3
	clr r1
	movb *r3,r1
	ci r1,0FF00h
	jne zlrdfile
	ai r2,-2
	mov r2,@CODETOP
	jmp zsclose


zsave:
	movb *r9+,r3
	ci r3,SPACE       ; should be a space
	jne zserr         ; missing space
	bl @getmstr        ; get filename - check for error ??
	popss r6          ; get string
	li r7,pabfil      ; set up for copy
	bl @strcopy       ; copy to pabfil location
	li r1,zsmsg       ; save to msg
	bl @PrintString   ; print it
	li r1,pabfil      ; file name
	bl @PrintString   ; print it
	li r1,00012h      ; open write
	bl @zsopen        ; open file to write to
	; write source to open file
	li r1,CODESTART   ;

zsavew:
	bl @WriteFile     ; r2 points to end of string
	mov r2,r1         ; r2 points to end of string
	clr r3            ; clear r3
	movb *r1,r3       ; get next char in code
	ci r3,0FF00h      ; check for end of file
	jne zsavew        ; if not get next line of code
	
	li r1,EOFmark     ; set R1 to end of file marker
	bl @WriteFile     ; write end of file maker

zsclose	; close file
	li r1,00100h      ; r1 00100 move only msb to pab rest of rec is set
        movb r1,@pabopc   ; copy to ram version of pab
	bl @fileio        ; write the record

	b @zexit          ; branch to exit 


zsopen: ; open file to save msrc to (filename hard coded for now 
        ; will need to allow entry of file name once working )
	; copy file name into pabfil location prior to calling
	; pass in r1 with 0012h to open to write
        ; pass in r1 with 0014h to open to read

	push r11

        mov r1,@pabopc      ; 0012h for write or 0014h to read
        li r1,BUFADR        ; set up ptr to VDP buffer (1000h)
        mov r1,@pabbuf      ; copy to pab in ram
        li r1,05000h        ; 50h is 80 chars, max size of records
        mov r1,@pablrl      ; copy to pab in ram
        li r6,pabfil        ; point to filename
        push r6             ; push for strlen
        bl @strlen          ; get length of the file
        pop r7              ; length from strcopy in r7
        swpb r7             ; move to msb
        movb r7,@pabnln     ; copy to pab in ram
        bl @fileio          ; call filio to do the open
        clr r3              ;
        li r0,PABERR        ; point to addres in pab where status is 
        bl @vsbr            ; read error status from vdp in pab
        andi r1,0E000h      ; 1110 0000 0000 0000 b 1400 is ok F400 error
        ci r1,0             ; check if r1 is 0 - no error
        jne zserr           ; found an error
zsend:
        mov @CursorPos,r2   ; rest vdp read/write pointer
        bl @gotoxy          ; and reset cursor position

	pop r11             ; pop return address
	b *r11              ; return to caller

zserr:
	li r1,88            ; error 88 - file io error
	mov r1,@Errnum      ; 
	jmp zsend           ;



