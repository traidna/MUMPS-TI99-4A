GoBank0:  ;
          ; r14 = address in bank to jump to
          ;
    push r11
    push r1
    li r1,BANK0           ; bank 1
    mov r1,@SWBANK+2      ; mov address of bank to pad ram
    mov r14,@SWBANK+6     ; move address to jump to to pad ram
    pop r1
    b @SWBANK             ; jump to pad ram to execute


RetBank0:  ; r1 bank address to pass always bank 0
           ; address to return should be on top of the stack
	push r1
    li r1,BANK0           ;
    mov r1,@SWBANK+2      ; mov address of bank to pad ram
    pop r1
       
	pop r11                ; pop address that was pushed in gobank
    mov r11,@SWBANK+6      ; move address to jump to to pad ram

    b @SWBANK             ; jump to pad ram to execute




RetBank2:  ; r1 bank address to pass always bank 0
           ; address to return should be on top of the stack
	push r1
    li r1,BANK2           ;
    mov r1,@SWBANK+2      ; mov address of bank to pad ram
	pop r1
    pop r11                ; pop address that was pushed in gobank
    mov r11,@SWBANK+6      ; move address to jump to to pad ram

    b @SWBANK             ; jump to pad ram to execute