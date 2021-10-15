           ;; Andiar Systems MUMPS for TI 99 4/A - Version 1.x
	   ;; Assumes Expansion Memory of at lest 32K 
	   ;; Assembled to 8K Rom Cart amC.bin - copied to SD for FlashRom99
	   ;; Author : Tom Raidna - Andiar Systems Software
	   ;; 2021/10 Retrochallenge 

	include "stack.mac"


;; 16 bit Pad Ram
WKSPACE    equ 08300h   ; MUMPS workspace r9 - code ptr, r10 stack ptr
CursorPos  equ 08320h   ; current screen location
HaltFlag   equ 08322h   ; halt flag set when halt or error
ErrNum     equ 08324h   ; Error number set when an error
CodeTop    equ 08326h   ; next available address for code (bytes)
MSP        equ 08328h   ; mumps math stack pointer (strings 32 bytes ea)
LastKeyin  equ 0832Ah   ; used for getkey - dup keys 
VIptr      equ 0832Ch   ; pointer to next available local var index node
VDptr      equ 0832Eh   ; pointer to next available local var data node
STRSP      equ 08330h   ; pointer to top of string stack 
QuitFlag   equ 08332h   ; True when Quit and return stack empty
Head       equ 08334h   ; head of the symbol table b-tree
keyin      equ 08375h   ; ROM - kscan address for ascii code
DolT       equ 08376h    ; MUMPS system variable $T used for if, else, read
Parenct    equ 08378h   ; word to count paren depth
ALTSPACE   equ 083C0h   ; Available alternate workspace
wspMonitor equ 083E0h	; Address for our monitor Vars

	   ; Lower Ram in expansion
VARINDEX   equ 02000h   ; 6k space for varible index records
TIB        equ 03800h   ; text input buffer - 128 bytes
CmdLine    equ 03880h   ; code typed in     - 128 bytes
MSTACK     equ 03900h   ; return stack      - 256 bytes
VARNAME    equ 03A00h   ; varibale for varnames - 16 bytes tree, etc
LABEL      equ 03A10h   ; label names (do, zl etc)16 bytes 
          
	 ; for dsrlnk calls
sav8a      equ 03A20h       ;
savcru     equ 03A22h       ; cru address of the peripheral
savent     equ 03A24h       ; entry address of dsr or subprogram
savlen     equ 03A26h       ; device or subprogram name length
savpab     equ 03A28h       ; pointer to device or subprogram in the pab
savver     equ 03A2Ah       ; version # of dsr
flgptr     equ 03A2Ch       ; pointer to flag in pab (byte 1 in pab)
dsrlws     equ 03A2Eh       ; data 0,0,0,0,0    ; dsrlnk workspace
dstype     equ 03A38h       ; data 0,0,0,0,0,0,0,0,0,0,0
haa        equ 03A4Eh       ; used to store AA pattern for DSR ROM detection
namsto     equ 03A50h       ; 0,0,0,0 ( 8 bytes)  

	; Scratch PAB in ram template  for diskio

pabopc	    equ 03A60h         ; PAB RAM - start of ram PAB for diskio 
pabflg      equ 03A61h         ; filetype / error code
pabbuf      equ 03A62h         ; word, address of pab buffer (1000) 
pablrl      equ 03A64h         ; logical rec length (write, read)
pabcc       equ 03A65h         ; output char count
pabrec      equ 03A66h         ; record number
pabsco      equ 03A68h         ; usual 0, screen offset
pabnln      equ 03A69h         ; length of file name DSK1.FILE1 = 10 0AH 
pabfil      equ 03A3Ah         ; text of filename ( leave 32 bytes ?)


SCRATCH    equ 03B00h   ; FREE MEMORY 3B00-3BFF FOR NOW
STACK      equ 03C00h   ; Stack t0 3FFF - total of 1024 bytes 512 words

           ; Upper Ram in expansion
CODESTART  equ 0A000h   ; location of MUMPS code to interpret
VARDATA    equ 0C800h   ; start of Variable data area c800-F7FF
STRSTACK   equ 0F800h   ; MUMPS String stack for math, operators etc 2k

           ; equates for word length Charaters values
Quote      equ '"'
Space      equ 02000h   ; word value of space
Hashtag    equ 02300h   ; word value of #
Exclampt   equ 02100h   ; word value of !
Dol        equ 02400h   ; word value of $
Amp        equ 02600h   ; word value of &
OpenParen  equ 02800h   ; word value of (
CloseParen   equ 02900h   ; word valude of )
Asteric      equ 02A00h   ; word value of *
Plus         equ 02B00h   ; word value of +
Comma        equ 02C00h   ; word value of ,
Minus        equ 02D00h   ; word value of -
Zero         equ 03000h   ; word value of '0'
Period       equ 02E00h   ; word value of .
Slash        equ 02F00h   ; word value of /
Semicol      equ 03B00h   ; word value of ;
LessThan     equ 03C00h   ; word value of <
Equals       equ 03D00h   ; word value of =
Greater      equ 03E00h   ; word value of > 
RightBracket equ 05D00h   ; word value of ]
Carat        equ 05E00h   ; word value of ^
Underscore   equ 05F00h   ; word value of _
Cursor       equ 01E00h   ; word value of - defined below
MTRUE        equ 03100h   ; word value of true '1' 
MFALSE       equ 03000h   ; word value of false '0'


Quoteword  equ 02200h   ; word value of "
NULL       equ 00000h   ; NULL end of string marker
EOF        equ 0FF00h   ; 255 byte or FFFFh work end of file marker

	 ; Cartridge Header Info 	 
	include am.h  
	include utils.asm   ; define cursor, copy font from TI Basic Grom

ProgramStart:
	
	limi 0        	; disable interrupts
	lwpi WKSPACE    ; set default workspace - 083C0h from equ above

	clr r2            ; set screen pos to 0
	bl @gotoxy        ; move to screen pos 0

	clr r0		     ;Zero Xpos
	;movb r0,@CursorX     ;Xpos
        movb r0,@CursorPos   ;screen pos

	; initialize stacks	
	li r10,STACK      ; assembly code pointer
	li r13,MSTACK     ; mumps return stack
	li r2,STRSTACK    ; mumps string/math stack
	mov r2,@MSP       ; mumps string stack 	

	; initialize MUMPS source code area

	bl @defcursor     ; create cursor definition
	bl @copychardef   ; copy TI Basic character defs to VDP mem
		
startmumps:
   ; area for test code

	bl @SetBorderCol
	li r1,01700h
	bl @SetColors


init:	clr r2
	mov r2,@HaltFlag       ; set haltflag to 0 - keep parsing 
	mov r2,@ErrNum         ; set ErrNum to 0   - no errors
	mov r2,@Head           ; set Head of btree to empty
	li r2,CODESTART
	mov r2,@CodeTop        ; Iintial CodeTop ( next addres for M code)
	li r1,EOF              ; Initial code space
	mov r1,*r2             ; put end of file at first space in code mem

	li r2,VARINDEX
	mov r2,@VIptr         ; initialize ptr to var index
	li r2,VARDATA
	mov r2,@VDptr         ; initialize ptr to var data
	
;;;;;;;;;;;;;;;
 
;;;;;;;;;;;;;;;




splash: 
	clr r2
	bl @gotoxy
	li r1,StarStr
        bl @PrintString
        li r1,SplashStr    ;ascii string address
        bl @PrintString    ;0 terminated string
        li r1,StarStr
        bl @PrintString
	bl @CR

mgs	li r2,0260h       ; set screen position column 0 row 20 (30*20+0)
	bl @gotoxy        ; move cursor to position
	li r1,Mprompt     ; point r1 to string a Mprompt
	bl @PrintString   ; Print the string 
	li r2,0262h       ; screen pos to start getstr
	push r2
	bl @GetStr        ; read in command line
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
	
lp:     clr r3            ; clr out to hold char in msb
        mov r3,@QuitFlag  ; reset quitflag
	movb *r9+,r3      ; read char and move to r3
	ci r3,EOF
	jeq mgs
	ci r3,NULL        ; check if end of line
	jne skiplbl       ; not end of line jump to skip label

iseof:	movb *r9+,r3      ; if end of line, is it EOF, get next char
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

	
chksp:	ci r3,SPACE       ; should be a space
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

iseol:	ci r3,NULL        ; check if null 
	jeq iseof         ; if null jump back up to eof test
lp2	swpb r3           ; move to lsb for use in as offset to jumptable
	bl @parse         ; go parse and run this command
pp      mov @ErrNum,r8    ; check if error
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
	bl @CR
	bl @CR
	li r1,ERRMSG
	bl @PrintString
	; reset error flag and any stacks
	mov @ErrNum,r2	
	bl @ShowHex4
	bl @CR

	li r13,MSTACK    ; init mumps stack (string stack later?)
	li r2,STRSTACK    ; mumps string/math stack
	mov r2,@MSP       ; mumps string stack 	

	clr r1
	mov r1,@ErrNum
	jmp mgs	

parse:  ; pass letter in r3
        push r11
	;mov r3,r2
	bl @toupper      ; conver command to upper case	
	ai r3,-65        ; find offset from A
        a r3,r3          ; double it as addresses are two bytes
	li r4,jmptbl     ; load address of jump table
        a r3,r4          ; add to offset
        mov *r4,r3       ; get jump address from address in jump table
	ci r3,0          ; is the address from the table 0
	jne parse2       ; if not keep jump down to parese2
	li r4,5          ; if yes then error #5 bad command
	mov r4,@ErrNum   ; store error 
	jmp pexit	 ; jump down to exit
parse2: bl *r3           ; jump to mumps command routine

pexit:	
	pop r11
	b *r11

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        include d.asm
       	include e.asm
	include g.asm
	include h.asm
        include i.asm
	include q.asm
	include r.asm
	include s.asm
        include w.asm
	include z.asm
	include mstr.asm
	include math.asm
	include strmath.asm
	include dol.asm
	include kscan.asm
	include mon.asm
	include prtlib.asm
	include strlib.asm
	include charlib.asm
	include tree.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SplashStr:
    byte "*  ANDIAR SYSTEMS MUMPS V 1.0  *"
    byte NULL
    align 2

StarStr:
        byte "********************************"
        byte NULL
        align 2
Mprompt:
        byte "> _"
        byte NULL
ERRMSG  byte "ERROR : "
	byte NULL
	align 2
HMSG:   byte "HALTING MUMPS"
        byte NULL
        align 2
debug1:  byte "DEBUG01"
 	 byte NULL
debug2:  byte "DEBUG02"
 	 byte NULL
ZIMsg:   byte "ENTER LINE OF CODE TO INSERT:"
	 byte 0
	 align 2
PressMsg: byte "PRESS ENTER TO CONTINUE"
	 byte 0
	align 2

jmptbl:  ; MUMPS command jump table
        word 0,0,0,Do,Else,0,Go,Halt
	word If,0,0,0,0,0,0,0
        word Quit,Read,Set,0,0,0,Write,0,0,Zee

doltbl:
	word dola,0,dolc,0,dole,0,0,0,0,0,0,doll,0
        word 0,0,dolp
