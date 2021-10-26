GoBank:  ; r1 = 6002,6000     BANK0, BANK1
	 ; r2 = address in bank to jump to
	 ;

	li r0,004E0h
	mov r0,@SWBANK
	mov r1,@SWBANK+2
	li r0,00460h
	mov r0,@SWBANK+4
	mov r2,@SWBANK+6
	b @SWBANK

