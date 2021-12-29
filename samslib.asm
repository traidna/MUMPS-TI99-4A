mapperon: macro
	push r12
	li r12,1E00h
	SBO 1
	pop r12

	push r1
	;li r1,0FFFFh
	li r1,1
	mov r1,@MemMapper
	pop r1
 	endm

mapperoff: macro
	push r12
	li r12,1E00h
	SBZ 1
	pop r12
	clr @MemMapper	
	endm


mappage:
	; R1 - pass in page in msb of R1 xx00h
	; R2 - pass in 4k block address to map to
	; 4004h - 2000h, 4006h - 3000h
	; 4014h - A000h, 4016h - B000h, 4018h - C000h 
        ; 401Ah - D000h, 401Ch - E000h, 401Eh - F000h
	; note this only sets up the map 
	; use SBO 1 to turn on mapper
	; use SBZ 1 to turn off mapper and revert to core memory
 
 	LI   R12,01E00h   ; AMS CRU
      	SBO  0            ; Enable MR's
  	MOV  R1,*R2       ; Write page in msb R1 to block address
      	SBZ  0            ; Disable MR's
	b *r11            ; return to caller


