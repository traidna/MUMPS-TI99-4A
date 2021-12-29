GoBank1:  ; 
	  ; r14 = address in bank to jump to
	  ;
	push r11
	push r1
	li r1,BANK1           ; bank 1
	mov r1,@SWBANK+2      ; mov address of bank to pad ram
	pop r1
	mov r14,@SWBANK+6      ; move address to jump to to pad ram	 
	b @SWBANK             ; jump to pad ram to execute


gb1init: ; call once to init
	li r0,004E0h          ; clr opcode
	mov r0,@SWBANK        ; mov to pad ram
	li r0,00460h          ; branch opcode
	mov r0,@SWBANK+4      ; move opcode to pad ram
	b *r11


GoBank2:  ; 
	  ; r14 = address in bank to jump to
	  
	push r11
	push r1	
	li r1,BANK2           ; bank 1
	mov r1,@SWBANK+2      ; mov address of bank to pad ram
	pop r1
	mov r14,@SWBANK+6      ; move address to jump to to pad ram	 
	b @SWBANK             ; jump to pad ram to execute

	
RetBank1:  ; r1 bank address to pass always bank 0
           ; address to return should be on top of the stack
	push r1
        li r1,BANK1           ;
        mov r1,@SWBANK+2      ; mov address of bank to pad ram
	pop r1
        pop r11                ; pop address that was pushed in gobank
        mov r11,@SWBANK+6      ; move address to jump to to pad ram

        b @SWBANK             ; jump to pad ram to execute


