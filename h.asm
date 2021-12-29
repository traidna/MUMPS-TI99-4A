	; h.asm - halt routine
Halt: 	; 
	mov r11,r7          ; hold return address
	bl @CR              ; carriage return
    li r1,HMSG          ; halt message
	bl @PrintString     ; print halt message		 
	bl @CR              ; carriage return
	bl @CR              ; carriage return
	li r1,PressMsg      ; get Press key to continue
	bl @PrintString     ; print press key message

	li r0,3148h	        ; goodbye
	li r14,b1Speech_a
	bl @GoBank1

	
	li r14,b1getkey_a   ; set address in bank2 for getkey
	bl @GoBank1	        ; switch to bank1

	
	li r1,1             ; set 1 in r1
	mov r1,@HaltFlag    ; copy to halt flag - true
	blwp @0             ; init system
	b *r7               ; never happens save in case we want to be able
                        ; to not halt mumps 


