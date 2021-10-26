Bank:   ; 
	push r11
	li r1,debug1
	bl @PrintString

	li r1,06000h
	li r2,06032h
	b @GoBank

	pop r11
	b *r11


