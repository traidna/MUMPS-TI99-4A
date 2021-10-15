;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Header             ;
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
        WORD ProgramStart       ;Start of Program
        BYTE 11                 ;Text Length
        BYTE "MUMPS V 0.1"      ;Text Message

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
