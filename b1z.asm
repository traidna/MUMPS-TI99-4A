	; Z commands in MUMPS bank1 routines

zwrite:   ; print all the variables in the symbol table
	push r11
    mov @HEAD,r6      ; get head of binary tree
   	li r14,b0treeprint_a
	bl @GoBank0
	pop r11
	b *r11

zremove:  ;  remove file from Code Area by placing FF in first byte
	push r11
	;; clear 10 k of space
	li r2,CODESTART
	clr r1
zrmloop:
	mov r1,*r2+
	ci r2,VARDATA
	jlt zrmloop

    li r2,CODESTART    ; set to start of code ram
    mov r2,@CodeTop    ; Iintial CodeTop ( next addres for M code)
    li r1,EOF          ; Initial code space
    mov r1,*r2         ; put end of file at first space in code mem
      
	;b @zexit
	pop r11
	b *r11

zload1:

	push r11
    bl @clrampab      ; clear out PB ram ( real PEB needs this)

	li r14,b0getmstr_a    ;
	bl @GoBank0           ; call getmstr in bank 0

    popss r6          ; get string
    li r7,pabfil      ; set up for copy
    bl @strcopy       ;
    li r1,zlmsg       ; load zl msg
    bl @PrintString   ; print it
    li r1,pabfil      ; point to file name
    bl @PrintString   ; print it

    li r1,00014h      ; open read
    bl @zsopen        ; open file to read
	mov @fioerr,r0    ;
	ci r0, 1400h         ; check if success on open
	jne zserr         ; generice file io err
    ; read source to open file
    li r2,CODESTART   ;


zlrdfile:  ; read rec from open file and copy to string stack from vdpmem
    li r1,2          ;read opcode
    swpb r1          ; swap to msb
    movb r1,@pabopc  ; put in PAB record
    push r2

    li r14,b0clrVDPbuf_a
    bl @GoBank0
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
    jeq zloadend
	ci r1,Dol
	jeq zloadend
	jmp zlrdfile

zloadend:
    ai r2,-2
    mov r2,@CODETOP
    jmp zsclose


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

    ;;;li r14,b1fileio_a
    ;;;bl @GoBank1
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
    li r1,8             ; error 8 - file io error
    mov r1,@Errnum      ;
    jmp zsend           ;


zsave:  ; save program in memory to disk

	push r11

	li r14,b0getmstr_a
	bl @GoBank0
        ;;;bl @getmstr        ; get filename - check for error ??
        
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
	li r14,b0WriteFile_a
	bl @GoBank0

    mov r2,r1         ; r2 points to end of string
    clr r3            ; clear r3
    movb *r1,r3       ; get next char in code
    ci r3,0FF00h      ; check for end of file
    jne zsavew        ; if not get next line of code

    li r1,b1eofmark_a     ; set R1 to end of file marker
	li r14,b0WriteFile_a
	bl @GoBank0


zsclose ; close file
    li r1,00100h      ; r1 00100 move only msb to pab rest of rec is set
    movb r1,@pabopc   ; copy to ram version of pab

    bl @fileio        ; write the record
	pop r11
	b *r11
    
zlist:    ; list code
    push r11
	push r3
	mov @Screenwidth,r3
	ci r3,40
	jeq zlcont
	li r1,1700h
	bl @Text40
	bl @Cls
	pop r3
zlcont:	
    movb *r9,r3        ; get current char
    ci r3,0000h        ; check if no label
    jne zlista         ; not zero so there is a label
    li r1,CODESTART    ; start a beginning of Codearea
    jmp zlist2         ; start listing
zlista:  
	ci r3,Space        ; check for space (must be)
    jeq zlab           ; if yes then get label
    li r2,1            ; error missing space
    mov r2,@ErrNum     ; log error
    jmp zl2            ; jump out

zlab:
    inc r9          ; move past space
    movb *r9,r3     ; get what should be an alpah
	bl @isalpha     ; should be an alpha  - b1charlib.asm
    jeq zlab2       ; if yes go get label
    li r3,11        ; if not log error
    mov r3,@ErrNum  ; save error
    jmp zl2         ; and exit

zlab2:
    li r2,LABEL     ; pointer to ram space for temp var
    push r2         ; push for use in getlabel
      
    li r14,b0getlabel_a
	bl @GoBank0
   
    push r2         ; push ptr to label
    li r14,b0findlabel_a
	bl @GoBank0
    pop r2          ; address of end of label
    pop r1          ; address of start of line
    ci r2,0h        ; is the addrss 0 (not found)
    jeq zl2         ; if so get out


zlist2: clr r2          ; set screeen pos to 0
    bl @gotoxy      ; move to screen pos

    li r2,EOF       ; load EOF in r2
    cb *r1,r2       ; is char EOF
    jeq zl2         ; if yes jump out

zl  bl @PrintString    ; print line of code
    push r1            ; save code ptr - place in code
    bl @CR             ; print newline
    pop r1             ; pop code ptr back
    clr r2             ; clear r2
    li r2,EOF          ; load r2 with EOF
    cb *r1,r2          ; is this char end of file
    jeq zl2            ; if yes jump out
    mov @CursorPos,r2  ; get cur screen position
    ci r2,800          ; check see if we are 800 down
    jlt zl             ; if less than then loop back up
    push r1            ; save code ptr
    bl @CR             ; print new line
    li r1,PQMsg        ; get pointer to press key msg
    bl @PrintString    ; print the message

zlgetkey:
    bl @getkey         ; wait for key press
    ci r7,NKey         ; is it a  N
	jeq zlnext
        ;ci r7,Pkey        ; is it a P
        ;jeq zmprev
    ci r7,QKey         ; is it a Q
	jne zlgetkey       ; 	
	pop r1             ; 
	bl @Cls            ; clr screen
	jmp zl2            ; exit
	

zlnext:
    bl @Cls            ; clear the screen
    pop r1             ; pop ptr to code back
    jmp zl             ; loop back up for next line of code

zl2: 
    pop r11            ; pop return address
    b *r11             ; return to caller



zinsert:  ; insert code
    push r11
    li r1,ZIMsg         ; point to zi message
    bl @PrintString     ; print the zi message
zins2:
	mov @ScreenWidth,r11
	ci r11,32
	jeq zin32
	li r2,800           ; set screen posisiton for get str
	jmp zins2a
zin32:
	li r2,640
	
zins2a	
    push r2             ; push it so get str can pop it

        ;li r14,b1getstr_a
        ;bl @GoBank1
    bl @GetStr          ; call get str
    li r6,TIB           ; get address of string from get str
    clr r3              ; clr r3
    movb *r6,r3         ; read char from text input buffer
    ci r3,0             ; is it end of line
    jne zins3           ; if no jump down
    bl @Cls             ; clear screen
    pop r11
	b *r11
	 ;;jmp zexit           ; get out

zins3   mov @CodeTop,r7     ; point to bottom of codearea
    bl @strcopy         ; append new line of code
    li r6,TIB           ; reset TIB pointer
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



zm2:    ; monitor
	push r11               ; push return addr
	mov @Screenwidth,r3
	ci r3,40
	jeq zmcont
	li r1,1700h
	bl @Text40
	bl @Cls
zmcont:	
	ci r3,0
	jne zm2b
	push r3               ; dummy push
	b @zmgetaddr
zm2b:
    pushss r6              ; get address and space on string stack
    bl @gethexstring       ; read the hex string from input TIB
    popss r6               ; get address where the hex number str is

zm2a:
    mov @errnum,r1         ; did error occur
    ci r1,0                ; if 0 no error yes otherwise
  	jeq zm2c
	b @zexit               ; if not 0 then error and exit out

zm2c:	li r14,b0hstrtonum_a   ; get address of routine in bank0
	bl @GoBank0            ; trampoline back to Bank0
    mov r7,r4              ; copy result to r4
zmloop: 
	push r4                ; save 
    li r5,48h              ; r5 number of characters to prt in ramdump
    bl @ramdump            ; call ramdump
    bl @CR                 ; carriage return
	invon


	li r5,4
	li r2,760
zmmloop:
	bl @gotoxy
	li r1,Blanks
	bl @PrintString
	ai r2,40
	dec r5
	jne zmmloop
	
	li r2,760
	bl @gotoxy
	li r1,Mmsg	           ; address of  Map message
	bl @PrintString        ; print it 
	li r1,Amsg             ; address message
	bl @PrintString        ; print it
    li r1,PQmsg            ; prev next quit msg
    bl @PrintString        ; print it
	li r2,840
	bl @gotoxy
	li r1,BankMsg1         ; Banks message 1
	bl @PrintString
	li r2,880
	bl @gotoxy
	li r1,BankMsg2         ; Banks message 2
	bl @PrintString
	
	mov @MemMapper,r1
	ci r1,0
	jeq mmoff
	li r1,Onmsg
	push r1
	push r7
	push r5
	
	clr r7
	li r5,zmbanktbl
	
banktop:	
	
	mov *r5,r2
	bl @gotoxy
	li r1,ThreeBlanks
	bl @PrintString
	mov *r5,r2
	bl @gotoxy
	inct r5

	pushss r6
	mov r6,r1
	li r0,Bank2Map
	a r7,r0
	clr r3
	movb *r0,r3
	ci r3,0
	jeq banktop2
	
	swpb r3
	push r1
	bl @toascstr
	pop r1
	bl @PrintString

banktop2:	
	popss r6
	inc r7
	ci r7,8
	jne banktop
	
	
	pop r5
	pop r7
	pop r1
	
	
	jmp mmmsg

mmoff:
	li r1,Offmsg

	
mmmsg	
	li r2,801
	bl @gotoxy
	bl @PrintString
	invoff
zmask:  
    bl @getkey             ; get keyboard press
	ci r7,Akey             ; is it an A
	jeq zmgetaddr
    ci r7,NKey             ; is it a  N
	jeq zmagain
    ci r7,Pkey             ; is it a P
    jeq zmprev
	ci r7,Mkey             ; is it a M
    jeq zmmem
	ci r7,QKey             ; is it a Q
    jne zmask
    pop r4
    bl @Cls
    jmp zexit

zmmem:   ; toggle memory
	bl @Cls
	pop r4
	mov @MemMapper,r1
	ci r1,0                ; is mapper off
	jeq zmemset            ; if off turn on
	mapperoff	       ; it's on turn off
	clr @MemMapper
	b @zmloop
zmemset:	
	mapperon
	;li r1,0FFFFh
	li r1,1
	mov r1,@MemMapper
	;jmp zmloop
	b @zmloop

zmgetaddr:
	pop r4               ; not needed as new address to be enterd
	;;bl @CR               ; carriage return
	li r2,808
	bl @gotoxy
	li r1,Admsg          ; addr msg
	invon
	bl @PrintString      ; print it
	li r7,815            ; position on screen to do getmsg
	push r7              ; push pos for getstr
	bl @getstr           ; call getstr
	invoff
	push r9	             ; save pointer to code gethexstring uses it
	li r9,TIB            ; point to Text input buffer
    pushss r6            ; get address and space on string stack
    bl @gethexstring     ; read the hex string from input TIB
    popss r6             ; get address where the hex number str is
	pop r9               ; get code pointer back
	bl @Cls              ; clear screen
	b @zm2a             ; jump up to display


zmagain:
    bl @Cls
    pop r4
    ;ai r4,0A0h
	ai r4,90h
    b @zmloop

zmprev:
    bl @Cls         ; clr screen
    pop r4          ; get last addr
    ;ai r4,-0A0h    ; subract A0 to go to prev 
    ai r4,-90h
	b @zmloop       ; 

zmerr:
    li r1,1          ; missing space
    mov r1,@ErrNum   ; log error
    jmp zexit
zexit:
	pop r11
	;jmp $
	b *r11



gethexstring: ; read string of hex numbers from input stream and return in
              ; address in r6 as passed in
              ; if any chars not hex digit error is flagged
    push r11         ; store return value
    clr r3           ; clear char register
ghsloop:
    movb *r9+,r3     ; read char
    ci r3,0          ; is it end of line
    jeq ghsterm      ; if yes then exit
    ci r3,SPACE      ; is it a space (end of num)
    jeq ghsterm      ; if yes then exit
    bl @ishexdigit   ; is it a hex digit
    jne ghserr       ; if not then error
    movb r3,*r6+     ; store hex digit in return string
    jmp ghsloop      ; got get next char

ghsterm:
    clr r3          ; clr for eol
    movb r3,*r6     ; mark end of of string
    jmp ghsexit

ghserr:
    li r1,17         ; error 17 - bad hex num
    mov r1,@ErrNum   ; store error
ghsexit:
    pop r11          ; get return value
	b *r11
