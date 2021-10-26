WKSPACE		equ 08300h
ProgramStart    equ 060C8h
SWBANK     	equ 08340h   ; 8 bytes for bank switching code 8340 - 8347	


        Padding Off             ;Stop the assembler adding zeros
        ORG  6000h              ;Our program starts at 6000h
        WORD 0AA01h             ;header
        Word 0
        Word 0
        WORD ProgramA           ;Pointer to 1st program
        Word 0
        Word 0
ProgramA:   WORD 0              ;1st entry 0=only one program
        WORD kickback           ;Start of Program
        BYTE 11                 ;Text Length
        BYTE "MUMPS V 0.1"      ;Text Message



kickback:
	lwpi WKSPACE
	limi 0
	li r1,6002h
	li r2,ProgramStart
	b @GOBANK


	jmp $

db:     ; just a debug place to jump to	
	li r1,03B00h    ; scratch
	li r2,0AAAAh    ; 
	mov r2,*r1
	
	jmp $

	include banklib.asm
