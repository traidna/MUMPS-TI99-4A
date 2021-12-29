

zwrite:   ; print all the variables in the symbol table
	push r11
        mov @HEAD,r6      ; get head of binary tree
   	li r14,b0treeprint_a
	bl @GoBank0
     	;bl @treeprint     ; call tree print (needs r6 ) tree.asm
        ;jmp zexit         ; jump out
	pop r11
	b *r11

zremove:  ;  remove file from Code Area by placing FF in first byte
	push r11
        li r2,CODESTART    ; set to start of code ram
        mov r2,@CodeTop    ; Iintial CodeTop ( next addres for M code)
        li r1,EOF          ; Initial code space
        mov r1,*r2         ; put end of file at first space in code mem
      
	;b @zexit
	pop r11
	b *r11


;;;zload:
        ;;;movb *r9+,r3
        ;;;ci r3,SPACE       ; should be a space
        ;;;jeq zload1
        ;;;; b @zserr         ; missing space
zload1:
        ;;;li r14,b1clrampab_a   ; address to call in bank1
        ;;;bl @GoBank1           ; goto bank1
        bl @clrampab      ; clear out PB ram ( real PEB needs this)

	li r14,b0getmstr_a  ;
	bl @GoBank0       ; call getmstr in bank 0

        ;;;bl @getmstr       ; get filename - check for error ??
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

        ;li r14,b1clrVDPbuf_a
        ;bl @GoBank1
        bl @clrVDPbuf    ; clear read buffer

        ;;;li r14,b1fileio_a
        ;;;bl @GoBank1
        bl @fileio       ; request the read

        li r0,BUFADR     ; vdp address of read buffer
        ;pushss r2        ; address in ram to copy to
        pop r2
        push r2

        ;li r14,b1VDPtoRAM_a
        ;bl @GoBank1
        bl @VDPtoRAM     ; copy from Vdp memory to ram (bufaddr to var)
        pop r3
        clr r1
        movb *r3,r1
        ci r1,0FF00h
        jne zlrdfile
        ai r2,-2
        mov r2,@CODETOP
        jmp zsclose


zsclose ; close file
        li r1,00100h      ; r1 00100 move only msb to pab rest of rec is set
        movb r1,@pabopc   ; copy to ram version of pab

        ;;;;li r14,b1fileio_a
        ;;;;bl @GoBank1
        bl @fileio        ; write the record

        b @zexit          ; branch to exit
	


