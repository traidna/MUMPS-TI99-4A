       ;; Andiar Systems MUMPS for TI 99 4/A - Version 1.x
	   ;; Assumes Expansion Memory of at lest 32K 
	   ;; Assembled to 24K Rom Cart amC.bin - copied to SD for FlashRom99
	   ;; Author : Tom Raidna - Andiar Systems Software
	   ;; 2021/10 Retrochallenge 

	include "stack.mac"
	; Cartridge Header Info and equates	 
	include equ.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  MUMPS  Header Bank0          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    Padding Off             ;Stop the assembler adding zeros
    ORG  6000h              ;Our program starts at 6000h
    WORD 0AA01h             ;header
    Word 0
    Word 0
    WORD ProgramA           ;Pointer to 1st program
    Word 0
    Word 0
ProgramA:
	WORD 0                  ;1st entry 0=only one program
	WORD ProgramStart       ;Start of Program
	BYTE 11                 ;Text Length
	BYTE "MUMPS V 0.A"      ;Text Message

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CODE 
	;MOVB @Spchrd,@SPDATA
	;mov r11,r11
	;B *r11
;CLEN EQU $-CODE
	
	
ProgramStart:
	jmp PS2	  ; jump to staert of MUMPS

	;;  entry point for call from other banks, do not move or 
	;;  address in equ.asm will need to be changed

b0treeprint:     ; b1kscan -> getkey
    bl @treeprint
    b @RetBank1

b0getmstr:
	bl @getmstr
	b @RetBank1

b0clrVDPbuf:
	bl @clrVDPbuf
	b @RetBank1

b0WriteFile:
	bl @WriteFile
	b @RetBank1

EOFmark byte 0FFh,00

b0getlabel:
	pop r11    ; return address gobank
	pop r1     ; LABEL address
	push r11   ; return address gobank
	push r1    ; LABEL address
	bl @getlabel
	b @RetBank1

b0findlabel:
	pop r11        ; ret addre gobank
	pop r1         ; address of label
	push r11       ; ret addr gobank
	push r1        ; address of label
	bl @findlabel
	pop r2         ; addr of label2
	pop r1         ; addr of label1
	pop r11        ; RetBank ret addr
	push r1        ; addr of label 1
	push r2        ; addr of label 2
	push r11       ; RetBank Ret addr
	b @RetBank1

b0hstrtonum:
	bl @hstrtonum
	b @RetBank1


	;;;; Start of MUMPS interpreter

PS2:	
    limi 0        	; disable interrupts
	lwpi WKSPACE    ; set default workspace - 083C0h from equ above

	clr r2            ; set screen pos to 0
	bl @gotoxy        ; move to screen pos 0

	clr @CursorPos

	;;;li r0,40
	li r0,32
	mov r0,@ScreenWidth

	; initialize stacks	
	li r10,STACK      ; assembly code pointer
	li r13,MSTACK     ; mumps return stack
	li r2,STRSTACK    ; mumps string/math stack
	mov r2,@MSP       ; mumps string stack 	
	
	; initialize MUMPS source code area

	
	bl @gb1init       ; initial trampoline code for switch to bank 1

startmumps:

   ; area for test code

	;
	
init:	
	li r14,b1minit_a
	bl @GoBank1
		
mgs	
	li r2,800         ; set screen pos col 0 row 20 (ScreenWidth*20+0)
	mov @ScreenWidth,r0
	ci r0,32
	jne mgs2
	li r2,640
	
mgs2:
	bl @gotoxy        ; move cursor to position
	li r1,Mprompt     ; point r1 to string a Mprompt
	bl @PrintString   ; Print the string 

	li r2,802         ; screen pos to start get_str
	mov @ScreenWidth,r0
	ci r0,32
	jne mgs3
	li r2,642

mgs3:
	
	push r2

	li r14,b1getstr_a  ; type in command
	bl @GoBank1

	bl @Cls	          ; think about storing screen pos and not clearing
	li r6,TIB         ; copy code from text input buffer
	li r7,CmdLine     ; place it where it can be executed
	li r2,SPACE       ; 
	movb r2,*r7       ; start with space
	inc r7            ; position to copy string from TIB
	bl @strcopy       ; copy it over
	inc r7            ; strcopy leaves r7 at Null terminator 
	li r2,EOF         ; end of file marker on command string
    movb r2,*r7       ; put in CmdLine

	li r9,CmdLine     ; pointer to string of mumps code

		; entry point to run a MUMPS command 
		; R9 should be pointing to first char of 
	    ; label of a line, or space between commands in a line
		; or NULL at end of line
	
lp:     
    clr r3            ; clr out to hold char in msb
    mov r3,@QuitFlag  ; reset quitflag
	movb *r9+,r3      ; read char and move to r3
	ci r3,EOF
	jeq mgs
	ci r3,NULL        ; check if end of line
	jne skiplbl       ; not end of line jump to skip label
	mov @DoFlg,r2     ; see if in a do call
	ci r2,0           ; if zero not in do
	jne iseof
	mov @Forflg,r2    ; see if in a for loop
	ci r2,0           ; if 0 not in for looop
	jeq iseof         ; jump down to continue
	pop r11           ; if in for loop pop address of call from for
	b *r11

iseof:	
    movb *r9+,r3      ; if end of line, is it EOF, get next char
	ci r3,EOF         ; compare to EOF 
    jeq mgs           ; if yes end of this line of code - go get next cmd


skiplbl:  ; code to skip a label
	bl @isalpha       ; is it an alpha ?
	jne chksp         ; no then continue on
    ; loop rest of label chars can be alpha or digits
skiplp	movb *r9+,r3      ; yes get next character put in r3
	bl @isalpha       ; is it an letter 
	jeq skiplp        ; if yes skip it
	bl @isdigit       ; is it a digit
	jeq skiplp	  ; if yes skip it

chksp:	
	ci r3,SPACE       ; should be a space
	jeq skipws        ; is yes jump to skip white space
	li r2,1           ; error #1 - missing space
	mov r2,@ErrNum    ; store error

skipws:
	movb *r9+,r3      ; read current char and advance pointer
	ci r3,SPACE       ; compare to space
	jeq skipws        ; if space loop back up

	ci r3,Semicol     ; is it a comment line
	jne iseol         ; if not move on	
toeol:	movb *r9+,r3      ; move to end of line by advancing
	ci r3,NULL 	  ; until NULL
	jne toeol        

iseol:
	ci r3,NULL        ; check if null 
	jeq iseof         ; if null jump back up to eof test
lp2:
	swpb r3           ; move to lsb for use in as offset to jumptable
	bl @parse         ; go parse and run this command
pp:      
	mov @ErrNum,r8    ; check if error
	ci r8,0           ; check for no error
	jne errors        ; ErrNum does not contain 0
	mov @HaltFlag,r8  ; get haltflag 
        ci r8,0           ; compare to 0 - keep going 
	jne done          ; not zero so exit out ( either H, or error)
	mov @Quitflag,r8  ; is it a quit the program
	ci r8,0           ; not done
	jne mgs
    jmp lp            ; keep going

done:
	jmp $			;InfLoop


errors:   ; 
	; call error handling in bank2 code am2.asm
	li r14,b2prterrmsg_a
	bl @GoBank2
	b @mgs	


parse:  ; pass letter in r3
    push r11         ; return address of caller
	bl @toupper      ; convert command to upper case	
	ai r3,-65        ; find offset from A
    a r3,r3          ; double it as addresses are two bytes
	li r4,jmptbl     ; load address of jump table
    a r3,r4          ; add to offset
    mov *r4,r3       ; get jump address from address in jump table
	ci r3,0          ; is the address from the table 0
	jne parse2       ; if not keep jump down to parese2
	li r4,5          ; if yes then error #5 bad command
	mov r4,@ErrNum   ; store error 
	jmp pexit	     ; jump down to exit
parse2: 
	bl *r3       ; jump to mumps command routine

pexit:	
	pop r11          ; get return address of caller
	b *r11           ; return to caller

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include bank0lib.asm
	include samslib.asm
	;include utils.asm   ; define cursor, copy font from TI Basic Grom
	include c.asm
	include d.asm
    include e.asm
	include f.asm
	include g.asm
	include h.asm
    include i.asm
	include m.asm
	include o.asm
	include q.asm
	include r.asm
	include s.asm
    include u.asm
	include w.asm
	include z.asm
	include mstr.asm
	include math.asm
	include strmath.asm
	include dol.asm
	include prtlib.asm
	include strlib.asm
	include charlib.asm
	include vdpfio.asm 
	include tree.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Mprompt:
    byte "> "
    byte NULL

HMSG:   
	byte "HALTING MUMPS"
    byte NULL
    align 2
debug1:  
	byte "DEBUG01"
 	byte NULL
PressMsg: 
	byte "PRESS ENTER TO CONTINUE"
	byte 0
	align 2

zsfn:	
	byte "DSK1.MSRC"
	byte 0
	align 2

NULLstr 
	byte 0h
	align 2	


		
jmptbl:  ; MUMPS command jump table
    word 0,0,Close,Do,Else,For,Go,Halt
	word If,0,0,0,Mw,0,Open,0
    word Quit,Read,Set,0,Use,0,Write,0,0,Zee

doltbl:
	word dola,dolb,dolc,0,dole,0,0,dolh,doli,dolj,dolk,doll,dolm
    word doln,dolo,dolp,dolq,0,dols,doltt,dolu,dolv,dolw,dolx,0,0

	org 07fffh
	byte 0
