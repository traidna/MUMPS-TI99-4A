	
	include stack.mac
	include equ.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  MUMPS  Header Bank2          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        Padding Off             ;Stop the assembler adding zeros
        ORG  6000h              ;Our program starts at 6000h
        WORD 0AA01h             ;header
        Word 0
        Word 0
        WORD ProgramA           ;Pointer to 1st program
        Word 0
        Word 0
ProgramA:   WORD 0              ;1st entry 0=only one program
        ;WORD ProgramStart       ;Start of Program
        WORD kickback           ; program to jump back to bank0
        BYTE 11                 ;Text Length
        BYTE "MUMPS V B.2"      ;Text Message

kickback:
	li r0,0601Ch
	push r0
	bl @RetBank0
	jmp $

b2prterrmsg:
	bl @PrtErrMsg
	bl @RetBank0
	

PrtErrMsg:   ; look at @ErrMsg and Print error message	
	push r11
	
	;; Print Error : and error number
	bl @CR
	bl @CR
	li r1,ERRMSG
	bl @PrintString
	mov @ErrNum,r2	
	li r14,b1ShowHex42_a
	bl @GoBank1
	
	; Print address of error
	li r1,AtAddrmsg
	bl @PrintString
	mov r9,r2
	li r14,b1ShowHex42_a
	bl @GoBank1
	bl @CR
	bl @CR
	
	; Print Line of Code 
	; Either start of commnand line or end or previous line
	ci r9,CODESTART
	jl errcmdln
	
	mov r9,r1
errloop:	
	dec r1
	
	movb *r1,r3
	ci r3,0
	jne errloop
	inc r1
	jmp errprtline
	
errcmdln:
	li r1,CmdLine
	
errprtline:	
	bl @PrintString
	bl @CR
	bl @CR
	; speech Error
    li r0,28EFh	        ; Error
	li r14,b1Speech2_a
	bl @GoBank1
	
	mov @ErrNum, r1
	a r1,r1
	ai r1,Errtbl
	mov *r1,r1
	bl @PrintString
	
	; reset error flag and any stacks
	li r13,MSTACK     ; init mumps stack (string stack later?)
	li r2,STRSTACK    ; init mumps string/math stack
	mov r2,@MSP       ; mumps string stack 	

	clr r1
	mov r1,@ErrNum

	pop r11
	b *r11

	jmp $
	
	include bank2lib.asm	
	include prtlib.asm	
	
Errtbl:
	word 0,e1,e2,e3,e4,e5,0,e7,e8,e9,e10,e11,e1,e13,e14,e15,e16
	word e17,e18,e19,e20,e21,e22,e23,e24,e25,e26,e27

ERRMSG  
	byte "ERROR : ",0
	align 2	
AtAddrmsg
	byte "  At address : ",0
	
e1:
	byte "Missing Space",0
	align 2
e2:
	byte "Invalid value",0
	align 2
e3:
	byte "Invalid number",0
	align 2
e4:
	byte "Label must start with letter",0
	align 2
e5:
	byte "Unrecognized Command",0
	align 2
e7:
	byte "Invalid file mode",0
	align 2

e8:
	byte "File I/O",0
	align 2
e9:
	byte "Bad device numver",0
	align 2
e10:
	byte "Missing colon :",0
	align 2
e11:
	byte "Invalid Label",0
	align 2
e13:
	byte "Invalid $function call",0
	align 2
e14:
	byte "Missing open paren (",0
	align 2
e15:
	byte "Missing close paren )",0
	align 2
e16:
	byte "Proglem with call to $p",0
	align 2
e17:
	byte "Invalid hex number",0
	align 2
e18:
	byte "Problem with call to $H",0
	align 2
e19:
	byte "Problem with call to $S",0
	align 2
e20:
	byte "Problem with call to $B",0
	align 2
e21:
	byte "Problem with call to $K",0
	align 2
e22:
	byte "Problem with call to $I",0
	align 2
e23:
	byte "Character read not valid with disk file",0
	align 2
e24:
	byte "Expecting equals =",0
	align 2
e25:
	byte "Variable does not exist",0
	align 2
e26:
	byte "Problem with call to $N",0
	align 2
e27:
	byte "Problem with call to $Q",0
	
	align 2


	; do not load anything below this line 
	; this line is to make sure the bin is 8K
   org 07FFFh
   byte 0
