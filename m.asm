	; h.asm - halt routine
Mw: 	; 

	push r11
	bl @CR              ; carriage return
        li r1,debug1          ; halt message
	bl @PrintString     ; print halt message		 
	li r14,b1getkey_a   ; set address in bank2 for getkey

	li r14,061D0h       ;
	bl @GoBank2



	pop r11
	b *r11             ; never happens save in case we want to be able
                           ; to not halt mumps 
